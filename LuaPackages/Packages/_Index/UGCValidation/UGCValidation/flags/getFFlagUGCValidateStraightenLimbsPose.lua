--!strict

local root = script.Parent.Parent

local getFFlagUGCValidateStraightenLimbs = require(root.flags.getFFlagUGCValidateStraightenLimbs)

game:DefineFastFlag("UGCValidateStraightenLimbsPose", false)

return function()
	return getFFlagUGCValidateStraightenLimbs() and game:GetFastFlag("UGCValidateStraightenLimbsPose")
end
