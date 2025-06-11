local Foundation = script:FindFirstAncestor("Foundation")
local CoreGui = require(Foundation.Utility.Wrappers).Services.CoreGui

local isCoreGui = pcall(function()
	local _ = CoreGui.Name
end)

return isCoreGui
