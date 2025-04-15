local Root = script.Parent.Parent

local PurchaseError = require(Root.Enums.PurchaseError)
local Constants = require(Root.Misc.Constants)
local Promise = require(Root.Promise)

local function performCreatorStorePurchase(network, assetId, assetType)
	return network.performCreatorStorePurchase(assetId, assetType):andThen(function(result)
		if
			result.purchaseTransactionStatus == "PURCHASE_TRANSACTION_STATUS_ALREADY_OWNED"
			or result.purchaseTransactionStatus == "PURCHASE_TRANSACTION_STATUS_SUCCESS"
		then
			return Promise.resolve(result)
		else
			return Promise.reject(PurchaseError.UnknownFailure)
		end
	end, function(failure)
		return Promise.reject(PurchaseError.UnknownFailure)
	end)
end

return performCreatorStorePurchase