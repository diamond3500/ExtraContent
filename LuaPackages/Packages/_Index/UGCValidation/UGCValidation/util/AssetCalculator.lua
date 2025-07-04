--[[
calculatePartCFrameFromRigAttachments
	calculates a cframe where the y axis is from the parts rig attachment to parent to the parts rig attachment to child
calculateStraightenedLimb
	calculates the part cframes after straightning the limb at the elbow/knee
calculateAssetCFrame:
	calculate the cframe for the asset, where the y vector of the matrix for the asset is calculated from the top to the bottom of the asset
calculateAllTransformsForAsset:
	calculate the cframes for all parts of the asset
calculateAllTransformsForFullBody:
	calculate the cframes for all parts of the full body
calculatePartsLocalToAsset:
	calculate the cframes for the upper part, lower part, and hand/foot in the local space of the asset cframe
]]

local root = script.Parent.Parent
local Cryo = require(root.Parent.Cryo)

local ConstantsInterface = require(root.ConstantsInterface)

local Types = require(root.util.Types)
local canBeNormalized = require(root.util.canBeNormalized)
local getPartNamesInHierarchyOrder = require(root.util.getPartNamesInHierarchyOrder)
local AssetTraversalUtils = require(root.util.AssetTraversalUtils)

local fullBodyAssetHierarchy = {
	root = "LowerTorso",
	children = {
		UpperTorso = {
			children = {
				Head = AssetTraversalUtils.assetHierarchy[Enum.AssetType.DynamicHead],
				LeftUpperArm = AssetTraversalUtils.assetHierarchy[Enum.AssetType.LeftArm],
				RightUpperArm = AssetTraversalUtils.assetHierarchy[Enum.AssetType.RightArm],
			},
		},
		LeftUpperLeg = AssetTraversalUtils.assetHierarchy[Enum.AssetType.LeftLeg],
		RightUpperLeg = AssetTraversalUtils.assetHierarchy[Enum.AssetType.RightLeg],
	},
}

local AssetCalculator = {}

local function calculateCFrame(top: Vector3, bottom: Vector3): CFrame?
	local yVector = top - bottom

	if not canBeNormalized(yVector) then
		return -- error, top and bottom are in the same location
	end

	yVector = yVector.Unit

	local xVector = yVector:Cross(Vector3.zAxis).Unit
	if not canBeNormalized(xVector) then -- yVector is pointing along the world z axis
		local crossWith = if yVector.Z < 0 then Vector3.yAxis else -Vector3.yAxis
		xVector = yVector:Cross(crossWith).Unit
	end
	local zVector = xVector:Cross(yVector).Unit

	return CFrame.fromMatrix(top, xVector, yVector, zVector)
end

local function calculatePartTransformInHierarchy(
	meshHandle: MeshPart,
	parentName: string?,
	parentCFrame: CFrame,
	findMeshHandle: (string) -> MeshPart
)
	local cframe = parentCFrame
	if parentName then
		local parentMeshHandle = findMeshHandle(parentName :: string)
		assert(parentMeshHandle)

		local rigAttachmentName = ConstantsInterface.getRigAttachmentToParent(nil, meshHandle.Name)
		local parentAttachment: Attachment? = parentMeshHandle:FindFirstChild(rigAttachmentName) :: Attachment
		assert(parentAttachment)
		local attachment: Attachment? = meshHandle:FindFirstChild(rigAttachmentName) :: Attachment
		assert(attachment)

		cframe = (cframe * (parentAttachment :: Attachment).CFrame) * (attachment :: Attachment).CFrame:Inverse()
	else
		cframe = CFrame.new()
	end
	return cframe
end

