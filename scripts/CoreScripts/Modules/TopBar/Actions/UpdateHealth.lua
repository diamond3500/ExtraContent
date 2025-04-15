local CorePackages = game:GetService("CorePackages")

local Action = require(CorePackages.Packages.Rodux).makeActionCreator

return Action(script.Name, function(health, maxHealth)
	return {
		health = health,
		maxHealth = maxHealth,
	}
end)
