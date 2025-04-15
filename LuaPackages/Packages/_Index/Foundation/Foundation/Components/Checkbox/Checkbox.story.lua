local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local React = require(Packages.React)
local Dash = require(Packages.Dash)

local Checkbox = require(Foundation.Components.Checkbox)
local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

local function Story(props)
	local controls = props.controls
	local isChecked, setIsChecked = React.useState(false)

	return React.createElement(Checkbox, {
		isChecked = isChecked,
		isDisabled = controls.isDisabled,
		onActivated = function()
			setIsChecked(not isChecked)
		end,
		size = controls.size,
		label = controls.label or "",
	})
end

return {
	summary = "Checkbox component",
	story = Story,
	controls = {
		isDisabled = false,
		label = "Label",
		size = Dash.values(InputSize),
	},
}
