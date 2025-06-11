local Foundation = script:FindFirstAncestor("Foundation")

local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

local composeStyleVariant = require(Foundation.Utility.composeStyleVariant)
type VariantProps = composeStyleVariant.VariantProps

local Tokens = require(Foundation.Providers.Style.Tokens)
type Tokens = Tokens.Tokens

local getKnobSize = require(Foundation.Components.Knob.getKnobSize)
local VariantsContext = require(Foundation.Providers.Style.VariantsContext)

type ToggleVariantProps = {
	toggle: {
		size: UDim2,
		cornerRadius: UDim,
	},
	knob: {
		offPosition: UDim2,
		onPosition: UDim2,
	},
}

local function computeProps(props: {
	size: { height: number, width: number },
	cornerRadius: number,
	knobSize: UDim2,
})
	local knobWidth = props.knobSize.X.Offset
	local padding = (props.size.height - knobWidth) / 2
	return {
		toggle = {
			size = UDim2.fromOffset(props.size.width, props.size.height),
			cornerRadius = UDim.new(0, props.cornerRadius),
		},
		knob = {
			offPosition = UDim2.new(0, padding, 0.5, 0),
			onPosition = UDim2.new(0, props.size.width - knobWidth - padding, 0.5, 0),
		},
	}
end

local function variantsFactory(tokens: Tokens)
	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = computeProps({
			size = { width = tokens.Size.Size_700, height = tokens.Size.Size_300 },
			cornerRadius = tokens.Radius.Large,
			knobSize = getKnobSize(tokens, InputSize.XSmall),
		}),
		[InputSize.Small] = computeProps({
			size = { width = tokens.Size.Size_800, height = tokens.Size.Size_400 },
			cornerRadius = tokens.Radius.Large,
			knobSize = getKnobSize(tokens, InputSize.Small),
		}),
		[InputSize.Medium] = computeProps({
			size = { width = tokens.Size.Size_1000, height = tokens.Size.Size_500 },
			cornerRadius = tokens.Radius.Large,
			knobSize = getKnobSize(tokens, InputSize.Medium),
		}),
		[InputSize.Large] = computeProps({
			size = { width = tokens.Size.Size_1600, height = tokens.Size.Size_900 },
			cornerRadius = tokens.Radius.Circle,
			knobSize = getKnobSize(tokens, InputSize.Large),
		}),
	}

	return { sizes = sizes }
end

return function(tokens: Tokens, size: InputSize): ToggleVariantProps
	local props = VariantsContext.useVariants("Toggle", variantsFactory, tokens)
	return composeStyleVariant(props.sizes[size])
end
