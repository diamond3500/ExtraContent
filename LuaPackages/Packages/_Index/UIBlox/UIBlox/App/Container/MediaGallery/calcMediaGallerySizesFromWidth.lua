-- moving this file to LuaApps, please replicate any changes in the LuaApps file as well
local MediaGallery = script.Parent
local Container = MediaGallery.Parent
local App = Container.Parent
local UIBlox = App.Parent
local UIBloxConfig = require(UIBlox.UIBloxConfig)

local getIconSize = require(App.ImageSet.getIconSize)
local IconSize = require(App.ImageSet.Enum.IconSize)

local PADDING_MIDDLE = 24
local PADDING_ITEMS = 12

local IMAGE_RATIO = 16 / 9 -- width / height
local PAGINATION_ARROW_WIDTH = getIconSize(IconSize.Medium)

function calcMediaGallerySizesFromWidth(containerWidth: number, numberOfThumbnails: number, fullWidth: boolean?)
	local previewWidth = if UIBloxConfig.enableEdpComponentAlignment and fullWidth
		then containerWidth
		else containerWidth - PAGINATION_ARROW_WIDTH * 2
	local previewHeight = math.floor(previewWidth / IMAGE_RATIO)
	local thumbnailWidth
	if UIBloxConfig.enableEdpComponentAlignment and fullWidth then
		thumbnailWidth = math.floor((containerWidth - PADDING_ITEMS * (numberOfThumbnails - 1)) / numberOfThumbnails)
	else
		thumbnailWidth = math.floor(
			(containerWidth - PADDING_ITEMS * (numberOfThumbnails - 1) - PAGINATION_ARROW_WIDTH * 2)
				/ numberOfThumbnails
		)
	end
	local paginationWidth = if UIBloxConfig.enableEdpComponentAlignment and fullWidth
		then containerWidth + PAGINATION_ARROW_WIDTH * 2
		else containerWidth
	local paginationHeight = math.floor(thumbnailWidth / IMAGE_RATIO)
	local contentHeight = previewHeight + paginationHeight + PADDING_MIDDLE

	return {
		contentSize = UDim2.fromOffset(containerWidth, contentHeight),
		previewSize = UDim2.fromOffset(previewWidth, previewHeight),
		paginationSize = UDim2.fromOffset(paginationWidth, paginationHeight),
		thumbnailSize = UDim2.fromOffset(thumbnailWidth, paginationHeight),
	}
end

return (
	if UIBloxConfig.moveMediaGalleryToLuaApps then nil else calcMediaGallerySizesFromWidth
) :: typeof(calcMediaGallerySizesFromWidth)
