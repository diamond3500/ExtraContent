--[[
	test to make sure that the render mesh is predominantly inside the cage mesh
]]

local UGCValidationService = game:GetService("UGCValidationService")

local root = script.Parent.Parent

local Analytics = require(root.Analytics)

local getFIntUGCValidateRenderMeshInsideOuterCageMeshThreshold =
	require(root.flags.getFIntUGCValidateRenderMeshInsideOuterCageMeshThreshold)
local getFFlagUGCValidationHyperlinksInCageQuality = require(root.flags.getFFlagUGCValidationHyperlinksInCageQuality)

local Types = require(root.util.Types)
local pcallDeferred = require(root.util.pcallDeferred)

local function validateRenderMeshInsideOuterCageMesh(
	wrapLayer: WrapLayer,
	meshInfoOuterCage: Types.MeshInfo,
	meshInfoRenderMesh: Types.MeshInfo,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local startTime = tick()

	-- below we transform the render mesh by the inverse of the cage origin which is because the C++ function cannot move the
	-- cage mesh, but it can move the render mesh, so moving the render mesh by the inverse of the cage mesh keeps the two meshes
	-- in the same relative positions to one and other
	local success, percentageInside = pcallDeferred(function()
		return (UGCValidationService :: any):CalculateEditableMeshInsideMeshPercentage(
			meshInfoOuterCage.editableMesh,
			meshInfoRenderMesh.editableMesh,
			wrapLayer.CageOrigin:Inverse(),
			Vector3.new(1, 1, 1)
		)
	end, validationContext)

	if not success then
		local errorString = string.format(
			"Failed to execute render mesh inside outer mesh check for '%s' and '%s'. Make sure the meshes exists and try again.",
			meshInfoOuterCage.fullName,
			meshInfoRenderMesh.fullName
		)
		if validationContext.isServer then
			-- there could be many reasons that an error occurred, the asset is not necessarilly incorrect, we just didn't get as
			-- far as testing it, so we throw an error which means the RCC will try testing the asset again, rather than returning false
			-- which would mean the asset failed validation
			error(errorString)
		end
		Analytics.reportFailure(
			Analytics.ErrorType.validateRenderMeshInsideOuterCageMesh_FailedToExecute,
			nil,
			validationContext
		)
		return false, { errorString }
	end

	percentageInside = percentageInside * 100
	if percentageInside < getFIntUGCValidateRenderMeshInsideOuterCageMeshThreshold() then
		Analytics.reportFailure(
			Analytics.ErrorType.validateRenderMeshInsideOuterCageMesh_MaxOutsideCageMeshExceeded,
			nil,
			validationContext
		)

		local errorString = string.format(
			"Validation detected %d%% of the accessory is outside its outer cage. Make adjustments to have more of the accessory placed between the cages",
			100 - math.floor(percentageInside)
		)

		if getFFlagUGCValidationHyperlinksInCageQuality() then
			errorString = errorString
				.. "[Read more](https://create.roblox.com/docs/art/validation-errors#cageInsideMesh)"
		end

		return false, { errorString }
	end

	Analytics.recordScriptTime(script.Name, startTime, validationContext)
	return true
end

return validateRenderMeshInsideOuterCageMesh
