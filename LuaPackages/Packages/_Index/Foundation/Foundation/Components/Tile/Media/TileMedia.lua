local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local MediaType = require(Foundation.Enums.MediaType)
type MediaType = MediaType.MediaType

local MediaShape = require(Foundation.Enums.MediaShape)
type MediaShape = MediaShape.MediaShape

local useTileLayout = require(Foundation.Components.Tile.useTileLayout)
local withDefaults = require(Foundation.Utility.withDefaults)

local Image = require(Foundation.Components.Image)
local View = require(Foundation.Components.View)
local useTokens = require(Foundation.Providers.Style.useTokens)

local Types = require(Foundation.Components.Types)
type ColorStyle = Types.ColorStyle
type StateChangedCallback = Types.StateChangedCallback

local SHAPE_TO_ASPECT_RATIO: { [MediaShape]: number } = {
	[MediaShape.Circle] = 1,
	[MediaShape.Square] = 1,
	[MediaShape.Landscape] = 16 / 9,
	[MediaShape.Portrait] = 9 / 16,
}

type TileMediaProps = {
	id: number?,
	type: MediaType?,
	shape: MediaShape?,
	style: ColorStyle?,
	background: {
		image: string?,
		style: ColorStyle?,
	}?,
	onStateChanged: StateChangedCallback?,
	children: React.ReactNode?,
	LayoutOrder: number?,
}

local defaultProps = {
	shape = MediaShape.Square,
	LayoutOrder = 1,
}

local function renderGradient(fillDirection: Enum.FillDirection, top: boolean)
	local gradient = React.createElement("UIGradient", {
		Rotation = if fillDirection == Enum.FillDirection.Vertical then 90 else 0,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, if top then 0 else 1),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, if top then 1 else 0),
		}),
	})
	return gradient
end

local function TileMedia(tileMediaProps: TileMediaProps)
	local props = withDefaults(tileMediaProps, defaultProps)

	local tileLayout = useTileLayout()
	local tokens = useTokens()

	local backgroundStyle: ColorStyle? = if props.background then props.background.style :: any else nil
	local backgroundImage: string? = if props.background then props.background.image else nil

	local image = React.useMemo(function()
		if props.id == nil or props.type == nil then
			return nil :: string?
		end

		return `rbxthumb://type={props.type}&id={props.id}&w=150&h=150`
	end, { props.type, props.id } :: { any })

	local cornerRadius = if props.shape :: MediaShape == MediaShape.Circle
		then UDim.new(0, tokens.Radius.Circle)
		else UDim.new(0, tokens.Radius.Medium)

	local hasMiddleCorners = tileLayout.isContained and cornerRadius
	local topGradient = if hasMiddleCorners then renderGradient(tileLayout.fillDirection, true) else nil
	local bottomGradient = if hasMiddleCorners then renderGradient(tileLayout.fillDirection, false) else nil

	return React.createElement(if backgroundImage then Image else View, {
		Image = backgroundImage,
		imageStyle = if backgroundImage then backgroundStyle else nil,
		backgroundStyle = if backgroundImage then nil else backgroundStyle,
		Size = if tileLayout.fillDirection == Enum.FillDirection.Vertical
			then UDim2.fromScale(1, 0)
			else UDim2.fromScale(0, 1),
		ZIndex = 0,
		LayoutOrder = props.LayoutOrder,

		aspectRatio = {
			AspectRatio = SHAPE_TO_ASPECT_RATIO[props.shape],
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = if tileLayout.fillDirection == Enum.FillDirection.Vertical
				then Enum.DominantAxis.Width
				else Enum.DominantAxis.Height,
		},
		cornerRadius = cornerRadius,
		onStateChanged = props.onStateChanged,
	}, {
		-- If the tile is contained, we only round the top two corners.
		-- This is achieved by duplicating the background and images, and only
		-- showing half of each (rounding all four on the first set, and none on the second)
		TransparencyGradient = topGradient,
		MiddleCorners = if hasMiddleCorners
			then React.createElement(Image, {
				Image = backgroundImage,
				imageStyle = if backgroundImage then backgroundStyle else nil,
				backgroundStyle = if backgroundImage then nil else backgroundStyle,
				ZIndex = 0,
				tag = "size-full",
			}, {
				TransparencyGradient = bottomGradient,
				Image = React.createElement(Image, {
					Image = image,
					imageStyle = props.style,
					tag = "size-full",
				}, {
					TransparencyGradient = bottomGradient,
				}),
			})
			else nil,
		Image = React.createElement(Image, {
			Image = image,
			cornerRadius = cornerRadius,
			imageStyle = props.style,
			tag = {
				["size-full"] = true,
				["padding-medium"] = props.children ~= nil,
			},
		}, props.children),
	})
end

return TileMedia
