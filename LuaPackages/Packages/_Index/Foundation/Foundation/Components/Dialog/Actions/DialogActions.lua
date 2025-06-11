local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)
local Dash = require(Packages.Dash)

local Button = require(Foundation.Components.Button)
local ButtonVariant = require(Foundation.Enums.ButtonVariant)
local FillBehavior = require(Foundation.Enums.FillBehavior)
local Text = require(Foundation.Components.Text)
local View = require(Foundation.Components.View)
local Types = require(Foundation.Components.Types)

type Bindable<T> = Types.Bindable<T>
type ButtonVariant = ButtonVariant.ButtonVariant

export type DialogAction = {
	variant: ButtonVariant?,
	icon: string?,
	text: string?,
	onActivated: () -> (),
	inputDelay: number?,
	ref: React.Ref<GuiObject>?,
}

export type DialogActionsProps = {
	actions: { DialogAction }?,
	label: Bindable<string>?,
	LayoutOrder: Bindable<number>?,
}

local function DialogActions(props: DialogActionsProps)
	local actions = React.useMemo(function()
		return React.createElement(
			React.Fragment,
			nil,
			Dash.map(props.actions, function(actionProps, index)
				return React.createElement(
					Button,
					Dash.join(actionProps, {
						key = `{index}-{actionProps.text}`,
						Name = actionProps.text,
						LayoutOrder = index,
						fillBehavior = FillBehavior.Fill,
					})
				)
			end)
		)
	end, { props.actions })

	return React.createElement(View, {
		tag = "col gap-large auto-y size-full-0",
		LayoutOrder = props.LayoutOrder,
	}, {
		ActionsContainer = React.createElement(View, {
			tag = "row wrap gap-large auto-y size-full-0",
			LayoutOrder = 1,
		}, {
			Actions = actions,
		}),
		ActionsLabel = if props.label
			then React.createElement(Text, {
				Text = props.label,
				tag = "text-label-small text-align-x-center text-align-y-top auto-y size-full-0",
				LayoutOrder = 2,
			})
			else nil,
	})
end

return DialogActions
