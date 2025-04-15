local Root = script.Parent.Parent
local isCreatorStoreAssetType = require(Root.Utils.isCreatorStoreAssetType)
local Promise = require(Root.Promise)

export type AssetInfoType = {
	id: number,
	type: string,
	typeId: number,
	creator: { [any]: any },
	description: string?,
	isPublicDomainEnabled: boolean?,
	name: string?,
}

local AssetInfoUtil = {}

function AssetInfoUtil.isAssetValid(asset): boolean
	-- Asset response data is only used for the creator store flow, so we only validate in that case.
	-- Otherwise, we default to VEP purchase flow where asset response data is irrelevant.
	if isCreatorStoreAssetType(asset.type) then
		-- Validate required fields
		if not (asset.id and asset.type and asset.typeId and asset.creator) then
			return false
		end
	end
	return true
end

function AssetInfoUtil.fromAsset(asset): AssetInfoType
	local assetInfo = {}

	-- Pruning response to only relevant fields
	assetInfo.id = asset.id
	assetInfo.type = asset.type
	assetInfo.typeId = asset.typeId
	assetInfo.creator = asset.creator
	assetInfo.description = asset.description
	assetInfo.isPublicDomainEnabled = asset.isPublicDomainEnabled
	assetInfo.name = asset.name

	return assetInfo
end

return AssetInfoUtil
