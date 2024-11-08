local Chrome = script:FindFirstAncestor("Chrome")

local ChromeService = require(Chrome.Service)
local useObservableValue = require(Chrome.Hooks.useObservableValue)

return function()
	return useObservableValue(ChromeService:status())
end
