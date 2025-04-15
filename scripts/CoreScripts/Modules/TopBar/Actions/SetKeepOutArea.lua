local CorePackages = game:GetService("CorePackages")

local Action = require(CorePackages.Packages.Rodux).makeActionCreator

return Action(script.Name, function(id, position, size)
	return {
		id = id,
		position = position,
		size = size,
	}
end)