local function calculateHierarchyTransforms(mainDetails: any, findMeshHandle: (string) -> MeshPart): { string: CFrame }
	local results = {}

	local function calculateAllTransformsInternal(name: string, parentName: string?, details: any, parentCFrame: CFrame)
		local meshHandle = findMeshHandle(name)
		assert(meshHandle)

		local cframe = calculatePartTransformInHierarchy(meshHandle, parentName, parentCFrame, findMeshHandle)
		results[meshHandle.Name] = cframe

		if not details.children then
			return
		end
		for childName, childDetails in details.children do
			calculateAllTransformsInternal(childName, name, childDetails, cframe)
		end
	end

	calculateAllTransformsInternal(mainDetails.root, nil, mainDetails, CFrame.new())
	return results
end

-- return 'to' in the local space of 'from'
local function calculateLocalSpaceTransform(from: CFrame, to: CFrame): CFrame
	local toInLocalRotationSpaceOfFrom = from.Rotation:Inverse() * to.Rotation
	local toInLocalPositionSpaceOfFrom = from.Rotation:Inverse() * (to.Position - from.Position)

	return CFrame.new(toInLocalPositionSpaceOfFrom) * toInLocalRotationSpaceOfFrom
end

local function calculateAssetCFrameFromPartsCFrames(
	singleAsset: Enum.AssetType,
	partsCFrames: { string: CFrame }
): CFrame?
	local partNamesHierarchyOrder = getPartNamesInHierarchyOrder(singleAsset)
	local top = partsCFrames[partNamesHierarchyOrder[1]].Position
	local bottom = partsCFrames[partNamesHierarchyOrder[3]].Position

	return calculateCFrame(top, bottom)
end

local function assertTypesToOrient(singleAsset: Enum.AssetType)
	assert(
		singleAsset == Enum.AssetType.LeftArm
			or singleAsset == Enum.AssetType.RightArm
			or singleAsset == Enum.AssetType.LeftLeg
			or singleAsset == Enum.AssetType.RightLeg
	)
end

local function getAttachmentCFrame(part: MeshPart, rigAttachmentName: string, transform: CFrame): CFrame
	local rigAttachment: Attachment? = part:FindFirstChild(rigAttachmentName) :: Attachment
	assert(rigAttachment)
	return transform * rigAttachment.CFrame
end

function AssetCalculator.calculatePartCFrameFromRigAttachments(
	singleAsset: Enum.AssetType,
	part: MeshPart,
	transform: CFrame
): CFrame?
	assertTypesToOrient(singleAsset)

	local attachmentToRigParentName = ConstantsInterface.getRigAttachmentToParent(singleAsset, part.Name)
	if attachmentToRigParentName == "" then
		return
	end
	local attachmentToRigParentCFrame = getAttachmentCFrame(part, attachmentToRigParentName, transform)

	local rigChildPartName = AssetTraversalUtils.getAssetRigChild(singleAsset, part.Name)
	if not rigChildPartName then
		return
	end
	local attachmentToRigChildName =
		ConstantsInterface.getRigAttachmentToParent(singleAsset, rigChildPartName :: string)
	local attachmentToRigChildCFrame = getAttachmentCFrame(part, attachmentToRigChildName, transform)

	return calculateCFrame(attachmentToRigParentCFrame.Position, attachmentToRigChildCFrame.Position)
end

