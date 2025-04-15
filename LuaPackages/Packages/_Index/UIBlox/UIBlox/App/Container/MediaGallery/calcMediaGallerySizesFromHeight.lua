-- moving this file to LuaApps, please replicate any changes in the LuaApps file as well
local MediaGallery = script.Parent
local Container = MediaGallery.Parent
local App = Container.Parent
local UIBlox = App.Parent
local UIBloxConfig = require(UIBlox.UIBloxConfig)

local getIconSize = require(App.ImageSet.getIconSize)
local IconSize = require(App.ImageSet.Enum.IconSize)

local calcMediaGallerySizesFromWidth = require(MediaGallery.calcMediaGallerySizesFromWidth)

local PADDING_MIDDLE = 24
local PADDING_ITEMS = 12

local IMAGE_RATIO = 16 / 9 -- width / height
local PAGINATION_ARROW_WIDTH = getIconSize(IconSize.Medium)

function calcMediaGallerySizesFromHeight(containerHeight: number, numberOfThumbnails: number, fullWidth: boolean?)
	-- reverse calculation of calcMediaGallerySizesFromWidth()
	local contentWidth = math.floor(
		(
			math.floor((containerHeight - PADDING_MIDDLE) * IMAGE_RATIO * numberOfThumbnails)
			+ PADDING_ITEMS * (numberOfThumbnails - 1)
			+ PAGINATION_ARROW_WIDTH * 2
			+ PAGINATION_ARROW_WIDTH * 2 * numberOfThumbnails
		) / (numberOfThumbnails + 1)
	)

	return calcMediaGallerySizesFromWidth(
		contentWidth,
		numberOfThumbnails,
		if UIBloxConfig.enableEdpComponentAlignment then fullWidth else nil
	)
end

return (
	if UIBloxConfig.moveMediaGalleryToLuaApps then nil else calcMediaGallerySizesFromHeight
) :: typeof(calcMediaGallerySizesFromHeight)
