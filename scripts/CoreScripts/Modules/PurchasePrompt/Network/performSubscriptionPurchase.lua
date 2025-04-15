local Root = script.Parent.Parent
local Promise = require(Root.Promise)
local parseSubscriptionError = require(Root.Utils.parseSubscriptionError)

local function performSubscriptionPurchase(network, subscriptionId, paymentMethod)
	return network.performSubscriptionPurchase(subscriptionId, paymentMethod):catch(function(failure)
		return Promise.reject(parseSubscriptionError(failure))
	end)
end

return performSubscriptionPurchase
