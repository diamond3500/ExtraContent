local Foundation = script:FindFirstAncestor("Foundation")

local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

local composeStyleVariant = require(Foundation.Utility.composeStyleVariant)
type VariantProps = composeStyleVariant.VariantProps

local Tokens = require(Foundation.Providers.Style.Tokens)
type Tokens = Tokens.Tokens

local VariantsContext = require(Foundation.Providers.Style.VariantsContext)

local function computeProps(props: {
	width: number,
	horizontalPadding: number,
	upButtonTag: string,
	downButtonTag: string,
})
	local horizontalPadding = UDim.new(0, (props.width - props.horizontalPadding) / 2)
	return {
		button = {
			tag = "size-full fill",
			width = props.width,
			padding = {
				left = horizontalPadding,
				right = horizontalPadding,
			},
		},
		upButton = {
			tag = props.upButtonTag,
		},
		downButton = {
			tag = props.downButtonTag,
		},
	}
end

local function variantsFactory(tokens: Tokens)
	local common = {
		upButton = {
			tag = "size-full fill padding-bottom-xsmall",
		},
		downButton = {
			tag = "size-full fill padding-top-xsmall",
		},
		icon = {
			tag = "content-default size-150-100",
		},
	}
	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = computeProps({
			width = tokens.Size.Size_400,
			horizontalPadding = tokens.Size.Size_150,
			upButtonTag = "padding-top-xxsmall",
			downButtonTag = "padding-bottom-xxsmall",
		}),
		[InputSize.Small] = computeProps({
			width = tokens.Size.Size_600,
			horizontalPadding = tokens.Size.Size_150,
			upButtonTag = "padding-top-xsmall",
			downButtonTag = "padding-bottom-xsmall",
		}),
		[InputSize.Medium] = computeProps({
			width = tokens.Size.Size_600,
			horizontalPadding = tokens.Size.Size_150,
			upButtonTag = "padding-top-small",
			downButtonTag = "padding-bottom-small",
		}),
		[InputSize.Large] = computeProps({
			width = tokens.Size.Size_800,
			horizontalPadding = tokens.Size.Size_150,
			upButtonTag = "padding-top-medium",
			downButtonTag = "padding-bottom-medium",
		}),
	}
	return { common = common, sizes = sizes }
end

return function(tokens: Tokens, size: InputSize)
	local props = VariantsContext.useVariants("NumberInput", variantsFactory, tokens)
	return composeStyleVariant(props.common, props.sizes[size])
end
