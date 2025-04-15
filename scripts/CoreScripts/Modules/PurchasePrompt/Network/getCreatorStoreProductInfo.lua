local Root = script.Parent.Parent

local PurchaseError = require(Root.Enums.PurchaseError)
local Promise = require(Root.Promise)

local function getCreatorStoreProductInfo(network, assetId: number, assetType: string)
	return network
		.getCreatorStoreProductInfo(assetId, assetType)
		:andThen(function(result)
			return Promise.resolve(result)
		end)
		:catch(function(failure)
			return Promise.reject(PurchaseError.UnknownFailure)
		end)
end

return getCreatorStoreProductInfo