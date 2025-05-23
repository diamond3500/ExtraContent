local Root = script.Parent.Parent

local PurchaseError = require(Root.Enums.PurchaseError)
local Promise = require(Root.Promise)

local function deprecated_GetProductInfo(network, id, infoType)
	return network.getProductInfo(id, infoType):catch(function(failure)
		return Promise.reject(PurchaseError.UnknownFailureNoItemName)
	end)
end

return deprecated_GetProductInfo
