--!strict

local root = script.Parent.Parent

local getFFlagUGCValidateStraightenLimbs = require(root.flags.getFFlagUGCValidateStraightenLimbs)

game:DefineFastFlag("UGCValidateStraightenLimbsTransparency2", false)

return function()
	return getFFlagUGCValidateStraightenLimbs() and game:GetFastFlag("UGCValidateStraightenLimbsTransparency2")
end
