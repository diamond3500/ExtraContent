local Root = script.Parent.Parent
local PurchaseError = require(Root.Enums.PurchaseError)
local Promise = require(Root.Promise)

local function getVngShopUrl(network: any)
	return network.getVngShopUrl()
		:andThen(function(getVngShopUrlResponse)
			return Promise.resolve(getVngShopUrlResponse)
		end)
		:catch(function(failure)
			return Promise.reject(PurchaseError.UnknownFailure)
		end)
end

return getVngShopUrl
