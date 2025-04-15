local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local Image = require(Foundation.Components.Image)
local IconSize = require(Foundation.Enums.IconSize)
type IconSize = IconSize.IconSize

local useTokens = require(Foundation.Providers.Style.useTokens)
local withCommonProps = require(Foundation.Utility.withCommonProps)
local withDefaults = require(Foundation.Utility.withDefaults)
local useIconSize = require(Foundation.Utility.useIconSize)

local Types = require(Foundation.Components.Types)
type Bindable<T> = Types.Bindable<T>
type ColorStyle = Types.ColorStyle

type IconProps = {
	name: string,
	style: ColorStyle?,
	size: IconSize?,
	Rotation: Bindable<number>?,
	children: React.ReactNode?,
} & Types.CommonProps

local defaultProps = {
	size = IconSize.Medium,
}

local function Icon(iconProps: IconProps, ref: React.Ref<GuiObject>?)
	local props = withDefaults(iconProps, defaultProps)
	local tokens = useTokens()
	local size = useIconSize(props.size)

	local iconStyle = props.style or tokens.Color.Content.Default

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
	)
end

return React.memo(React.forwardRef(Icon))
