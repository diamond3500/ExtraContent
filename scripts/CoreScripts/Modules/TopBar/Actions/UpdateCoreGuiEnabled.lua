local CorePackages = game:GetService("CorePackages")

local Action = require(CorePackages.Packages.Rodux).makeActionCreator

return Action(script.Name, function(coreGuiType, enabled)
	return {
		coreGuiType = coreGuiType,
		enabled = enabled,
	}
end)
