local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local View = require(Foundation.Components.View)
local Image = require(Foundation.Components.Image)
local Types = require(Foundation.Components.Types)

local withDefaults = require(Foundation.Utility.withDefaults)

type Bindable<T> = Types.Bindable<T>
type AspectRatio = Types.AspectRatio

export type DialogMediaProps = {
	media: Bindable<string>,
	aspectRatio: AspectRatio?,
	Size: Bindable<UDim2>?,
	LayoutOrder: Bindable<number>?,
}

local defaultProps = {
	LayoutOrder = -1, -- Prefer to render first
}

local function DialogMedia(mediaProps: DialogMediaProps)
	local props = withDefaults(mediaProps, defaultProps)

	return React.createElement(View, {
		tag = "auto-y size-full-0 row align-x-center",
		LayoutOrder = props.LayoutOrder,
	}, {
		Image = React.createElement(Image, {
			aspectRatio = props.aspectRatio,
			Image = props.media,
			Size = props.Size,
		}),
	})
end

return DialogMedia
