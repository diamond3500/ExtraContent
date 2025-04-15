local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local Flags = require(Foundation.Utility.Flags)

local FFlagFoundationFixSupportImageBinding = Flags.FoundationFixSupportImageBinding

local React = require(Packages.React)
local Cryo = require(Packages.Cryo)
local ReactIs = require(Packages.ReactIs)
local FoundationImages = require(Packages.FoundationImages)

local Interactable = require(Foundation.Components.Interactable)
local Images = FoundationImages.Images
type ImageSetImage = FoundationImages.ImageSetImage
local getScaledSlice = require(script.Parent.ImageSet.getScaledSlice)

local Types = require(Foundation.Components.Types)
local withDefaults = require(Foundation.Utility.withDefaults)
local useDefaultTags = require(Foundation.Utility.useDefaultTags)
local withGuiObjectProps = require(Foundation.Utility.withGuiObjectProps)
local useStyledDefaults = require(Foundation.Utility.useStyledDefaults)
local indexBindable = require(Foundation.Utility.indexBindable)
local GuiObjectChildren = require(Foundation.Utility.GuiObjectChildren)
type ColorStyle = Types.ColorStyle

local useStyleTags = require(Foundation.Providers.Style.useStyleTags)

type StateChangedCallback = Types.StateChangedCallback
type Bindable<T> = Types.Bindable<T>

export type Slice = {
	center: Rect?,
	scale: number?,
}

export type ImageRect = {
	offset: Bindable<Vector2>?,
	size: Bindable<Vector2>?,
}

type ImageProps = {
	slice: Slice?,
	imageRect: ImageRect?,
	imageStyle: ColorStyle?,

	Image: Bindable<string>?,
	ResampleMode: Bindable<Enum.ResamplerMode>?,
	ScaleType: Bindable<Enum.ScaleType>?,
	TileSize: Bindable<UDim2>?,
} & Types.GuiObjectProps & Types.CommonProps

local defaultProps = {
	AutoLocalize = false,
	AutoButtonColor = false,
	BorderSizePixel = 0,
	isDisabled = false,
}

local DEFAULT_TAGS = "gui-object-defaults"

local function ImageValue(value): string?
	if ReactIs.isBinding(value) then
		return (value :: React.Binding<string>):getValue()
	else
		return value :: string
	end
end

local function isFoundationAsset(image)
	local imageValue = ImageValue(image)
	return imageValue ~= nil and imageValue:match("^%w+://.*$") == nil
end

local function Image(imageProps: ImageProps, ref: React.Ref<GuiObject>?)
	local defaultPropsWithStyles = if Flags.FoundationStylingPolyfill
		then useStyledDefaults("Image", imageProps.tag, DEFAULT_TAGS, defaultProps)
		else nil
	local props = withDefaults(
		imageProps,
		(if Flags.FoundationStylingPolyfill then defaultPropsWithStyles else defaultProps) :: typeof(defaultProps)
	)

	local isInteractable = props.onStateChanged ~= nil or props.onActivated ~= nil

	local image, imageRectOffset, imageRectSize = nil, nil, nil
	local isFoundationImage = nil

	if FFlagFoundationFixSupportImageBinding then
		image, imageRectOffset, imageRectSize = React.useMemo(function(): ...any
			local image = props.Image
			local imageRectOffset = if props.imageRect then props.imageRect.offset else nil
			local imageRectSize = if props.imageRect then props.imageRect.size else nil

			if ReactIs.isBinding(props.Image) then
				local function getImageBindingValue(prop)
					return (props.Image :: React.Binding<string>):map(function(value: string)
						if isFoundationAsset(value) then
							local asset = Images[value]
							return if asset then asset[prop] else nil
						elseif prop == "Image" then
							return value
						elseif prop == "ImageRectOffset" and props.imageRect then
							return props.imageRect.offset
						elseif prop == "ImageRectSize" and props.imageRect then
							return props.imageRect.size
						else
							return nil
						end
					end)
				end

				image = getImageBindingValue("Image")
				imageRectOffset = getImageBindingValue("ImageRectOffset")
				imageRectSize = getImageBindingValue("ImageRectSize")
			elseif isFoundationAsset(props.Image) then
				local imageValue = ImageValue(props.Image)
				local asset = Images[imageValue]
				if asset then
					image = asset.Image
					imageRectOffset = asset.ImageRectOffset
					imageRectSize = asset.ImageRectSize
				end
			end

			return image, imageRectOffset, imageRectSize
		end, { props.Image, props.imageRect :: any, Images :: any })
	else
		image = props.Image
		local imageValue = if ReactIs.isBinding(image)
			then (image :: React.Binding<string>):getValue()
			else image :: string

		isFoundationImage = imageValue ~= nil and imageValue:match("^%w+://.*$") == nil
		local asset = if isFoundationImage then Images[imageValue] else nil

		imageRectOffset, imageRectSize = nil, nil
		if props.imageRect then
			imageRectOffset = props.imageRect.offset
			imageRectSize = props.imageRect.size
		end
		if asset then
			image = asset.Image
			imageRectOffset = asset.ImageRectOffset
			imageRectSize = asset.ImageRectSize
		end
	end

	local sliceCenter, sliceScale, scaleType = nil, nil, props.ScaleType
	if props.slice then
		sliceCenter, sliceScale = props.slice.center, props.slice.scale
		local isFoundation = if FFlagFoundationFixSupportImageBinding
			then isFoundationAsset(props.Image)
			else isFoundationImage
		if isFoundation then
			sliceCenter, sliceScale = getScaledSlice(sliceCenter, sliceScale)
		end
		scaleType = Enum.ScaleType.Slice
	end

	local defaultTags = DEFAULT_TAGS
	if Flags.FoundationMigrateStylingV2 then
		local transparency = if props.backgroundStyle ~= nil
			then indexBindable(props.backgroundStyle, "Transparency") :: any
			else nil
		if transparency == 0 then
			defaultTags ..= " x-default-transparency"
		end
	end
	local tagsWithDefaults = useDefaultTags(props.tag, defaultTags)
	local tag = useStyleTags(tagsWithDefaults)

	local engineComponent = if isInteractable then "ImageButton" else "ImageLabel"

	local engineComponentProps = withGuiObjectProps(props, {
		AutoButtonColor = if engineComponent == "ImageButton" then props.AutoButtonColor else nil,
		Image = image,
		ImageColor3 = if props.imageStyle then indexBindable(props.imageStyle, "Color3") else nil,
		ImageTransparency = if props.imageStyle then indexBindable(props.imageStyle, "Transparency") else nil,
		ImageRectOffset = imageRectOffset,
		ImageRectSize = imageRectSize,
		ResampleMode = props.ResampleMode,
		ScaleType = scaleType,
		SliceCenter = sliceCenter,
		SliceScale = sliceScale,
		TileSize = props.TileSize,

		ref = ref,
		[React.Tag] = tag,
	})

	local component = if isInteractable then Interactable else engineComponent

	local componentProps = if isInteractable
		then Cryo.Dictionary.union(engineComponentProps, {
			component = engineComponent,
			onActivated = props.onActivated,
			onStateChanged = props.onStateChanged,
			stateLayer = props.stateLayer,
			isDisabled = props.isDisabled,
		})
		else engineComponentProps

	return React.createElement(component, componentProps, GuiObjectChildren(props))
end

return React.memo(React.forwardRef(Image))
