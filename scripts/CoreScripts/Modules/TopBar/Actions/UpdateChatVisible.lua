local CorePackages = game:GetService("CorePackages")

local Action = require(CorePackages.Packages.Rodux).makeActionCreator

return Action(script.Name, function(visible)
	return {
		visible = visible,
	}
end)
