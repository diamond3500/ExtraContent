local Foundation = script:FindFirstAncestor("Foundation")

local Types = require(Foundation.Components.Types)
type ColorStyleValue = Types.ColorStyleValue

local DialogSize = require(Foundation.Enums.DialogSize)
type DialogSize = DialogSize.DialogSize

local composeStyleVariant = require(Foundation.Utility.composeStyleVariant)
type VariantProps = composeStyleVariant.VariantProps

local Tokens = require(Foundation.Providers.Style.Tokens)
type Tokens = Tokens.Tokens

local VariantsContext = require(Foundation.Providers.Style.VariantsContext)

type DialogVariantProps = {
	container: {
		tag: string,
		margin: string,
	},
	dialog: {
		tag: string,
		maxWidth: number,
	},
}

local DIALOG_SIZES: { [DialogSize]: number } = {
	[DialogSize.Small] = 360,
	[DialogSize.Large] = 640,
}

local function variantsFactory(tokens: Tokens)
	local common = {
		container = {
			tag = "size-full-full col align-x-center align-y-center",
		},
		dialog = {
			tag = "size-full-0 auto-y shrink-1 bg-surface-100 clip radius-medium",
		},
	}

	local size: { [DialogSize]: VariantProps } = {
		[DialogSize.Small] = {
			container = {
				margin = "margin-small",
			},
			dialog = {
				maxWidth = DIALOG_SIZES[DialogSize.Small],
			},
		},
		[DialogSize.Large] = {
			container = {
				margin = "margin-large",
			},
			dialog = {
				maxWidth = DIALOG_SIZES[DialogSize.Large],
			},
		},
	}

	return { common = common, size = size }
end

return function(tokens: Tokens, size: DialogSize): DialogVariantProps
	local props = VariantsContext.useVariants("Dialog", variantsFactory, tokens)
	return composeStyleVariant(props.common, props.size[size] or props.size[DialogSize.Large])
end
