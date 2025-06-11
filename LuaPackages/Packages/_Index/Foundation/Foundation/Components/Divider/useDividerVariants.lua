local Foundation = script:FindFirstAncestor("Foundation")

local Types = require(Foundation.Components.Types)
type ColorStyleValue = Types.ColorStyleValue

local DividerVariant = require(Foundation.Enums.DividerVariant)
type DividerVariant = DividerVariant.DividerVariant

local composeStyleVariant = require(Foundation.Utility.composeStyleVariant)
type VariantProps = composeStyleVariant.VariantProps

local Tokens = require(Foundation.Providers.Style.Tokens)
type Tokens = Tokens.Tokens

local VariantsContext = require(Foundation.Providers.Style.VariantsContext)

type DividerVariantProps = {
	container: { tag: string },
	stroke: { tag: string, backgroundStyle: ColorStyleValue },
	line: { tag: string, position: UDim2, backgroundStyle: ColorStyleValue },
}

local function variantsFactory(tokens: Tokens)
	local common = {
		container = {
			tag = "size-full-0 auto-y col",
		},
		stroke = {
			tag = "size-full-50",
			backgroundStyle = tokens.Color.Stroke.Default,
		},
		line = {
			tag = "size-full-200",
			position = UDim2.new(0, 0, 0, tokens.Size.Size_50),
			backgroundStyle = tokens.Color.Common.HeavyDivider,
		},
	}

	local padding: { [DividerVariant]: VariantProps } = {
		[DividerVariant.Inset] = {
			container = {
				tag = "padding-x-xlarge",
			},
		},
		[DividerVariant.InsetLeft] = {
			container = {
				tag = "padding-left-xlarge",
			},
		},
		[DividerVariant.InsetRight] = {
			container = {
				tag = "padding-right-xlarge",
			},
		},
	}

	return { common = common, padding = padding }
end

return function(tokens: Tokens, variant: DividerVariant): DividerVariantProps
	local props = VariantsContext.useVariants("Divider", variantsFactory, tokens)
	return composeStyleVariant(props.common, props.padding[variant] or {})
end
