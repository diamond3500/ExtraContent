local Chrome = script:FindFirstAncestor("Chrome")

local CorePackages = game:GetService("CorePackages")

local TopBarConstants = require(Chrome.Parent.TopBar.Constants)
local UnibarConstants = require(Chrome.ChromeShared.Unibar.Constants)

local GetFFlagChangeTopbarHeightCalculation = require(Chrome.Parent.TopBar.Flags.GetFFlagChangeTopbarHeightCalculation)
local GetFFlagFixSongbirdPeekUseFoundationIcons =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagFixSongbirdPeekUseFoundationIcons

local TOP_BAR_TOP_MARGIN = if GetFFlagChangeTopbarHeightCalculation() then TopBarConstants.TopBarTopMargin else 0

local MIN_TRACK_DETAILS_PIXEL_WIDTH = 48
local MAX_TRACK_DETAILS_PIXEL_WIDTH = 78

return {
	getPeekContainerPosition = function(style)
		return UDim2.fromOffset(0, TOP_BAR_TOP_MARGIN + style.Tokens.Global.Space_25)
	end,

	PEEK_CONTAINER_HEIGHT = if GetFFlagFixSongbirdPeekUseFoundationIcons() then 52 else 44,
	MIN_TRACK_DETAILS_WIDTH = MIN_TRACK_DETAILS_PIXEL_WIDTH / UnibarConstants.ICON_CELL_WIDTH,
	MAX_TRACK_DETAILS_WIDTH = MAX_TRACK_DETAILS_PIXEL_WIDTH / UnibarConstants.ICON_CELL_WIDTH,
	MUSIC_WINDOW_MAX_SIZE = Vector2.new(400, 80),
	AUDIO_REPORTING_WINDOW_MIN_HEIGHT = 420,
}
