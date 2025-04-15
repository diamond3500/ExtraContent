--!strict

local root = script.Parent.Parent

local getFFlagUGCValidateConfigurableFullBodyBounds = require(root.flags.getFFlagUGCValidateConfigurableFullBodyBounds)

return function()
	return getFFlagUGCValidateConfigurableFullBodyBounds()
		and game:GetEngineFeature("EngineUGCValidateFullBodyBoundsAvatarRules")
end
