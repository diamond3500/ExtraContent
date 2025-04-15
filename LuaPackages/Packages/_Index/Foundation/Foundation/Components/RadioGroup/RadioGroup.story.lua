local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local React = require(Packages.React)

local Dash = require(Packages.Dash)

local RadioGroup = require(Foundation.Components.RadioGroup)

local InputSize = require(Foundation.Enums.InputSize)

local values = { "A", "B", "C", "D", "E" }

local function Story(props)
	local controls = props.controls
	local optionLabel: string = controls.optionLabel
	local items = {}
	Dash.forEach(values, function(value)
		table.insert(
			items,
			React.createElement(RadioGroup.Item, {
				value = value,
				label = optionLabel .. " " .. value,
				isDisabled = value == "D",
				size = controls.size,
			})
		)
	end)

	return React.createElement(RadioGroup.Root, {
		onValueChanged = function(value: string)
			print("Checking value", value)
		end,
	}, items)
end

return {
	summary = "Radio Group component",
	story = Story,
	controls = {
		optionLabel = "Option",
		size = Dash.values(InputSize),
	},
}
