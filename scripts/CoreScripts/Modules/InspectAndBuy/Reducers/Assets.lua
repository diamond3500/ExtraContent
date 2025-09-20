--!nonstrict
local CorePackages = game:GetService("CorePackages")
local Cryo = require(CorePackages.Packages.Cryo)
local Rodux = require(CorePackages.Packages.Rodux)
local InspectAndBuyFolder = script.Parent.Parent
local AssetInfo = require(InspectAndBuyFolder.Models.AssetInfo)
local SetAssets = require(InspectAndBuyFolder.Actions.SetAssets)
local SetBundlesAssetIsPartOf = require(InspectAndBuyFolder.Actions.SetBundlesAssetIsPartOf)
local SetAssetFromBundleInfo = require(InspectAndBuyFolder.Actions.SetAssetFromBundleInfo)
local SetAvatarPreviewDetails = require(InspectAndBuyFolder.Actions.SetAvatarPreviewDetails)
local UpdateBulkPuchaseResults = require(InspectAndBuyFolder.Actions.UpdateBulkPuchaseResults)
local AvatarExperienceCommon = require(CorePackages.Workspace.Packages.AvatarExperienceCommon)
local ItemRestrictions = AvatarExperienceCommon.Enums.ItemRestrictions
local ItemType = AvatarExperienceCommon.Enums.ItemTypeEnum
local FFlagAXEnableFetchAvatarPreview = require(InspectAndBuyFolder.Flags.FFlagAXEnableFetchAvatarPreview)
local FFlagAXEnableInspectAndBuyBulkPurchase =
	require(CorePackages.Workspace.Packages.SharedFlags).FFlagAXEnableInspectAndBuyBulkPurchase

return Rodux.createReducer({}, {
	--[[
		Updates asset ownerships based on the bulk purchase results.
	]]
	[UpdateBulkPuchaseResults.name] = if FFlagAXEnableInspectAndBuyBulkPurchase
		then function(state, action: UpdateBulkPuchaseResults.UpdateBulkPuchaseResults)
			local items = action.result.Items
			for _, item in items do
				if item.type == Enum.MarketplaceProductType.AvatarAsset then
					-- check to see if the asset is a collectible using item restrictions status
					local itemRestrictions = state[item.id].itemRestrictions
					local nextAsset = Cryo.Dictionary.join({}, state[item.id])
					if
						itemRestrictions and itemRestrictions[ItemRestrictions.Collectible]
						or itemRestrictions[ItemRestrictions.Limited]
						or itemRestrictions[ItemRestrictions.LimitedUnique]
					then
						-- update the resellable count by 1 if the asset is a collectible
						nextAsset.resellableCount = nextAsset.resellableCount + 1
					end
					state[item.id] = Cryo.Dictionary.join(nextAsset, AssetInfo.fromBulkPurchaseResult(item))
				end
			end
			return state
		end
		else nil,
	--[[
		Set a group of assets, joining with any existing assets.
	]]
	[SetAssets.name] = function(state, action)
		local assets = {}

		for _, asset in ipairs(action.assets) do
			assert(asset.assetId ~= nil, "Expected an asset id when setting an asset's information.")
			local currentAsset = state[asset.assetId] or {}
			assets[asset.assetId] = Cryo.Dictionary.join(currentAsset, asset)
			if assets[asset.assetId] then
				assets[asset.assetId] = AssetInfo.getSaleDetailsForCollectibles(assets[asset.assetId])
			end
		end

		assets = Cryo.Dictionary.join(state, assets)

		return assets
	end,

	--[[
		Sets the avatar preview details to each AssetInfo
	]]
	[SetAvatarPreviewDetails.name] = if FFlagAXEnableFetchAvatarPreview
		then function(state, action: SetAvatarPreviewDetails.SetAvatarPreviewDetails)
			local avatarPreviewDetails = action.avatarPreviewDetails
			local look = avatarPreviewDetails.look
			if look.items then
				local assets = {}
				for _, item in look.items do
					if item.itemType == ItemType.Asset then
						assets[tostring(item.id)] = AssetInfo.fromAvatarPreviewItem(item)
					end
				end
				return Cryo.Dictionary.join(state, assets)
			end
			return state
		end
		else nil,

	--[[
		Sets the list of bundles an asset is part of. At this point
		the asset should already exist in the store. This is called
		after the user navigates to the details page.
	]]
	[SetBundlesAssetIsPartOf.name] = function(state, action)
		local assetId = tostring(action.assetId)
		local bundles = action.bundleIds
		local currentAsset = state[assetId] or {}
		local asset = AssetInfo.fromGetAssetBundles(assetId, bundles)
		asset = Cryo.Dictionary.join(currentAsset, asset)
		return Cryo.Dictionary.join(state, { [assetId] = asset })
	end,

	[SetAssetFromBundleInfo.name] = function(state, action)
		local bundleInfo = action.bundleInfo
		local assetId = tostring(action.assetId)
		local currentAsset = state[assetId] or {}
		local asset = AssetInfo.fromBundleInfo(assetId, bundleInfo)
		asset = Cryo.Dictionary.join(currentAsset, asset)

		return Cryo.Dictionary.join(state, { [assetId] = asset })
	end,
})
