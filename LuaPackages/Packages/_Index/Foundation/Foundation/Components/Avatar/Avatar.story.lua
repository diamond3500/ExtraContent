local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local React = require(Packages.React)
local Dash = require(Packages.Dash)

local Avatar = require(Foundation.Components.Avatar)
local View = require(Foundation.Components.View)
local UserPresence = require(Foundation.Enums.UserPresence)
local InputSize = require(Foundation.Enums.InputSize)

local useTokens = require(Foundation.Providers.Style.useTokens)

return {
	summary = "Avatar",
	stories = {
		{
			name = "Base",
			story = function(props)
				local tokens = useTokens()
				return React.createElement(
					View,
					{ tag = "auto-xy col gap-xxlarge" },
					Dash.map(UserPresence, function(userPresence)
						return React.createElement(
							View,
							{ tag = "auto-xy row gap-xxlarge" },
							Dash.map(InputSize, function(size)
								return React.createElement(Avatar, {
									userId = 24813339,
									key = size,
									userPresence = userPresence,
									size = size,
									background = tokens.Color.Shift.Shift_200,
								})
							end)
						)
					end)
				)
			end,
		},
	},
	controls = {
		userPresence = Dash.values(UserPresence),
	},
}
