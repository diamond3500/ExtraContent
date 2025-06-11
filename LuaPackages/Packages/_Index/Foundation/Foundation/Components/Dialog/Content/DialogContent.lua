local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local ScrollView = require(Foundation.Components.ScrollView)
local Types = require(Foundation.Components.Types)
local withCommonProps = require(Foundation.Utility.withCommonProps)
local useScrollBarPadding = require(script.Parent.useScrollBarPadding)

export type DialogContentProps = {
	children: React.ReactNode,
} & Types.CommonProps

local function DialogContent(props: DialogContentProps)
	local scrollBarPadding, updateScrollBarPadding = useScrollBarPadding()

	return React.createElement(
		ScrollView,
		withCommonProps(props, {
			scroll = {
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.new(0, 0, 0, 0),
			},
			onAbsoluteCanvasSizeChanged = updateScrollBarPadding,
			onAbsoluteWindowSizeChanged = updateScrollBarPadding,
			tag = "auto-y size-full fill clip",
		}),
		{
			ScrollPadding = React.createElement("UIPadding", {
				PaddingRight = UDim.new(0, scrollBarPadding),
			}),
			ScrollContent = React.createElement(React.Fragment, nil, props.children),
		}
	)
end

return DialogContent
