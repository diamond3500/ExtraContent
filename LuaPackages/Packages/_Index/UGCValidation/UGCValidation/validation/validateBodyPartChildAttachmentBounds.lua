--!strict

local root = script.Parent.Parent

local Types = require(root.util.Types)
local Analytics = require(root.Analytics)
local Constants = require(root.Constants)

local FailureReasonsAccumulator = require(root.util.FailureReasonsAccumulator)
local prettyPrintVector3 = require(root.util.prettyPrintVector3)
local floatEquals = require(root.util.floatEquals)
local getDiffBetweenOrientations = require(root.util.getDiffBetweenOrientations)
local getExpectedPartSize = require(root.util.getExpectedPartSize)
local BoundsCalculator = require(root.util.BoundsCalculator)
local AssetCalculator = require(root.util.AssetCalculator)
local BoundsDataUtils = require(root.util.BoundsDataUtils)
local MeshSpaceUtils = require(root.util.MeshSpaceUtils)

local ANGLE_EPSILON = 0.01

local getFFlagCheckOrientationOnAllAttachments = require(root.flags.getFFlagCheckOrientationOnAllAttachments)
local getFFlagUGCValidateOrientedAttachmentPositionCheck =
	require(root.flags.getFFlagUGCValidateOrientedAttachmentPositionCheck)
local getFFlagUGCValidateOrientedAttachmentOrientationCheck =
	require(root.flags.getFFlagUGCValidateOrientedAttachmentOrientationCheck)
local getFFlagUGCValidatePreciseAttachmentErrorMessage =
	require(root.flags.getFFlagUGCValidatePreciseAttachmentErrorMessage)
local getFStringUGCValidationAttachmentErrorLink = require(root.flags.getFStringUGCValidationAttachmentErrorLink)

local maxOrientationOffsets = {
	["RootAttachment"] = game:DefineFastInt("UGCValidationRootAttachmentThreshold", 0),
	["LeftGripAttachment"] = game:DefineFastInt("UGCValidationLeftGripAttachmentThreshold", 0),
	["RightGripAttachment"] = game:DefineFastInt("UGCValidationRightGripAttachmentThreshold", 0),
	["FaceFrontAttachment"] = game:DefineFastInt("UGCValidationFaceFrontAttachmentThreshold", 90),
	["HatAttachment"] = game:DefineFastInt("UGCValidationHatAttachmentThreshold", 90),
	["HairAttachment"] = game:DefineFastInt("UGCValidationHairAttachmentThreshold", 90),
	["FaceCenterAttachment"] = game:DefineFastInt("UGCValidationFaceCenterAttachmentThreshold", 90),
	["RightFootAttachment"] = game:DefineFastInt("UGCValidationRightFootAttachmentThreshold", 90),
	["LeftFootAttachment"] = game:DefineFastInt("UGCValidationLeftFootAttachmentThreshold", 90),
	["BodyFrontAttachment"] = game:DefineFastInt("UGCValidationBodyFrontAttachmentThreshold", 90),
	["BodyBackAttachment"] = game:DefineFastInt("UGCValidationBodyBackAttachmentThreshold", 90),
	["LeftCollarAttachment"] = game:DefineFastInt("UGCValidationLeftCollarAttachmentThreshold", 90),
	["RightCollarAttachment"] = game:DefineFastInt("UGCValidationRightCollarAttachmentThreshold", 90),
	["NeckAttachment"] = game:DefineFastInt("UGCValidationNeckAttachmentThreshold", 90),
	["WaistCenterAttachment"] = game:DefineFastInt("UGCValidationWaistCenterAttachmentThreshold", 90),
	["WaistFrontAttachment"] = game:DefineFastInt("UGCValidationWaistFrontAttachmentThreshold", 90),
	["WaistBackAttachment"] = game:DefineFastInt("UGCValidationWaistBackAttachmentThreshold", 90),
	["LeftShoulderAttachment"] = game:DefineFastInt("UGCValidationLeftShoulderAttachmentThreshold", 90),
	["RightShoulderAttachment"] = game:DefineFastInt("UGCValidationRightShoulderAttachmentThreshold", 90),
}

