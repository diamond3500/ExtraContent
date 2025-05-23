local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Packages.Roact)

local ContextActionsBinder = require(script.ContextActionsBinder)

local Connection = Roact.PureComponent:extend("Connection")

function Connection:render()
	return Roact.createFragment({
		ContextActionsBinder = Roact.createElement(ContextActionsBinder),
	})
end

return Connection
