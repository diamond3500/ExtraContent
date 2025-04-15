local Root = script.Parent.Parent

local PurchaseError = require(Root.Enums.PurchaseError)
local Promise = require(Root.Promise)
local getAssetInfo = require(Root.Network.getAssetInfo)
local getCreatorStoreProductInfo = require(Root.Network.getCreatorStoreProductInfo)
local Constants = require(Root.Misc.Constants)
local isCreatorStoreAssetType = require(Root.Utils.isCreatorStoreAssetType)
local AssetInfoUtil = require(Root.Utils.getAssetInfoUtil)
local CreatorStoreProductInfoUtil = require(Root.Utils.getCreatorStoreProductInfoUtil)

local function getProductInfo(network, id, infoType)
	if infoType == Enum.InfoType.Asset then
		return getAssetInfo(network, id)
			:andThen(function(assetInfo)
				local asset
				if assetInfo and assetInfo.data and assetInfo.data[1] then
					if not AssetInfoUtil.isAssetValid(assetInfo.data[1]) then
						return Promise.reject(PurchaseError.UnknownFailureNoItemName)
					end
					asset = AssetInfoUtil.fromAsset(assetInfo.data[1])
				end
				local assetType = (asset and asset.type) or ""

				if isCreatorStoreAssetType(assetType) then
					return getCreatorStoreProductInfo(network, id, assetType):andThen(function(result)
						local creatorStoreProduct = CreatorStoreProductInfoUtil.fromProduct(result)
						return {
							AssetId = asset.id,
							AssetType = assetType,
							AssetTypeId = asset.typeId,
							Creator = {
								CreatorTargetId = asset.creator.targetId,
								CreatorType = asset.creator.type,
							},
							Description = asset.description,
							IsFiatPriced = (
								creatorStoreProduct.basePrice
								and creatorStoreProduct.basePrice.quantity
								and creatorStoreProduct.basePrice.quantity.significand ~= 0
							),
							IsForSale = creatorStoreProduct.purchasable,
							IsPublicDomain = asset.isPublicDomainEnabled,
							Name = asset.name,
							PriceInRobux = 0,
							ProductId = asset.id,
						}
					end)
				else
					return network.getProductInfo(id, infoType):catch(function(failure)
						return Promise.reject(PurchaseError.UnknownFailureNoItemName)
					end)
				end
			end)
			:catch(function(failure)
				return Promise.reject(PurchaseError.UnknownFailureNoItemName)
			end)
	else
		return network.getProductInfo(id, infoType):catch(function(failure)
			return Promise.reject(PurchaseError.UnknownFailureNoItemName)
		end)
	end
end

return getProductInfo
