local Chrome = script:FindFirstAncestor("Chrome")

local CorePackages = game:GetService("CorePackages")
local React = require(CorePackages.Packages.React)

local useChromeWindowItems = require(Chrome.Hooks.useChromeWindowItems)
local WindowHost = require(Chrome.Unibar.ComponentHosts.WindowHost)

type Array<T> = { [number]: T }
type Table = { [any]: any }

return function(props)
	-- Tree of window items to display
	local windowItems = useChromeWindowItems()

	local children: Table = {} -- Windows to be rendered

	for k, item in windowItems do
		children[("window_" .. item.integration.id)] = React.createElement(WindowHost, {
			position = item.integration.startingWindowPosition,
			integration = item,
		})
	end

	return children
end
