local Root = script.Parent.Parent

function isCreatorStoreAssetType(assetType: string)
	if assetType == nil or type(assetType) ~= "string" then
		return false
	end

	local creatorStoreAssetTypes = {
		"Model",
		"Plugin",
		"Audio",
		"Decal",
		"FontFamily",
		"MeshPart",
		"Video",
	}

	for _, creatorStoreAssetType in creatorStoreAssetTypes do
        if assetType == creatorStoreAssetType then
			return true
		end
	end

	return false
end

return isCreatorStoreAssetType