-- this function relies on validateMeshIsAtOrigin() in validateDescendantMeshMetrics.lua to catch meshes not built at the origin
local function validateInMeshSpace(
	att: Attachment,
	part: MeshPart,
	boundsInfoMeshSpace: any,
	validationContext: Types.ValidationContext,
	transformData: any
): (boolean, { string }?)
	local posMeshSpace
	local meshHalfSize
	local meshCenterOpt
	local meshDimensionsOpt
	if getFFlagUGCValidateOrientedAttachmentPositionCheck() then
		local world = transformData.cframe * att.CFrame
		meshCenterOpt = BoundsDataUtils.calculateBoundsCenters(transformData.boundsData)
		meshDimensionsOpt = BoundsDataUtils.calculateBoundsDimensions(transformData.boundsData)
		if not meshCenterOpt or not meshDimensionsOpt then
			return false, { "Missing mesh data for " .. part.Name }
		end
		local attWorldOffset = (world.Position - (meshCenterOpt :: Vector3))
		meshHalfSize = (meshDimensionsOpt :: Vector3) / 2
		posMeshSpace = (attWorldOffset / meshHalfSize) :: any
	else
		meshHalfSize = getExpectedPartSize(part, validationContext) / 2

		posMeshSpace = (att.CFrame.Position / meshHalfSize) :: any
	end

	local minMeshSpace = boundsInfoMeshSpace.min
	local maxMeshSpace = boundsInfoMeshSpace.max
	for _, dimension in { "X", "Y", "Z" } do
		if
			posMeshSpace[dimension] < (minMeshSpace :: any)[dimension]
			or posMeshSpace[dimension] > (maxMeshSpace :: any)[dimension]
		then
			Analytics.reportFailure(
				Analytics.ErrorType.validateBodyPartChildAttachmentBounds_InvalidAttachmentPosition,
				nil,
				validationContext
			)

			local attachmentClampedCFrame = nil
			local acceptablePosition = nil
			local acceptableOrientation = nil
			local acceptableDimensions = nil
			if
				getFFlagUGCValidateOrientedAttachmentPositionCheck()
				and getFFlagUGCValidatePreciseAttachmentErrorMessage()
			then
				attachmentClampedCFrame =
					MeshSpaceUtils.clampAttachmentToBounds(att, transformData, boundsInfoMeshSpace, 0.001)

				assert(
					meshCenterOpt and meshDimensionsOpt,
					"meshCenterOpt and meshDimensionsOpt must be defined if getFFlagUGCValidateOrientedAttachmentPositionCheck() is true"
				)
				local acceptableCFrameLocal
				acceptableCFrameLocal, acceptableDimensions = MeshSpaceUtils.calculateAcceptableBoundsLocalSpace(
					boundsInfoMeshSpace,
					transformData,
					meshDimensionsOpt :: Vector3,
					meshCenterOpt :: Vector3
				)
				acceptablePosition = acceptableCFrameLocal.Position
				local acceptableOriX, acceptableOriY, acceptableOriZ = acceptableCFrameLocal.Rotation:ToOrientation()
				acceptableOrientation =
					Vector3.new(math.deg(acceptableOriX), math.deg(acceptableOriY), math.deg(acceptableOriZ))
			end

			return false,
				{
					if getFFlagUGCValidateOrientedAttachmentPositionCheck()
							and getFFlagUGCValidatePreciseAttachmentErrorMessage()
						then string.format(
							"Attachment (%s) in %s is placed at position [%s] that is outside the valid range. The closest valid position is [%s]. (the attachment must be within the oriented bounding box - Position: [%s], Orientation: [%s], Size: [%s]%s)",
							att.Name,
							part.Name,
							prettyPrintVector3(att.CFrame.Position, 3),
							prettyPrintVector3(attachmentClampedCFrame.Position, 3),
							prettyPrintVector3(acceptablePosition, 3),
							prettyPrintVector3(acceptableOrientation, 3),
							prettyPrintVector3(acceptableDimensions, 3),
							if getFStringUGCValidationAttachmentErrorLink() ~= ""
								then ". See " .. getFStringUGCValidationAttachmentErrorLink() .. " for further explanation"
								else ""
						)
						else string.format(
							"Attachment (%s) in %s is placed at a position [%s] that is outside the valid range. You need to adjust the attachment position.",
							att.Name,
							part.Name,
							prettyPrintVector3(att.CFrame.Position)
						),
				}
		end
	end
	return true
