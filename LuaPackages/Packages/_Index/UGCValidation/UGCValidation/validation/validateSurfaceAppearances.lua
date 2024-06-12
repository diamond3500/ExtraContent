--!strict

--[[
	validateSurfaceAppearances.lua checks that all MeshParts without a TextureID have a SurfaceAppearance child, and checks
	if a MeshPart has a TextureID it does not have a child SurfaceAppearance
]]

local root = script.Parent.Parent

local Analytics = require(root.Analytics)

local FailureReasonsAccumulator = require(root.util.FailureReasonsAccumulator)

local function validateSurfaceAppearances(instance: Instance): (boolean, { string }?)
	-- full tree of instance + descendants
	local allDescendants: { Instance } = instance:GetDescendants()
	table.insert(allDescendants, instance)

	local reasonsAccumulator = FailureReasonsAccumulator.new()

	for _, descendant in pairs(allDescendants) do
		if not descendant:IsA("MeshPart") then
			continue
		end

		local meshPartHasTexture = (descendant :: MeshPart).TextureID ~= ""
		local surfaceAppearance = descendant:FindFirstChildWhichIsA("SurfaceAppearance")

		if meshPartHasTexture then
			if surfaceAppearance then
				Analytics.reportFailure(Analytics.ErrorType.validateSurfaceAppearances_MeshPartHasTexture)
				reasonsAccumulator:updateReasons(false, {
					`TextureID and SurfaceAppearance are both defined for MeshPart ({(descendant :: Instance):GetFullName()}). Publishing will only use SurfaceApperance.`,
				})
			end
		elseif not surfaceAppearance then
			Analytics.reportFailure(Analytics.ErrorType.validateSurfaceAppearances_MissingSurfaceAppearance)
			reasonsAccumulator:updateReasons(false, {
				`({(descendant :: Instance):GetFullName()}) has an empty TextureID and no child SurfaceAppearance instance. You need to define at least one of them.`,
			})
		end
	end

	return reasonsAccumulator:getFinalResults()
end

return validateSurfaceAppearances
