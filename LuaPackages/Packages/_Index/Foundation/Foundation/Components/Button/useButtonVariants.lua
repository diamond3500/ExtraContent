local Foundation = script:FindFirstAncestor("Foundation")
local Flags = require(Foundation.Utility.Flags)

local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

local ButtonVariant = require(Foundation.Enums.ButtonVariant)
type ButtonVariant = ButtonVariant.ButtonVariant

local StateLayerMode = require(Foundation.Enums.StateLayerMode)

local Types = require(Foundation.Components.Types)
type ColorStyleValue = Types.ColorStyleValue
type StateLayer = Types.StateLayer
type Stroke = {
	Color: Color3,
	Transparency: number,
}

local VariantsContext = require(Foundation.Providers.Style.VariantsContext)
local composeStyleVariant = require(Foundation.Utility.composeStyleVariant)
type VariantProps = composeStyleVariant.VariantProps

local Tokens = require(Foundation.Providers.Style.Tokens)
type Tokens = Tokens.Tokens

type ButtonVariantProps = {
	container: {
		tag: string,
		height: number,
		stroke: Stroke,
		radius: number,
		style: ColorStyleValue,
		stateLayer: StateLayer?,
	},
	content: {
		style: ColorStyleValue,
	},
	text: {
		tag: string,
	},
	icon: {
		size: UDim2,
	},
}

local function toStroke(token: { Color3: Color3, Transparency: number }): Stroke
	return {
		Color = token.Color3,
		Transparency = token.Transparency,
	}
end

local variants = function(tokens: Tokens)
	local common = {
		container = {
			tag = "row align-y-center align-x-center clip",
		},
		icon = if Flags.FoundationEnableNewButtonSizes
			then nil
			else {
				size = UDim2.fromOffset(tokens.Size.Size_900, tokens.Size.Size_900),
			},
		text = {
			tag = (if Flags.FoundationEnableNewButtonSizes then "" else "text-title-large ")
				.. "size-0-full auto-x text-truncate-end shrink",
		},
	}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = {
			container = {
				tag = "gap-xsmall padding-small",
				radius = tokens.Radius.Small,
				height = if Flags.FoundationEnableNewButtonSizes then tokens.Size.Size_600 else tokens.Size.Size_700,
			},
			icon = if Flags.FoundationEnableNewButtonSizes
				then {
					size = UDim2.fromOffset(tokens.Size.Size_300, tokens.Size.Size_300),
				}
				else nil,
			text = if Flags.FoundationEnableNewButtonSizes
				then {
					tag = "text-title-small",
				}
				else nil,
		},
		[InputSize.Small] = {
			container = {
				tag = "gap-xsmall padding-small",
				radius = tokens.Radius.Medium,
				height = if Flags.FoundationEnableNewButtonSizes then tokens.Size.Size_800 else tokens.Size.Size_900,
			},
			icon = if Flags.FoundationEnableNewButtonSizes
				then {
					size = UDim2.fromOffset(tokens.Size.Size_400, tokens.Size.Size_400),
				}
				else nil,
			text = if Flags.FoundationEnableNewButtonSizes
				then {
					tag = "text-title-small",
				}
				else nil,
		},
		[InputSize.Medium] = {
			container = {
				tag = "gap-small padding-small",
				radius = tokens.Radius.Medium,
				height = if Flags.FoundationEnableNewButtonSizes then tokens.Size.Size_1000 else tokens.Size.Size_1200,
			},
			icon = if Flags.FoundationEnableNewButtonSizes
				then {
					size = UDim2.fromOffset(tokens.Size.Size_500, tokens.Size.Size_500),
				}
				else nil,
			text = if Flags.FoundationEnableNewButtonSizes
				then {
					tag = "text-title-medium",
				}
				else nil,
		},
		[InputSize.Large] = {
			container = {
				tag = "gap-small padding-medium",
				radius = tokens.Radius.Medium,
				height = tokens.Size.Size_1200,
			},
			icon = if Flags.FoundationEnableNewButtonSizes
				then {
					size = UDim2.fromOffset(tokens.Size.Size_600, tokens.Size.Size_600),
				}
				else nil,
			text = if Flags.FoundationEnableNewButtonSizes
				then {
					tag = "text-title-large",
				}
				else nil,
		},
	}

	local types: { [ButtonVariant]: VariantProps } = {
		[ButtonVariant.Emphasis] = {
			container = {
				style = tokens.Color.ActionEmphasis.Background,
				stroke = toStroke(tokens.Color.ActionEmphasis.Border),
			},
			content = {
				style = tokens.Color.ActionEmphasis.Foreground,
			},
		},
		[ButtonVariant.SubEmphasis] = {
			container = {
				style = tokens.Color.ActionSubEmphasis.Background,
				stroke = toStroke(tokens.Color.ActionSubEmphasis.Border),
				stateLayer = {
					mode = StateLayerMode.Inverse,
				},
			},
			content = {
				style = tokens.Color.ActionSubEmphasis.Foreground,
			},
		},
		[ButtonVariant.SoftEmphasis] = {
			container = {
				style = tokens.Color.ActionSoftEmphasis.Background,
				stroke = toStroke(tokens.Color.ActionSoftEmphasis.Border),
			},
			content = {
				style = tokens.Color.ActionSoftEmphasis.Foreground,
			},
		},
		[ButtonVariant.Standard] = {
			container = {
				style = tokens.Color.ActionStandard.Background,
				stroke = toStroke(tokens.Color.ActionStandard.Border),
			},
			content = {
				style = tokens.Color.ActionStandard.Foreground,
			},
		},
		[ButtonVariant.Subtle] = {
			container = {
				style = tokens.Color.ActionSubtle.Background,
				stroke = toStroke(tokens.Color.ActionSubtle.Border),
			},
			content = {
				style = tokens.Color.ActionSubtle.Foreground,
			},
		},
		[ButtonVariant.Alert] = {
			container = {
				style = tokens.Color.ActionAlert.Background,
				stroke = toStroke(tokens.Color.ActionAlert.Border),
			},
			content = {
				style = tokens.Color.ActionAlert.Foreground,
			},
		},
		[ButtonVariant.Text] = {
			content = {
				style = tokens.Color.Content.Emphasis,
			},
		},
		[ButtonVariant.Link] = {
			content = {
				style = tokens.Color.Content.Link,
			},
		},
	}

	return { common = common, sizes = sizes, types = types }
end

return function(tokens: Tokens, size: InputSize, variant: ButtonVariant): ButtonVariantProps
	local variants = VariantsContext.useVariants("Button", variants, tokens)
	return composeStyleVariant(variants.common, variants.sizes[size], variants.types[variant])
end
