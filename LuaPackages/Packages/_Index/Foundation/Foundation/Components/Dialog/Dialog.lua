local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)
local Dash = require(Packages.Dash)

local Types = require(Foundation.Components.Types)
local View = require(Foundation.Components.View)
local DialogSize = require(Foundation.Enums.DialogSize)
local withCommonProps = require(Foundation.Utility.withCommonProps)
local withDefaults = require(Foundation.Utility.withDefaults)
local useScaledValue = require(Foundation.Utility.useScaledValue)
local useTokens = require(Foundation.Providers.Style.useTokens)
local DialogLayoutProvider = require(script.Parent.DialogLayoutProvider)
local DialogTitle = require(script.Parent.Title)
local DialogActions = require(script.Parent.Actions)
local useDialogLayout = require(script.Parent.useDialogLayout)
local useDialogVariants = require(script.Parent.useDialogVariants)

type Bindable<T> = Types.Bindable<T>

type DialogAction = DialogActions.DialogAction
type DialogSize = DialogSize.DialogSize

type DialogProps = {
	title: Bindable<string>?,
	closeIcon: string?,
	onClose: (() -> ())?,
	size: DialogSize?,
	children: React.ReactNode,
} & Types.NativeCallbackProps

type DialogInternalProps = DialogProps & {
	forwardRef: React.Ref<GuiObject>?,
}

local defaultProps = {
	size = DialogSize.Large,
}

local function Dialog(dialogProps: DialogInternalProps)
	local overriddenProps = Dash.assign({}, dialogProps, { LayoutOrder = 1 })
	local props = withDefaults(overriddenProps, defaultProps)
	local tokens = useTokens()
	local variants = useDialogVariants(tokens, props.size)
	local dialogLayout = useDialogLayout()
	local maxWidth = useScaledValue(variants.dialog.maxWidth)

	local bodyOffsetY = if dialogLayout.hasMediaBleed then 0 else dialogLayout.titleHeight

	return React.createElement(View, {
		tag = `{variants.container.tag} {variants.container.margin}`,
	}, {
		DialogFlexStart = React.createElement(View, {
			tag = "fill",
			LayoutOrder = 0,
		}),
		DialogInner = React.createElement(
			View,
			withCommonProps(props, {
				tag = variants.dialog.tag,
				ref = props.forwardRef,
				sizeConstraint = {
					MaxSize = Vector2.new(maxWidth, math.huge),
				},
			}),
			{
				DialogTitle = if dialogLayout.isTitleVisible
					then React.createElement(DialogTitle, {
						title = props.title,
						onClose = props.onClose,
						closeIcon = props.closeIcon,
						ZIndex = 2,
					})
					else nil,
				DialogBody = React.createElement(View, {
					tag = {
						["size-full-0 auto-y col align-x-center padding-x-xxlarge padding-bottom-xxlarge gap-xxlarge clip"] = true,
						["padding-top-xxlarge"] = not dialogLayout.hasMediaBleed,
					},
					ZIndex = 1,
					Position = UDim2.fromOffset(0, bodyOffsetY),
				}, props.children),
			}
		),
		DialogFlexEnd = React.createElement(View, {
			tag = "fill",
			LayoutOrder = 2,
		}),
	})
end

local function DialogContainer(props: DialogProps, ref: React.Ref<GuiObject>?)
	local isTitleVisible = props.title ~= nil or props.onClose ~= nil

	return React.createElement(DialogLayoutProvider, {
		isTitleVisible = isTitleVisible,
	}, {
		Dialog = React.createElement(
			Dialog,
			Dash.assign({}, props, {
				forwardRef = ref,
			})
		),
	})
end

return React.memo(React.forwardRef(DialogContainer))
