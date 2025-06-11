local Foundation = script:FindFirstAncestor("Foundation")

local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

local VariantsContext = require(Foundation.Providers.Style.VariantsContext)
local composeStyleVariant = require(Foundation.Utility.composeStyleVariant)
type VariantProps = composeStyleVariant.VariantProps

local Tokens = require(Foundation.Providers.Style.Tokens)
type Tokens = Tokens.Tokens

type MenuItemVariantProps = {
	container: { tag: string },
	icon: { tag: string },
	text: { tag: string },
	check: { tag: string },
}

local variants = function(tokens: Tokens)
	local common = {
		container = { tag = "row align-y-center flex-x-between" },
		icon = { tag = "content-emphasis" },
		text = { tag = "content-emphasis auto-y grow text-align-x-left text-truncate-end" },
		check = { tag = "content-emphasis" },
	}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = {
			container = { tag = "size-full-600 radius-small padding-x-xsmall gap-xsmall" },
			icon = { tag = "size-400" },
			text = { tag = "text-title-small" },
			check = { tag = "size-300" },
		},
		[InputSize.Small] = {
			container = { tag = "size-full-800 radius-medium padding-x-small gap-xsmall" },
			icon = { tag = "size-500" },
			text = { tag = "text-title-small" },
			check = { tag = "size-400" },
		},
		[InputSize.Medium] = {
			container = { tag = "size-full-1000 radius-medium padding-x-small gap-small" },
			icon = { tag = "size-600" },
			text = { tag = "text-title-medium" },
			check = { tag = "size-500" },
		},
		[InputSize.Large] = {
			container = { tag = "size-full-1200 radius-medium padding-x-small gap-small" },
			icon = { tag = "size-700" },
			text = { tag = "text-title-large" },
			check = { tag = "size-600" },
		},
	}

	local isChecked = {
		[false] = { container = { tag = "" } },
		[true] = { container = { tag = "bg-surface-200" } },
	}

	return { common = common, sizes = sizes, isChecked = isChecked }
end

return function(tokens: Tokens, size: InputSize, isChecked: boolean): MenuItemVariantProps
	local variants = VariantsContext.useVariants("MenuItem", variants, tokens)
	return composeStyleVariant(variants.common, variants.sizes[size], variants.isChecked[isChecked])
end
