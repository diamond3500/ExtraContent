local CorePackages = game:GetService("CorePackages")

local Action = require(CorePackages.Packages.Rodux).makeActionCreator

return Action(script.Name, function(name, description)
	return {
		name = name,
		description = description,
	}
end)
