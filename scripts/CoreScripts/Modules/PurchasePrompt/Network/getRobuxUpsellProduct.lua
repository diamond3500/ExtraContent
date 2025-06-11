local Root = script.Parent.Parent
local CorePackages = game:GetService("CorePackages")

local PurchaseError = require(Root.Enums.PurchaseError)
local PaymentPlatform = require(Root.Enums.PaymentPlatform)

local RobuxUpsell = require(Root.Models.RobuxUpsell)

local Promise = require(Root.Promise)

local paymentPlatformToUpsellPlatform = require(Root.Utils.paymentPlatformToUpsellPlatform)

-- Flags
local FFlagEnabledEnhancedRobuxUpsellV2 = require(CorePackages.Workspace.Packages.SharedFlags).FFlagEnabledEnhancedRobuxUpsellV2

local function OriginalGetRobuxUpsellProduct(network, price, robuxBalance, paymentPlatform)
	local upsellPlatform = paymentPlatformToUpsellPlatform(paymentPlatform)
	return network.getRobuxUpsellProduct(price, robuxBalance, upsellPlatform)
		:andThen(function(result)
			local upsellProduct: RobuxUpsell.Product = RobuxUpsell.fromJson(result)
			if upsellProduct then
				return Promise.resolve(upsellProduct)
			else
				return Promise.reject(PurchaseError.UnknownFailure)
			end
		end)
		:catch(function(failure)
			return Promise.reject(PurchaseError.UnknownFailure)
		end)
end

local function EnhancedGetRobuxUpsellProduct(network, price: number, robuxBalance: number, paymentPlatform: string, itemProductId: number?, itemName: string?, universeId: number?)
    local upsellPlatform = paymentPlatformToUpsellPlatform(paymentPlatform)

    local promise
    if universeId ~= nil and itemProductId ~= nil then
        promise = network.getRobuxUpsellProductWithUniverseItemInfo(price, robuxBalance, upsellPlatform, itemProductId, itemName, universeId)
    else
        promise = network.getRobuxUpsellProduct(price, robuxBalance, upsellPlatform)
    end
    
    return promise
        :andThen(function(result)
            local upsellProduct: RobuxUpsell.Product = RobuxUpsell.fromJson(result)
            if upsellProduct then
                return Promise.resolve(upsellProduct)
            else
                return Promise.reject(PurchaseError.UnknownFailure)
            end
        end)
        :catch(function(failure)
            return Promise.reject(PurchaseError.UnknownFailure)
        end)
end

local function getRobuxUpsellProduct(...)
    if FFlagEnabledEnhancedRobuxUpsellV2 then
        return EnhancedGetRobuxUpsellProduct(...)
    else
        return OriginalGetRobuxUpsellProduct(...)
    end
end

return getRobuxUpsellProduct
