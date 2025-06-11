local Foundation = script:FindFirstAncestor("Foundation")
local Flags = require(Foundation.Utility.Flags)

if Flags.FoundationRefactorInputs then
	return require(script.Toggle)
end

return require(script.Toggle_DEPRECATED)
