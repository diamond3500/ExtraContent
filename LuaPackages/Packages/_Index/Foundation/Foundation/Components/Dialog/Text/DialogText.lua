local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local Text = require(Foundation.Components.Text)
local Types = require(Foundation.Components.Types)

type Bindable<T> = Types.Bindable<T>

export type DialogTextProps = {
	Text: Bindable<string>?,
	LayoutOrder: Bindable<number>?,
}

local function DialogText(props: DialogTextProps)
	return React.createElement(Text, {
		Text = props.Text,
		RichText = true, -- This circumvents a bug with TextLabel where it doesn't update the size in scrollview
		tag = "text-body-large text-wrap text-align-x-left text-align-y-top auto-y size-full-0",
		LayoutOrder = props.LayoutOrder,
	})
end

return DialogText
