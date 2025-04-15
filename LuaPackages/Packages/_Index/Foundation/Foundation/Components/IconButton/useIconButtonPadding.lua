local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local IconSize = require(Foundation.Enums.IconSize)
type IconSize = IconSize.IconSize

local useTokens = require(Foundation.Providers.Style.useTokens)

local function useIconButtonPadding(size: IconSize): number
	local tokens = useTokens()

	local iconButtonPaddings = React.useMemo(function()
		return {
			[IconSize.XSmall :: IconSize] = tokens.Size.Size_50,
			[IconSize.Small :: IconSize] = tokens.Size.Size_50,
			[IconSize.Medium :: IconSize] = tokens.Size.Size_100,
			[IconSize.Large :: IconSize] = tokens.Size.Size_150,
			[IconSize.XLarge :: IconSize] = tokens.Size.Size_200,
			[IconSize.XXLarge :: IconSize] = tokens.Size.Size_250,
		}
	end, { tokens })

	local padding = iconButtonPaddings[size]
	return padding
end

return useIconButtonPadding
