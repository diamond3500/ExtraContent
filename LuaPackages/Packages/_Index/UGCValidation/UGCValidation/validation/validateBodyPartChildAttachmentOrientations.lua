--[[
We will validate two things:
    - All rig attachments have no orientation
    - Grip attachments are oriented to best align tools along the arm. We base this off the vector from ElbowAtt to WristAtt 


In the future, we can also validate other attachment orientations to make sure back accessories, hats, etc are properly oriented
    - To do this, we need to look at more examples and ensure we are not limiting creativity. Eg: Head mesh thats slanted, which means a hat should actually be slanted as well.
    - So for now, we will only limit grips, because this can affect gameplay (ex. sword pointing into the body) and can be computed with the arm bone instead of mesh analysis.
]]

local root = script.Parent.Parent
local Analytics = require(root.Analytics)
local Types = require(root.util.Types)
local FailureReasonsAccumulator = require(root.util.FailureReasonsAccumulator)
local getDiffBetweenOrientations = require(root.util.getDiffBetweenOrientations)
local floatEquals = require(root.util.floatEquals)
local valueToString = require(root.util.valueToString)
local getFFlagRefactorBodyAttachmentOrientationsCheck =
	require(root.flags.getFFlagRefactorBodyAttachmentOrientationsCheck)

local getFIntUGCValidationGripAttOrientationThreshold =
	require(root.flags.getFIntUGCValidationGripAttOrientationThreshold)

local ValidateBodyPartChildAttachmentOrientations = {}

function ValidateBodyPartChildAttachmentOrientations.expectedGripAttCFrame(
	armAsset: Instance,
	assetTypeEnum: Enum.AssetType
): (Attachment, CFrame)
	--[[
    Returns { gripAttachment, expectedCFrame }

    -- We assume that when they imported the model, the hand (thumb) is facing towards the front (otherwise this is impossible)
	-- So just imagine the hand back to how it was imported, and we snap the arm into place. Then the bone gives you the exact rotation of the grip
    -- As they rotate the arm in game, that local CFrame stays the same and the gun simply rolls with the arm
    -- ]]
	assert(assetTypeEnum == Enum.AssetType.RightArm or assetTypeEnum == Enum.AssetType.LeftArm)
	local armPrefix = assetTypeEnum == Enum.AssetType.RightArm and "Right" or "Left"

	local lowerArm = armAsset:FindFirstChild(armPrefix .. "LowerArm") :: MeshPart
	local hand = armAsset:FindFirstChild(armPrefix .. "Hand") :: MeshPart
	assert(lowerArm)
	assert(hand)

	local armElbowAtt = lowerArm:FindFirstChild(armPrefix .. "ElbowRigAttachment") :: Attachment
	local armWristAtt = lowerArm:FindFirstChild(armPrefix .. "WristRigAttachment") :: Attachment
	local handWristAtt = hand:FindFirstChild(armPrefix .. "WristRigAttachment") :: Attachment
	local gripAtt = hand:FindFirstChild(armPrefix .. "GripAttachment") :: Attachment
	assert(armElbowAtt)
	assert(armWristAtt)
	assert(handWristAtt)
	assert(gripAtt)

	-- We need to know where the wrist and elbow attachments end up if we were to undo the attached hand rotation
	local wristAttWorldCFrame = CFrame.new(hand.CFrame.Position) * handWristAtt.CFrame -- CFrame of wrist attachment if hand has no rotation
	local lowerArmCFrame = wristAttWorldCFrame * armWristAtt.CFrame:Inverse() -- CFrame of lower arm that attaches to the above attachment
	local elbowAttWorldCFrame = lowerArmCFrame * armElbowAtt.CFrame -- CFrame of elbow att of the above hand
	local elbowRigBone = wristAttWorldCFrame.Position - elbowAttWorldCFrame.Position

	-- Next, we ignore translations in the Z because the valid arm configurations (I, A, T) are rotations along this axis.
	--      If for whatever reason they had the model pointing at you, we don't want that shift in Z to mean a gun points to the side. The gun still faces forward (import assumption)
	-- We also ignore negative x shifts, because this shouldn't be supported and flips the grip rotation. I found some examples of small negative values in I pose, so we treat it as 0.
	--      For left handed grips, we ignore positive shifts instead, and need to rotate the other way so we dont end up backwards
	local multiple = assetTypeEnum == Enum.AssetType.RightArm and 1 or -1
	elbowRigBone = Vector3.new(math.max(0, elbowRigBone.X * multiple) * multiple, elbowRigBone.Y, 0)
	local finalRotation = CFrame.new(Vector3.zero, elbowRigBone).Rotation
		* CFrame.fromEulerAnglesXYZ(0, 0, math.pi / 2 * multiple)
	local finalCFrame = CFrame.new(gripAtt.CFrame.Position) * finalRotation

	return gripAtt, finalCFrame
end

function ValidateBodyPartChildAttachmentOrientations.runValidation(
	inst: Instance,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	assert(getFFlagRefactorBodyAttachmentOrientationsCheck())
	local reasonsAccumulator = FailureReasonsAccumulator.new()

	-- Two validations: Rig attachments must be (0,0,0), and grip attachments must be perpendicular to the bone
	-- Assumes schema already validated, and we can search directly for the attachments
	for _, desc: Attachment in inst:GetDescendants() do
		local rigAttSuffix = "RigAttachment"
		local isRigAttachment = desc.ClassName == "Attachment"
			and string.sub(desc.Name, -string.len(rigAttSuffix)) == rigAttSuffix

		if isRigAttachment then
			local x, y, z = desc.CFrame:ToOrientation()
			if not floatEquals(x, 0) or not floatEquals(y, 0) or not floatEquals(z, 0) then
				Analytics.reportFailure(
					Analytics.ErrorType.validateBodyPartChildAttachmentOrientations_RotatedRig,
					nil,
					validationContext
				)
				reasonsAccumulator:updateReasons(false, {
					string.format(
						"Rig attachments cannot be rotated, please set %s's orientation to (0,0,0)",
						desc:GetFullName()
					),
				})
			end
		end
	end

	if
		validationContext.assetTypeEnum == Enum.AssetType.RightArm
		or validationContext.assetTypeEnum == Enum.AssetType.LeftArm
	then
		assert(validationContext.assetTypeEnum) -- nonsensical assert given the if statement above, but required for static analysis
		local gripAtt: Attachment, expectedCFrame: CFrame =
			ValidateBodyPartChildAttachmentOrientations.expectedGripAttCFrame(inst, validationContext.assetTypeEnum)

		if
			getDiffBetweenOrientations(expectedCFrame, gripAtt.CFrame)
			> getFIntUGCValidationGripAttOrientationThreshold()
		then
			Analytics.reportFailure(
				Analytics.ErrorType.validateBodyPartChildAttachmentOrientations_RotatedGrip,
				nil,
				validationContext
			)

			local expectedOrientation = Vector3.new(expectedCFrame:ToOrientation())
			expectedOrientation = Vector3.new(
				math.deg(expectedOrientation.X),
				math.deg(expectedOrientation.Y),
				math.deg(expectedOrientation.Z)
			)

			reasonsAccumulator:updateReasons(false, {
				string.format(
					"Attachment %s's orientation deviates too far from how the arm is rotated, which will make tools look unaligned. Recommended orientation is %s",
					gripAtt:GetFullName(),
					valueToString(expectedOrientation)
				),
			})
		end
	end

	return reasonsAccumulator:getFinalResults()
end

return ValidateBodyPartChildAttachmentOrientations
