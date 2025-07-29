local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local React = require(Packages.React)
local Dash = require(Packages.Dash)

local View = require(Foundation.Components.View)
local IconButton = require(Foundation.Components.IconButton)
local IconSize = require(Foundation.Enums.IconSize)
type IconSize = IconSize.IconSize

local Flags = require(Foundation.Utility.Flags)

local function Story(props)
	local controls = props.controls

	return React.createElement(IconButton, {
		isDisabled = false,
		onActivated = function() end,
		size = controls.size,
		icon = controls.name,
		isCircular = controls.isCircular,
	})
end

local iconSizes = { IconSize.Small, IconSize.Medium, IconSize.Large, IconSize.XLarge, IconSize.XXLarge } :: { IconSize }

return {
	summary = "Icon component for displaying icons",
	story = function(props)
		Flags.FoundationUpdateIconButtonSizes = props.controls.updateIconButtonSizes

		return React.createElement(
			View,
			{ tag = "row gap-medium auto-y size-full-0 align-y-center" },
			Dash.map(iconSizes, function(size)
				return Story({
					controls = {
						size = size,
						name = props.controls.name,
						isCircular = props.controls.isCircular,
					},
				})
			end)
		)
	end,
	controls = {
		name = {
			"icons/common/notificationOff",
			"icons/common/robux",
			"icons/common/search_small",
			"icons/controls/voice/microphone_off_light",
			"icons/controls/voice/video_on_light",
		},
		isCircular = false,
		updateIconButtonSizes = Flags.FoundationUpdateIconButtonSizes,
	},
}
