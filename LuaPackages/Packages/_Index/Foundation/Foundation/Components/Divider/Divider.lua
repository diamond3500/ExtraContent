local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local Types = require(Foundation.Components.Types)
local View = require(Foundation.Components.View)
local useTokens = require(Foundation.Providers.Style.useTokens)
local withDefaults = require(Foundation.Utility.withDefaults)
local withCommonProps = require(Foundation.Utility.withCommonProps)
local DividerVariant = require(Foundation.Enums.DividerVariant)
local useDividerVariants = require(script.Parent.useDividerVariants)

type DividerVariant = DividerVariant.DividerVariant

type DividerProps = {
	-- Configures the visual style of the divider.
	variant: DividerVariant?,
} & Types.CommonProps

local defaultProps = {
	variant = DividerVariant.Default,
}

local function Divider(dividerProps: DividerProps, ref: React.Ref<GuiObject>?)
	local props = withDefaults(dividerProps, defaultProps)
	local tokens = useTokens()
	local variantProps = useDividerVariants(tokens, props.variant)
	local isHeavy = props.variant :: DividerVariant == DividerVariant.Heavy

	return React.createElement(
		View,
		withCommonProps(props, {
			tag = variantProps.container.tag,
			ref = ref,
		}),
		{
			DividerStroke = React.createElement(View, {
				tag = variantProps.stroke.tag,
				backgroundStyle = variantProps.stroke.backgroundStyle,
			}),
			DividerLine = if isHeavy
				then React.createElement(View, {
					tag = variantProps.line.tag,
					Position = variantProps.line.position,
					backgroundStyle = variantProps.line.backgroundStyle,
				})
				else nil,
		}
	)
end

return React.memo(React.forwardRef(Divider))
