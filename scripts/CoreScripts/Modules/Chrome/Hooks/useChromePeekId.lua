local Chrome = script:FindFirstAncestor("Chrome")

local CorePackages = game:GetService("CorePackages")

local ChromeService = require(Chrome.Service)
local ChromeTypes = require(Chrome.Service.Types)
local useObservableValue = require(Chrome.Hooks.useObservableValue)

local GetFFlagFixPeekTogglingWhenSpammingUnibar =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagFixPeekTogglingWhenSpammingUnibar

return function(): ChromeTypes.PeekId?
	assert(GetFFlagFixPeekTogglingWhenSpammingUnibar(), "FFlagFixPeekTogglingWhenSpammingUnibar is not enabled")
	return useObservableValue(ChromeService:peekId())
end
