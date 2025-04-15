local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local React = require(Packages.React)
local Dash = require(Packages.Dash)

local Chip = require(Foundation.Components.Chip)
local IconPosition = require(Foundation.Enums.IconPosition)

local Flags = require(Foundation.Utility.Flags)

local function Story(props)
	return React.createElement(Chip, {
		icon = props.icon,
		text = props.text,
		onActivated = props.onActivated,
		isDisabled = props.isDisabled,
		isChecked = props.isChecked,
	})
end

return {
	summary = "Chip",
	story = function(props)
		Flags.FoundationFixChipEmphasisHoverState = props.controls.fixEmphasisHoverState

		return Story({
			icon = if props.controls.icon ~= ""
				then {
					name = props.controls.icon,
					position = props.controls.iconPosition,
				}
				else nil,
			text = props.controls.text,
			onActivated = function()
				print(`Chip activated`)
			end,
			isDisabled = props.controls.isDisabled,
			isChecked = props.controls.isChecked,
		})
	end,
	controls = {
		fixEmphasisHoverState = Flags.FoundationFixChipEmphasisHoverState,
		icon = {
			"icons/actions/filter",
			"icons/common/robux",
			"icons/common/play",
			"",
		},
		iconPosition = Dash.values(IconPosition),
		text = "Filter",
		isDisabled = false,
		isChecked = false,
	},
}
