local Root = script.Parent.Parent
local RobuxUpsell = require(Root.Models.RobuxUpsell)

export type Json = {
	products: {
		[number]: RobuxUpsell.Json
	}
}
export type Suggestions = {
	products: {
		[number]: RobuxUpsell.Product
	}
}

local RobuxUpsellSuggestions = {}

function RobuxUpsellSuggestions.new(
	products: {
		[number]: RobuxUpsell.Product
	}
): Suggestions
	return {
		products = products,
	}
end

function RobuxUpsellSuggestions.fromJson(jsonData: Json): Suggestions
	local products = {}
	for productId, product in pairs(jsonData.products) do
		products[productId] = RobuxUpsell.fromJson(product)
	end
	return RobuxUpsellSuggestions.new(products)
end

return RobuxUpsellSuggestions
