local Root = script.Parent.Parent

type Json = {
	roblox_product_id: number, -- The database ID of the product.
	provider_product_id: string, -- The id of the product defined by the provider.
	roblox_product_name: string, -- The name of the product defined by Roblox.
	robux_amount: number, -- The amount of Robux this product grants.
	robux_amount_before_bonus: number?, -- The amount of Robux this product grants before bonus.
	price: string?, -- The formatted, localized price of the product.
}

export type Product = {
	id: number, -- The database ID of the product.
	providerId: string, -- The id of the product defined by the provider.
	productName: string, -- The name of the product defined by Roblox.
	robuxAmount: number, -- The amount of Robux this product grants.
	robuxAmountBeforeBonus: number?, -- The amount of Robux this product grants before bonus.
	price: string?, -- The formatted, localized price of the product.
}

local RobuxUpsellProduct = {}

function RobuxUpsellProduct.new(
	productId: number,
	providerId: string,
	productName: string,
	robuxAmount: number,
	price: string?
): Product
	return {
		id = productId,
		providerId = providerId,
		productName = productName,
		robuxAmount = robuxAmount,
		price = price,
	}
end

function RobuxUpsellProduct.fromJson(jsonData: Json): Product
	return {
		id = jsonData.roblox_product_id,
		providerId = jsonData.provider_product_id,
		productName = jsonData.roblox_product_name,
		robuxAmount = jsonData.robux_amount,
		robuxAmountBeforeBonus = jsonData.robux_amount_before_bonus,
		price = jsonData.price,
	}
end

return RobuxUpsellProduct
