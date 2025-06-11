local Foundation = script:FindFirstAncestor("Foundation")
local Flags = require(Foundation.Utility.Flags)

if Flags.FoundationRefactorInputs then
	return require(script.RadioGroupItem)
end

return require(script.RadioGroupItem_DEPRECATED)
