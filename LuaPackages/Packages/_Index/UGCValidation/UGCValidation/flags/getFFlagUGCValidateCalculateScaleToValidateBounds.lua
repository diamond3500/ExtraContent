--!strict

local root = script.Parent.Parent

local getFFlagUGCValidateOrientedSizing = require(root.flags.getFFlagUGCValidateOrientedSizing)

game:DefineFastFlag("UGCValidateCalculateScaleToValidateBounds", false)

return function()
	return getFFlagUGCValidateOrientedSizing() and game:GetFastFlag("UGCValidateCalculateScaleToValidateBounds")
end
