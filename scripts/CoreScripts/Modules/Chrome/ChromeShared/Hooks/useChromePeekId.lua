local Root = script:FindFirstAncestor("ChromeShared")

local ChromeService = require(Root.Service)
local ChromeTypes = require(Root.Service.Types)
local useObservableValue = require(Root.Hooks.useObservableValue)

return function(): ChromeTypes.PeekId?
	return useObservableValue(ChromeService:peekId())
end
