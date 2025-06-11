local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local React = require(Packages.React)
local Dash = require(Packages.Dash)

local Knob = require(script.Parent.Knob)
local InputSize = require(Foundation.Enums.InputSize)

local function Story(props)
	local controls = props.controls

	return React.createElement(Knob, {
		size = controls.size,
		isDisabled = controls.isDisabled,
	})
end

return {
	summary = "Knob component",
	story = Story,
	controls = {
		isDisabled = false,
		size = Dash.values(InputSize),
	},
}
