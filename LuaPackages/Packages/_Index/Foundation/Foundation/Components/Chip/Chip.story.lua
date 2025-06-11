local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local React = require(Packages.React)
local Dash = require(Packages.Dash)

local ChipSize = require(Foundation.Enums.ChipSize)
local IconPosition = require(Foundation.Enums.IconPosition)
local View = require(Foundation.Components.View)

local Chip = require(Foundation.Components.Chip.Chip)

local function Story(props)
	return React.createElement(Chip, {
		leading = if #props.leading > 0 or type(props.leading) == "table" then props.leading else nil,
		trailing = if #props.trailing > 0 or type(props.trailing) == "table" then props.trailing else nil,
		text = props.text,
		onActivated = props.onActivated,
		isChecked = props.isChecked,
		size = props.size,
	})
end

return {
	summary = "Chip",
	stories = {
		{
			name = "Basic",
			story = function(props)
				return Story({
					text = props.controls.text,
					onActivated = function()
						print(`Chip activated`)
					end,
					leading = props.controls.leading,
					trailing = props.controls.trailing,
					isChecked = props.controls.isChecked,
					size = props.controls.size,
					chipDesignUpdate = props.controls.chipDesignUpdate,
				})
			end,
		} :: unknown,
		{
			name = "Sizes",
			story = function(props)
				return React.createElement(
					View,
					{ tag = "auto-xy row gap-xlarge" },
					Dash.map(ChipSize, function(value, key)
						return React.createElement(Story, {
							key = key,
							text = props.controls.text,
							onActivated = function()
								print(`Chip activated`)
							end,
							leading = props.controls.leading,
							trailing = props.controls.trailing,
							isChecked = props.controls.isChecked,
							size = value,
							chipDesignUpdate = props.controls.chipDesignUpdate,
						})
					end)
				)
			end,
		},
		{
			name = "Back compatibility for chipDesignUpdate",
			story = function(props)
				return React.createElement(
					View,
					{ tag = "auto-xy row gap-xlarge" },
					React.createElement(Chip, {
						icon = "icons/common/robux",
						text = props.controls.text,
						onActivated = function()
							print(`Chip activated`)
						end,
						isChecked = props.controls.isChecked,
						-- Is just ignored
						isDisabled = true,
					}),
					React.createElement(Chip, {
						icon = {
							name = "icons/common/robux",
							position = IconPosition.Right,
						},
						text = props.controls.text,
						onActivated = function()
							print(`Chip activated`)
						end,
						isChecked = props.controls.isChecked,
					})
				)
			end,
		},
	},
	controls = {
		leading = {
			"icons/actions/filter" :: any,
			"icons/common/robux",
			"icons/common/play",
			{
				iconName = "icons/actions/selectOn",
				onActivated = function()
					print("I've been clicked")
				end,
				isCircular = true,
			},
			"",
		},
		trailing = {
			"icons/actions/filter" :: any,
			"icons/common/robux",
			"icons/common/play",
			"icons/status/success_small",
			{
				iconName = "icons/actions/selectOn",
				onActivated = function()
					print("I've been clicked")
				end,
				isCircular = true,
			},
			"",
		},
		size = Dash.values(ChipSize),
		text = "Filter",
		isChecked = false,
	},
}
