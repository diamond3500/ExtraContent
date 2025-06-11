local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local React = require(Packages.React)
local Dash = require(Packages.Dash)
local BuilderIcons = require(Packages.BuilderIcons)

local IconButton = require(Foundation.Components.IconButton)
local IconSize = require(Foundation.Enums.IconSize)
type IconSize = IconSize.IconSize

local function Story(props)
	local controls = props.controls

	return React.createElement(IconButton, {
		isDisabled = false,
		onActivated = function() end,
		size = controls.size,
		icon = {
			name = controls.name,
			variant = controls.variant,
		},
	})
end

local iconSizes = { IconSize.Large, IconSize.XSmall, IconSize.Small, IconSize.Medium } :: { IconSize }

return {
	summary = "Icon component for displaying icons",
	stories = Dash.map(iconSizes, function(size: IconSize)
		return {
			name = size,
			story = function(props)
				return Story({
					controls = {
						size = size,
						name = props.controls.name,
						variant = props.controls.variant,
					},
				})
			end,
		}
	end),
	controls = {
		name = Dash.values(BuilderIcons.Icon),
		variant = Dash.values(BuilderIcons.IconVariant),
	},
}
