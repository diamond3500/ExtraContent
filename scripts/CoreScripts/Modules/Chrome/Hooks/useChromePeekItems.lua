local Chrome = script:FindFirstAncestor("Chrome")

local ChromeService = require(Chrome.Service)
local ChromeTypes = require(Chrome.Service.Types)
local useObservableValue = require(Chrome.Hooks.useObservableValue)

return function()
	return (useObservableValue(ChromeService:peekList()) or {}) :: ChromeTypes.PeekList
end
