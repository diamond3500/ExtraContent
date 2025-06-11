local Foundation = script:FindFirstAncestor("Foundation")
local Flags = require(Foundation.Utility.Flags)

if Flags.FoundationRefactorInputs then
	return require(script.Checkbox)
end

return require(script.Checkbox_DEPRECATED)
