local Foundation = script:FindFirstAncestor("Foundation")

local IconSize = require(Foundation.Enums.IconSize)
type IconSize = IconSize.IconSize

local useTokens = require(Foundation.Providers.Style.useTokens)

local function useIconSize(size: IconSize): UDim2
	local tokens = useTokens()

	local iconSizes = {
		[IconSize.XSmall :: IconSize] = tokens.Size.Size_200,
		[IconSize.Small :: IconSize] = tokens.Size.Size_400,
		[IconSize.Medium :: IconSize] = tokens.Size.Size_900,
		[IconSize.Large :: IconSize] = tokens.Size.Size_1200,
		[IconSize.XLarge :: IconSize] = tokens.Size.Size_2400,
		[IconSize.XXLarge :: IconSize] = 24 * tokens.Size.Size_200,
	}

	local iconSize = iconSizes[size]
	return UDim2.fromOffset(iconSize, iconSize)
end

return useIconSize
