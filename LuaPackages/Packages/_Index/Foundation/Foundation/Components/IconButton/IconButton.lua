local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)
local BuilderIcons = require(Packages.BuilderIcons)

local IconSize = require(Foundation.Enums.IconSize)
type IconSize = IconSize.IconSize

local Radius = require(Foundation.Enums.Radius)
type Radius = Radius.Radius

local ControlState = require(Foundation.Enums.ControlState)
type ControlState = ControlState.ControlState

local useTokens = require(Foundation.Providers.Style.useTokens)
local useCursor = require(Foundation.Providers.Cursor.useCursor)
local withCommonProps = require(Foundation.Utility.withCommonProps)
local withDefaults = require(Foundation.Utility.withDefaults)
local useIconSize = require(Foundation.Utility.useIconSize)
local useIconButtonPadding = require(script.Parent.useIconButtonPadding)
local isBuilderIcon = require(Foundation.Components.Icon.isBuilderIcon)

local Icon = require(Foundation.Components.Icon)
local View = require(Foundation.Components.View)
local Types = require(Foundation.Components.Types)

local Flags = require(Foundation.Utility.Flags)

local ICON_SIZE_TO_RADIUS_DEPRECATED: { [IconSize]: Radius } = {
	[IconSize.XSmall] = Radius.Small,
	[IconSize.Small] = Radius.Small,
	[IconSize.Medium] = Radius.Medium,
	[IconSize.Large] = Radius.Large,
	-- No Xlarge, map to large
	[IconSize.XLarge] = Radius.Large,
	-- No XXlarge, map to large
	[IconSize.XXLarge] = Radius.Large,
}

local ICON_SIZE_TO_RADIUS: { [IconSize]: Radius } = {
	[IconSize.XSmall] = Radius.Small,
	[IconSize.Small] = Radius.Medium,
	[IconSize.Medium] = Radius.Medium,
	[IconSize.Large] = Radius.Medium,
}

type IconButtonProps = {
	onActivated: () -> (),
	isDisabled: boolean?,
	isCircular: boolean?,
	size: IconSize?,
	icon: string | {
		name: BuilderIcons.Icon,
		variant: BuilderIcons.IconVariant?,
	},
} & Types.SelectionProps & Types.CommonProps

local defaultProps = {
	isDisabled = false,
	size = IconSize.Medium,
}

local function IconButton(iconButtonProps: IconButtonProps, ref: React.Ref<GuiObject>?)
	local props = withDefaults(iconButtonProps, defaultProps)
	local tokens = useTokens()

	local iconName = if typeof(props.icon) == "table" then props.icon.name else props.icon
	local iconVariant: BuilderIcons.IconVariant? = if typeof(props.icon) == "table" then props.icon.variant else nil

	local isBuilderIcon = isBuilderIcon(iconName)

	local radiusEnum = if isBuilderIcon
		then ICON_SIZE_TO_RADIUS[props.size]
		else ICON_SIZE_TO_RADIUS_DEPRECATED[props.size]
	local radius = tokens.Radius[radiusEnum]

	local paddingOffset = useIconButtonPadding(props.size, isBuilderIcon)
	local padding = UDim.new(0, paddingOffset)

	local size = useIconSize(props.size, isBuilderIcon)

	local cursor = useCursor({
		radius = UDim.new(0, radius),
		borderWidth = tokens.Stroke.Thicker,
	})

	return React.createElement(
		View,
		withCommonProps(props, {
			onActivated = props.onActivated,

			Size = size + UDim2.new(padding, padding) + UDim2.new(padding, padding),
			selection = {
				Selectable = not props.isDisabled,
				SelectionImageObject = cursor,
				NextSelectionUp = props.NextSelectionUp,
				NextSelectionDown = props.NextSelectionDown,
				NextSelectionLeft = props.NextSelectionLeft,
				NextSelectionRight = props.NextSelectionRight,
			},
			isDisabled = if Flags.FoundationFixDisablingForIconButtons then props.isDisabled else nil,
			padding = padding,
			cornerRadius = UDim.new(0, radius),

			ref = ref,
		}),
		{
			Icon = React.createElement(Icon, {
				name = iconName,
				variant = iconVariant,
				size = props.size,
				style = tokens.Color.Content.Emphasis,
			}),
		}
	)
end

return React.memo(React.forwardRef(IconButton))