end

-- NOTE: All FindFirstChild() calls will succeed based on all expected parts being checked for existance before calling this function
local function checkAll(
	meshHandle: MeshPart,
	_isServer: boolean?,
	partData: any,
	validationContext: Types.ValidationContext,
	transformData: any
): (boolean, { string }?)
	local reasonsAccumulator = FailureReasonsAccumulator.new()

	local rigAttachmentToParent: Attachment? =
		meshHandle:FindFirstChild(partData.rigAttachmentToParent.name) :: Attachment
	assert(rigAttachmentToParent)

	reasonsAccumulator:updateReasons(
		validateInMeshSpace(
			rigAttachmentToParent :: Attachment,
			meshHandle,
			partData.rigAttachmentToParent.bounds,
			validationContext,
			transformData
		)
	)

	for childAttachmentName, childAttachmentInfo in pairs(partData.otherAttachments) do
		local childAttachment: Attachment? = meshHandle:FindFirstChild(childAttachmentName) :: Attachment
		assert(childAttachment)

		reasonsAccumulator:updateReasons(
			validateInMeshSpace(
				childAttachment :: Attachment,
				meshHandle,
				childAttachmentInfo.bounds,
				validationContext,
				transformData
			)
		)
	end
	return reasonsAccumulator:getFinalResults()
end

