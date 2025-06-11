local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local IconButton = require(Foundation.Components.IconButton)
local IconSize = require(Foundation.Enums.IconSize)
local Text = require(Foundation.Components.Text)
local View = require(Foundation.Components.View)
local Types = require(Foundation.Components.Types)
local useTokens = require(Foundation.Providers.Style.useTokens)
local useTextSizeOffset = require(Foundation.Providers.Style.useTextSizeOffset)
local withDefaults = require(Foundation.Utility.withDefaults)

local useDialogLayout = require(script.Parent.Parent.useDialogLayout)
local renderFade = require(script.Parent.Parent.renderFade)

type Bindable<T> = Types.Bindable<T>

export type DialogTitleProps = {
	title: Bindable<string>?,
	onClose: (() -> ())?,
	closeIcon: string?,
	ZIndex: number?,
}

local defaultProps = {
	closeIcon = "icons/navigation/close",
}

local function DialogTitle(titleProps: DialogTitleProps)
	local props = withDefaults(titleProps, defaultProps)
	local tokens = useTokens()
	local textSizeOffset = useTextSizeOffset()
	local dialogLayout = useDialogLayout()

	React.useEffect(function()
		local titleFontStyle = tokens.Typography.HeadingSmall
		local titleFontHeight = (titleFontStyle.FontSize + textSizeOffset) * titleFontStyle.LineHeight
		local titleHeight = titleFontHeight + tokens.Padding.Medium * 2

		dialogLayout.setTitleHeight(titleHeight)
	end, { tokens, textSizeOffset } :: { any })

	React.useEffect(function()
		return function()
			dialogLayout.setTitleHeight(0)
		end
	end, { tokens, textSizeOffset } :: { any })

	return React.createElement(View, {
		Size = UDim2.new(1, 0, 0, dialogLayout.titleHeight),
		ZIndex = props.ZIndex,
	}, {
		TitleContent = React.createElement(View, {
			tag = "size-full padding-medium",
			ZIndex = 1,
		}, {
			CloseButton = if props.onClose
				then React.createElement(IconButton, {
					Position = UDim2.fromScale(0, 0.5),
					AnchorPoint = Vector2.new(0, 0.5),
					icon = props.closeIcon,
					size = IconSize.Medium, -- TODO: this needs to be smaller, but current IconSize mappings do not align with IconButton designs for InputSizes
					onActivated = props.onClose,
				})
				else nil,
			Title = if props.title
				then React.createElement(Text, {
					tag = "anchor-center-center position-center-center text-heading-small text-no-wrap auto-y size-full-0 text-truncate-end",
					Text = props.title,
				})
				else nil,
		}),
		TitleBorder = if props.title
			then React.createElement(View, {
				ZIndex = 1,
				tag = "stroke-default size-full-0 position-bottom-left",
			})
			else nil,
		TitleBackground = if dialogLayout.hasMediaBleed
			then React.createElement(View, {
				tag = "size-full clip",
				ZIndex = 0,
			}, {
				RoundedBackground = React.createElement(View, {
					tag = "bg-over-media-100 radius-medium",
					Size = UDim2.new(1, 0, 1, tokens.Radius.Medium),
				}, {
					TransparencyGradient = renderFade(0, tokens.Inverse.OverMedia.OverMedia_100.Transparency),
				}),
			})
			else nil,
	})
end

return DialogTitle
