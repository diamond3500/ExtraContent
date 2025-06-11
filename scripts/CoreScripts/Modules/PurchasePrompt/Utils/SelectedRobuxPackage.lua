local CorePackages = game:GetService("CorePackages")
local FFlagEnableUpsellSuggestionsAPI = require(CorePackages.Workspace.Packages.SharedFlags).FFlagEnableUpsellSuggestionsAPI

-- nativeUpsell and robuxUpsellSuggestions.products[n] do not have the same schema, so this utility should help
-- keep the rest of the codebase clean as we transition to the new upsell flow. Function naming is based on the old upsell flow
local function getSelectedRobuxPackage(storeState)
	-- old flow
	if not FFlagEnableUpsellSuggestionsAPI then
		return storeState.nativeUpsell
	end

	-- new flow
	if not storeState.robuxUpsellSuggestions or not storeState.robuxUpsellSuggestions.products or not storeState.robuxUpsellSuggestions.selection then
		return nil
	end
	return storeState.robuxUpsellSuggestions.products[storeState.robuxUpsellSuggestions.selection]
end

local function getRobuxProductId(storeState)
	local package = getSelectedRobuxPackage(storeState)
	if not package then
		return nil
	end

	-- old flow
	if not FFlagEnableUpsellSuggestionsAPI then
		return package.robuxProductId
	end

	-- new flow
	return package.providerId
end

local function getProductId(storeState)
	local package = getSelectedRobuxPackage(storeState)
	if not package then
		return nil
	end

	return package.productId
end

local function getProductName(storeState)
	local package = getSelectedRobuxPackage(storeState)
	if not package then
		return nil
	end

	return package.productName
end

local function getRobuxPurchaseAmount(storeState)
	local package = getSelectedRobuxPackage(storeState)
	if not package then
		return nil
	end

	-- old flow
	if not FFlagEnableUpsellSuggestionsAPI then	
		return package.robuxPurchaseAmount
	end

	-- new flow
	return package.robuxAmount
end

local function getPrice(storeState)
	local package = getSelectedRobuxPackage(storeState)
	if not package then
		return nil
	end

	return package.price
end

local function getRobuxAmountBeforeBonus(storeState)
	local package = getSelectedRobuxPackage(storeState)
	if not package then
		return nil
	end

	return package.robuxAmountBeforeBonus
end

return {
	getRobuxProductId = getRobuxProductId,
	getProductId = getProductId,
	getProductName = getProductName,
	getRobuxPurchaseAmount = getRobuxPurchaseAmount,
	getRobuxAmountBeforeBonus = getRobuxAmountBeforeBonus,
	getPrice = getPrice,
}