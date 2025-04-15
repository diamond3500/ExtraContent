--!nonstrict
local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local RobloxTranslator = require(CorePackages.Workspace.Packages.RobloxTranslator)

local mockTranslator = require(script.Parent.mockTranslator)

return function()
	local coreScriptLocalization = CoreGui:FindFirstChild("CoreScriptLocalization")
	if coreScriptLocalization then
		return RobloxTranslator
	else
		return mockTranslator
	end
end