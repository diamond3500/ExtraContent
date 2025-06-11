local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local Components = Foundation.Components
local Image = require(Components.Image)
local View = require(Components.View)
local Types = require(Components.Types)

local withCommonProps = require(Foundation.Utility.withCommonProps)
local withDefaults = require(Foundation.Utility.withDefaults)

local useKnobVariants = require(script.Parent.useKnobVariants)
local useTokens = require(Foundation.Providers.Style.useTokens)
local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

type Props = {
	-- The size variant of the knob
	size: InputSize?,
	isDisabled: boolean?,
} & Types.CommonProps

local defaultProps = {
	size = InputSize.Medium,
	isDisabled = false,
}

local function Knob(knobProps: Props)
	local props = withDefaults(knobProps, defaultProps)
	local tokens = useTokens()
	local style = if props.isDisabled
		then tokens.Color.Extended.Gray.Gray_500
		else tokens.Color.Extended.White.White_100
	local variantProps = useKnobVariants(tokens, props.size)

	return React.createElement(
		View,
		withCommonProps(props, {
			Size = variantProps.knob.size,
		}),
		{
			Circle = React.createElement(View, {
				tag = variantProps.knob.tag,
				backgroundStyle = style,
				Size = variantProps.knob.size,
				ZIndex = 4,
			}),
			Shadow = React.createElement(Image, {
				tag = variantProps.knobShadow.tag,
				Image = "component_assets/dropshadow_28",
				Size = variantProps.knobShadow.size,
				ZIndex = 3,
			}),
		}
	)
end

return React.memo(Knob)