local function validateAttachmentRotation(
	inst: Instance,
	assetCFrame: CFrame,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local reasonsAccumulator = FailureReasonsAccumulator.new()

	for _, desc in inst:GetDescendants() do
		if getFFlagCheckOrientationOnAllAttachments() then
			local isAttachment = desc.ClassName == "Attachment"
			if not isAttachment then
				continue
			end

			local isRigAttachment = string.find(desc.Name, "RigAttachment")
			if isRigAttachment then
				local x, y, z = desc.CFrame:ToOrientation()
				if not floatEquals(x, 0) or not floatEquals(y, 0) or not floatEquals(z, 0) then
					Analytics.reportFailure(
						Analytics.ErrorType.validateBodyPartChildAttachmentBounds_AttachmentRotated,
						nil,
						validationContext
					)
					reasonsAccumulator:updateReasons(false, {
						string.format(
							"Detected rotation in Attachment '%s'. You must reset all rotation values for this attachment to zero.",
							desc:GetFullName()
						),
					})
				end
			elseif maxOrientationOffsets[desc.Name] ~= nil then
				local isGrip = string.find(desc.Name, "Grip") -- Left and Right arm grips have a unique orientation (-90, 0, 0)
				local requiredOrientation = isGrip and CFrame.Angles(math.rad(-90), 0, 0) or CFrame.Angles(0, 0, 0)

				if getFFlagUGCValidateOrientedAttachmentOrientationCheck() then
					requiredOrientation = assetCFrame.Rotation * requiredOrientation
				end

				local orientationOffset = getDiffBetweenOrientations(requiredOrientation, desc.CFrame)
				local maxOffset: number = maxOrientationOffsets[desc.Name]
				if orientationOffset > maxOffset + ANGLE_EPSILON then
					Analytics.reportFailure(
						Analytics.ErrorType.validateBodyPartChildAttachmentBounds_AttachmentRotated,
						nil,
						validationContext
					)

					local requiredOriAngles
					if getFFlagUGCValidateOrientedAttachmentOrientationCheck() then
						local x, y, z = requiredOrientation:ToOrientation()
						requiredOriAngles = Vector3.new(math.deg(x), math.deg(y), math.deg(z))
					end

					reasonsAccumulator:updateReasons(false, {
						string.format(
							"Detected invalid orientation for '%s'. Attachment orientation should be %s, but can be rotated up to %d degrees in total",
							desc.Name,
							prettyPrintVector3(
								if getFFlagUGCValidateOrientedAttachmentOrientationCheck()
									then requiredOriAngles
									else Vector3.new(isGrip and -90 or 0, 0, 0)
							),
							math.floor(maxOffset)
						),
					})
				end
			end
		else
			local isRigAttachment = desc.ClassName == "Attachment" and string.find(desc.Name, "RigAttachment")
			if not isRigAttachment then
				continue
			end

			local x, y, z = desc.CFrame:ToOrientation()
			if not floatEquals(x, 0) or not floatEquals(y, 0) or not floatEquals(z, 0) then
				Analytics.reportFailure(
					Analytics.ErrorType.validateBodyPartChildAttachmentBounds_AttachmentRotated,
					nil,
					validationContext
				)
				reasonsAccumulator:updateReasons(false, {
					string.format(
						"Detected rotation in Attachment '%s'. You must reset all rotation values for this attachment to zero.",
						desc:GetFullName()
					),
				})
			end
		end
	end

	return reasonsAccumulator:getFinalResults()
end

local function calculateAssetCFrame(singleAsset: Enum.AssetType, inst: Instance): (boolean, { string }?, CFrame?)
	local assetCFrameOpt = AssetCalculator.calculateAssetCFrame(singleAsset, inst)
	if not assetCFrameOpt then
		return false,
			{
				string.format(
					"Failed to calculate %s asset CFrame. Make sure the character is in I pose, A pose, or T pose, and the parts are not all in the same position",
					singleAsset.Name
				),
			}
	end
	return true, nil, assetCFrameOpt
end

local function validateBodyPartChildAttachmentBounds(
	inst: Instance,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local startTime = tick()

	local assetTypeEnum = validationContext.assetTypeEnum
	local isServer = validationContext.isServer
	assert(assetTypeEnum)

	local assetInfo = Constants.ASSET_TYPE_INFO[assetTypeEnum]
	assert(assetInfo)

	local reasonsAccumulator = FailureReasonsAccumulator.new()

	local assetCFrame = CFrame.new()
	if getFFlagUGCValidateOrientedAttachmentOrientationCheck() then
		local successCF, failureReasonsCF, assetCFrameOpt = calculateAssetCFrame(assetTypeEnum :: Enum.AssetType, inst)
		if not successCF then
			return successCF, failureReasonsCF
		end
		assetCFrame = assetCFrameOpt :: CFrame
	end

	reasonsAccumulator:updateReasons(validateAttachmentRotation(inst, assetCFrame, validationContext))

	local boundsTransformData
	if getFFlagUGCValidateOrientedAttachmentPositionCheck() then
		local successData, failureReasonsData, boundsTransformDataOpt =
			BoundsCalculator.calculateIndividualAssetPartsData(inst, validationContext)
		if not successData then
			return successData, failureReasonsData
		end
		boundsTransformData = boundsTransformDataOpt :: { string: any }
	end

	if Enum.AssetType.DynamicHead == assetTypeEnum then
		local boundsTransformDataForPart = if getFFlagUGCValidateOrientedAttachmentPositionCheck()
			then boundsTransformData[inst.Name]
			else nil
		reasonsAccumulator:updateReasons(
			checkAll(inst :: MeshPart, isServer, assetInfo.subParts.Head, validationContext, boundsTransformDataForPart)
		)
	else
		for subPartName, partData in pairs(assetInfo.subParts) do
			local meshHandle: MeshPart? = inst:FindFirstChild(subPartName) :: MeshPart
			assert(meshHandle)

			local boundsTransformDataForPart = if getFFlagUGCValidateOrientedAttachmentPositionCheck()
				then boundsTransformData[subPartName]
				else nil
			reasonsAccumulator:updateReasons(
				checkAll(meshHandle :: MeshPart, isServer, partData, validationContext, boundsTransformDataForPart)
			)
		end
	end

	Analytics.recordScriptTime(script.Name, startTime, validationContext)
	return reasonsAccumulator:getFinalResults()
end

return validateBodyPartChildAttachmentBounds
