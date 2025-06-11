local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local React = require(Packages.React)
local Dash = require(Packages.Dash)

local CheckedValueContext = require(script.Parent.Parent.CheckedValueContext)
local RadioGroup = require(Foundation.Components.RadioGroup)
local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

local function Story(props)
	local controls = props.controls
	local value, setValue = React.useState(nil)

	return React.createElement(CheckedValueContext.Provider, {
		value = { value = value, onValueChanged = setValue },
	}, {
		React.createElement(RadioGroup.Item, {
			value = controls.value,
			label = if #controls.label > 0 then `{controls.label} {controls.value}` else "",
			isDisabled = controls.isDisabled,
			size = controls.size,
		}),
	})
end

return {
	summary = "Checkbox component",
	story = Story,
	controls = {
		isDisabled = false,
		label = "Label",
		value = "A",
		size = Dash.values(InputSize),
	},
}
