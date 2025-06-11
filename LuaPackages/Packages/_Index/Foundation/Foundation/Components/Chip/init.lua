local Foundation = script:FindFirstAncestor("Foundation")

local Flags = require(Foundation.Utility.Flags)

if Flags.FoundationChipDesignUpdate then
	return require(script.Chip)
end

return require(script.Chip_DEPRECATED)