function AssetCalculator.calculateStraightenedLimb(
	singleAsset: Enum.AssetType,
	partsCFrames: { string: CFrame },
	findMeshHandle: (string) -> MeshPart
): { string: CFrame }
	assertTypesToOrient(singleAsset)

	local result = Cryo.Dictionary.join(partsCFrames) -- make a copy

	local rigParentAttachmentPos: Vector3?
	local rigParentSpaceCFrame = CFrame.new()
	for _, partName in getPartNamesInHierarchyOrder(singleAsset) do
		local part = findMeshHandle(partName)

		-- partSpaceCFrame is initialized with the rig parent's value, but will get recalculated if the part is not at the end of the hierarchy
		local partSpaceCFrame = rigParentSpaceCFrame
		local rigChildPartName = AssetTraversalUtils.getAssetRigChild(singleAsset, partName)

		local isEndOfHierarchy = rigChildPartName == nil
		if not isEndOfHierarchy then -- calculations which require a next in the hierarchy are only done for parts not at the end of the hierarchy
			-- partSpaceCFrame is calculated from the diff between the parts's attachment to rig parent and rig child (or fails if they are in the same place)
			partSpaceCFrame = AssetCalculator.calculatePartCFrameFromRigAttachments(
				singleAsset,
				part,
				partsCFrames[partName]
			) or partSpaceCFrame
		end

		-- updating orientation of the part
		result[partName] = calculateLocalSpaceTransform(partSpaceCFrame :: CFrame, partsCFrames[partName])

		if rigParentAttachmentPos then -- fixing up the position of the part
			local updatedAttachmentToRigParentCFrame = getAttachmentCFrame(
				part,
				ConstantsInterface.getRigAttachmentToParent(singleAsset, partName),
				result[partName]
			)
			local posFix = rigParentAttachmentPos - updatedAttachmentToRigParentCFrame.Position
			result[partName] = CFrame.new(result[partName].Position + posFix) * result[partName].Rotation
		end

		if not isEndOfHierarchy then -- set the variables needed by the next part down in the hierarchy
			rigParentSpaceCFrame = partSpaceCFrame -- will be used by the end of hierarchy part, or any part where the attachments are in the same place
			rigParentAttachmentPos = getAttachmentCFrame(
				part,
				ConstantsInterface.getRigAttachmentToParent(singleAsset, rigChildPartName :: string) :: string,
				result[partName]
			).Position
		end
	end
	return result
end

function AssetCalculator.calculateAssetCFrame(singleAsset: Enum.AssetType, inst: Instance): CFrame?
	local partsCFrames = AssetCalculator.calculateAllTransformsForAsset(singleAsset, inst)
	if Enum.AssetType.DynamicHead == singleAsset then
		return partsCFrames["Head"]
	elseif Enum.AssetType.Torso == singleAsset then
		return partsCFrames["LowerTorso"]
	end

	return calculateAssetCFrameFromPartsCFrames(singleAsset, partsCFrames)
end

function AssetCalculator.calculateAllTransformsForAsset(singleAsset: Enum.AssetType, inst: Instance): { string: CFrame }
	if Enum.AssetType.DynamicHead == singleAsset then
		return { ["Head" :: string] = CFrame.new() }
	end

	local function findMeshHandle(name: string): MeshPart
		return inst:FindFirstChild(name) :: MeshPart
	end

	return calculateHierarchyTransforms(AssetTraversalUtils.assetHierarchy[singleAsset], findMeshHandle)
end

function AssetCalculator.calculateAllTransformsForFullBody(fullBodyAssets: Types.AllBodyParts): { string: CFrame }
	local function findMeshHandle(name: string): MeshPart
		return fullBodyAssets[name] :: MeshPart
	end

	return calculateHierarchyTransforms(fullBodyAssetHierarchy, findMeshHandle)
end

function AssetCalculator.calculatePartsLocalToAsset(
	singleAsset: Enum.AssetType,
	partsCFrames: { string: CFrame }
): { string: CFrame }
	assert(
		singleAsset == Enum.AssetType.LeftArm
			or singleAsset == Enum.AssetType.RightArm
			or singleAsset == Enum.AssetType.LeftLeg
			or singleAsset == Enum.AssetType.RightLeg
	)

	local assetCFrameOpt = calculateAssetCFrameFromPartsCFrames(singleAsset, partsCFrames)
	local result = {}
	for _, partName in getPartNamesInHierarchyOrder(singleAsset) do
		result[partName] = if assetCFrameOpt
			then calculateLocalSpaceTransform(assetCFrameOpt :: CFrame, partsCFrames[partName])
			else partsCFrames[partName]
	end
	return result
end

return AssetCalculator
