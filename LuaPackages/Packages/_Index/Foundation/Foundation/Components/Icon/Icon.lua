local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local BuilderIcons = require(Packages.BuilderIcons)
local Font = BuilderIcons.Font
local IconVariant = BuilderIcons.IconVariant
type IconVariant = BuilderIcons.IconVariant

local Text = require(Foundation.Components.Text)
local Image = require(Foundation.Components.Image)
local IconSize = require(Foundation.Enums.IconSize)
type IconSize = IconSize.IconSize

local useTokens = require(Foundation.Providers.Style.useTokens)
local withCommonProps = require(Foundation.Utility.withCommonProps)
local withDefaults = require(Foundation.Utility.withDefaults)
local useIconSize = require(Foundation.Utility.useIconSize)
local Logger = require(Foundation.Utility.Logger)
local isBuilderIcon = require(script.Parent.isBuilderIcon)

local Types = require(Foundation.Components.Types)
type Bindable<T> = Types.Bindable<T>
type ColorStyle = Types.ColorStyle

type IconProps = {
	name: string,
	style: ColorStyle?,
	size: IconSize | number?,
	variant: IconVariant?,
	Rotation: Bindable<number>?,
	-- **DEPRECATED**
	children: React.ReactNode?,
} & Types.CommonProps

local defaultProps = {
	size = IconSize.Medium,
	variant = IconVariant.Regular,
}

local function Icon(iconProps: IconProps, ref: React.Ref<GuiObject>?)
	local props = withDefaults(iconProps, defaultProps)
	local tokens = useTokens()
	local isBuilderIcon = isBuilderIcon(props.name)
	local size = useIconSize(props.size, isBuilderIcon)

	local iconStyle = props.style or tokens.Color.Content.Default

	if not isBuilderIcon then
		if iconProps.variant ~= nil then
			Logger:warning("variant is not supported when using FoundationImages, consider using BuilderIcons")
		end
		return React.createElement(
			Image,
			withCommonProps(props, {
				imageStyle = iconStyle,
				Image = props.name,
				Size = size,

				-- Pass through props
				ref = ref,
				Rotation = props.Rotation,
			}),
			props.children
		) :: React.Node
	else
		return React.createElement(
			Text,
			withCommonProps(props, {
				textStyle = iconStyle,
				Text = props.name,
				fontStyle = {
					Font = Font[props.variant],
					FontSize = size.Y.Offset,
				},
				Size = size,

				-- Pass through props
				ref = ref,
				Rotation = props.Rotation,
			})
		)
	end
end

return React.memo(React.forwardRef(Icon))
