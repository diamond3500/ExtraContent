export type CreatorStoreProductInfoType = {
	basePrice: { [any]: any }?,
	purchasable: boolean?,
}

local CreatorStoreProductInfoUtil = {}

function CreatorStoreProductInfoUtil.fromProduct(product): CreatorStoreProductInfoType
	local productInfo = {}

    productInfo.basePrice = product.basePrice
	productInfo.purchasable = product.purchasable

	return productInfo
end

return CreatorStoreProductInfoUtil