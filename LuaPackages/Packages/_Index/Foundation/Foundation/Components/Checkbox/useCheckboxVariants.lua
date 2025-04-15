local Foundation = script:FindFirstAncestor("Foundation")

local Types = require(Foundation.Components.Types)
type ColorStyleValue = Types.ColorStyleValue
type Padding = Types.Padding

local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

local InputLabelSize = require(Foundation.Enums.InputLabelSize)
type InputLabelSize = InputLabelSize.InputLabelSize

local ControlState = require(Foundation.Enums.ControlState)
type ControlState = ControlState.ControlState

local composeStyleVariant = require(Foundation.Utility.composeStyleVariant)
type VariantProps = composeStyleVariant.VariantProps

local Tokens = require(Foundation.Providers.Style.Tokens)
type Tokens = Tokens.Tokens

local VariantsContext = require(Foundation.Providers.Style.VariantsContext)

type CheckboxVariantProps = {
	container: { tag: string, padding: Padding },
	checkbox: { tag: string, size: UDim2, stroke: ColorStyleValue },
	checkmark: { tag: string },
	label: { style: ColorStyleValue },
}

export type CheckboxState = ControlState | "Checked"

local function variantsFactory(tokens: Tokens)
	local strokeThickness = math.ceil(tokens.Stroke.Standard)
	local function getCheckboxSize(size: number): UDim2
		return UDim2.fromOffset(size - strokeThickness, size - strokeThickness)
	end

	local common = {
		container = {
			tag = "row auto-xy align-x-left align-y-center",
			-- Add padding around checkbox to ensure it's not cut off
			-- by the bounds of the canvas group
			padding = {
				top = UDim.new(0, strokeThickness),
				bottom = UDim.new(0, strokeThickness),
				left = UDim.new(0, strokeThickness),
			},
		},
		checkbox = {
			tag = "stroke-standard radius-small",
		},
		checkmark = {
			tag = "position-center-center anchor-center-center content-action-sub-emphasis",
		},
	}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = {
			container = {
				tag = "gap-small",
			},
			checkbox = {
				size = getCheckboxSize(tokens.Size.Size_400),
			},
			checkmark = {
				tag = "size-300",
			},
		},
		[InputSize.Small] = {
			container = {
				tag = "gap-small",
			},
			checkbox = {
				size = getCheckboxSize(tokens.Size.Size_500),
			},
			checkmark = {
				tag = "size-350",
			},
		},
		[InputSize.Medium] = {
			container = {
				tag = "gap-medium",
			},
			checkbox = {
				size = getCheckboxSize(tokens.Size.Size_600),
			},
			checkmark = {
				tag = "size-400",
			},
		},
		[InputSize.Large] = {
			container = {
				tag = "gap-large",
			},
			checkbox = {
				size = getCheckboxSize(tokens.Size.Size_700),
			},
			checkmark = {
				tag = "size-500",
			},
		},
	}

	-- Strokes are intentionally left as tokens, because tags with matching name uses different color tokens
	local states: { [CheckboxState]: VariantProps } = {
		Checked = {
			checkbox = {
				tag = "bg-action-sub-emphasis",
				stroke = tokens.Color.ActionSubEmphasis.Background,
			},
			label = {
				style = tokens.Color.Content.Emphasis,
			},
		},
		[ControlState.Hover] = {
			checkbox = {
				stroke = tokens.Color.Content.Emphasis,
			},
			label = {
				style = tokens.Color.Content.Emphasis,
			},
		},
		[ControlState.Default] = {
			checkbox = {
				stroke = tokens.Color.Content.Default,
			},
			label = {
				style = tokens.Color.Content.Default,
			},
		},
	}

	return { common = common, sizes = sizes, states = states }
end

return function(tokens: Tokens, size: InputSize, state: CheckboxState): CheckboxVariantProps
	local props = VariantsContext.useVariants("Checkbox", variantsFactory, tokens)
	return composeStyleVariant(props.common, props.sizes[size], props.states[state])
end
