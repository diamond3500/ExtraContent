local Root = script.Parent.Parent
local CorePackages = game:GetService("CorePackages")

local PurchaseError = require(Root.Enums.PurchaseError)
local PaymentPlatform = require(Root.Enums.PaymentPlatform)

local RobuxUpsell = require(Root.Models.RobuxUpsell)

local Promise = require(Root.Promise)

-- Local implementation of payment platform conversion
-- See https://github.rbx.com/Roblox/payments-gateway/blob/master/services/payments-gateway-api/src/Models/Requests/GetUpsellProductRequest.cs for types
local function paymentPlatformToUpsellPlatform(paymentPlatform)
    if paymentPlatform == PaymentPlatform.Web then
        return "Web"
    elseif paymentPlatform == PaymentPlatform.Apple then
        return "AppleAppStore"
    elseif paymentPlatform == PaymentPlatform.Google then
        return "GooglePlayStore"
    elseif paymentPlatform == PaymentPlatform.Amazon then
        return "AmazonStore"
    elseif paymentPlatform == PaymentPlatform.UWP then
        return "WindowsStore"
    elseif paymentPlatform == PaymentPlatform.Xbox then
        return "XboxStore"
    elseif paymentPlatform == PaymentPlatform.Maquettes then
        return "MaquettesStore"
    elseif paymentPlatform == PaymentPlatform.Palisades then
        return "PalisadesStore"
    elseif paymentPlatform == PaymentPlatform.Microsoft then
        return "MicrosoftStore"
    else
        return "None"
    end
end

-- Flags
local GetFFlagEnabledEnhancedRobuxUpsell = require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagEnabledEnhancedRobuxUpsell

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
    if GetFFlagEnabledEnhancedRobuxUpsell then
        return EnhancedGetRobuxUpsellProduct(...)
    else
        return OriginalGetRobuxUpsellProduct(...)
    end
end

return getRobuxUpsellProduct
