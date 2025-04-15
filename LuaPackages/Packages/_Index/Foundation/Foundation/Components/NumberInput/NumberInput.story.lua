local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local React = require(Packages.React)
local Dash = require(Packages.Dash)

local InputSize = require(Foundation.Enums.InputSize)

local NumberInput = require(Foundation.Components.NumberInput)

local function DefaultStory(props)
	local controls = props.controls

	local value, setValue = React.useState(0)

	local function handleChange(newValue: number)
		print("newValue", newValue)
		setValue(newValue)
	end

	return React.createElement(NumberInput, {
		value = value,
		hasError = controls.hasError,
		isDisabled = controls.isDisabled,
		isRequired = controls.isRequired,
		onChanged = handleChange,
		formatAsString = function(value)
			return `{value}px`
		end,
		label = controls.label,
		size = controls.size,
		width = UDim.new(0, 100),
		maximum = controls.maximum,
		minimum = controls.minimum,
		step = controls.step,
		hint = controls.hint,
		precision = controls.precision,
	})
end

local function DisabledStory(props)
	local value, setValue = React.useState(0)

	local function handleChange(newValue: number)
		print("newValue", newValue)
		setValue(newValue)
	end

	return React.createElement(NumberInput, {
		value = value,
		isDisabled = true,
		onChanged = handleChange,
		formatAsString = function(value)
			return `{value}px`
		end,
		label = "",
		width = UDim.new(0, 100),
	})
end

return {
	summary = "Spinbox",
	stories = {
		{ name = "Default", story = DefaultStory :: any },
		{ name = "Disabled", story = DisabledStory },
	},
	controls = {
		label = "Label",
		hint = "Number from -5 to 100",
		isRequired = { React.None, false, true },
		hasError = false,
		isDisabled = false,
		size = Dash.values(InputSize),
		maximum = 100,
		minimum = -5,
		step = 0.2,
		precision = 2,
	},
}
