local UGCValidationService = game:GetService("UGCValidationService")

local root = script.Parent.Parent

local Types = require(root.util.Types)
local pcallDeferred = require(root.util.pcallDeferred)

local Analytics = require(root.Analytics)
local Constants = require(root.Constants)

local getFFlagUGCLCQualityReplaceLua = require(root.flags.getFFlagUGCLCQualityReplaceLua)
local getFFlagUGCValidateBodyPartsExtendedMeshTests = require(root.flags.getFFlagUGCValidateBodyPartsExtendedMeshTests)

-- ensures accessory mesh does not have more triangles than Constants.MAX_HAT_TRIANGLES
local function validateMeshTriangles(
	meshInfo: Types.MeshInfo,
	maxTriangles: number?,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local isServer = validationContext.isServer

	if getFFlagUGCLCQualityReplaceLua() and getFFlagUGCValidateBodyPartsExtendedMeshTests() then
		local success, result = pcallDeferred(function()
			return UGCValidationService:ValidateEditableMeshTriangles(meshInfo.editableMesh)
		end, validationContext)

		if not success then
			Analytics.reportFailure(Analytics.ErrorType.validateMeshTriangles_FailedToExecute, nil, validationContext)
			if nil ~= isServer and isServer then
				-- there could be many reasons that an error occurred, the asset is not necessarilly incorrect, we just didn't get as
				-- far as testing it, so we throw an error which means the RCC will try testing the asset again, rather than returning false
				-- which would mean the asset failed validation
				error("Failed to execute validateMeshTriangles check")
			end
			return false, { "Failed to execute validateMeshTriangles check" }
		end

		if not result then
			Analytics.reportFailure(Analytics.ErrorType.validateMeshTriangles_TooManyTriangles, nil, validationContext)
			return false, { "Your mesh exceeds the max triangle limit for UGC upload requirements." }
		end
	else
		local success, triangles = pcallDeferred(function()
			return UGCValidationService:GetEditableMeshTriCount(meshInfo.editableMesh)
		end, validationContext)

		maxTriangles = if nil ~= maxTriangles then maxTriangles else Constants.MAX_HAT_TRIANGLES
		if not success then
			Analytics.reportFailure(Analytics.ErrorType.validateMeshTriangles_FailedToLoadMesh, nil, validationContext)
			if nil ~= isServer and isServer then
				-- there could be many reasons that an error occurred, the asset is not necessarilly incorrect, we just didn't get as
				-- far as testing it, so we throw an error which means the RCC will try testing the asset again, rather than returning false
				-- which would mean the asset failed validation
				error(
					string.format(
						"Failed to load model mesh %s. Make sure the mesh exists and try again.",
						meshInfo.fullName
					)
				)
			end
			return false,
				{
					string.format(
						"Failed to load model mesh %s. Make sure the mesh exists and try again.",
						meshInfo.fullName
					),
				}
		elseif triangles > maxTriangles :: number then
			Analytics.reportFailure(Analytics.ErrorType.validateMeshTriangles_TooManyTriangles, nil, validationContext)
			return false,
				{
					string.format(
						"Model mesh %s resolution of %d is higher than max support value of %d. You need to retopologize your model and try again.",
						meshInfo.fullName,
						triangles,
						maxTriangles :: number
					),
				}
		end
	end

	return true
end

return validateMeshTriangles
