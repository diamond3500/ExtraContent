local Chrome = script:FindFirstAncestor("Chrome")

local CorePackages = game:GetService("CorePackages")

local Foundation = require(CorePackages.Packages.Foundation)
local React = require(CorePackages.Packages.React)
local Songbird = require(CorePackages.Workspace.Packages.Songbird)
local ChromeService = require(Chrome.Service)
local PeekConstants = require(Chrome.Integrations.MusicUtility.Constants)
local CommonIcon = require(Chrome.Integrations.CommonIcon)
local WindowSizeSignal = require(Chrome.ChromeShared.Service.WindowSizeSignal)

local ChromeUtils = require(Chrome.ChromeShared.Service.ChromeUtils)
local MappedSignal = ChromeUtils.MappedSignal

local MUSIC_WINDOW_MAX_SIZE = PeekConstants.MUSIC_WINDOW_MAX_SIZE

local windowSize = WindowSizeSignal.new(MUSIC_WINDOW_MAX_SIZE.X, MUSIC_WINDOW_MAX_SIZE.Y)

local mappedMusicOpenSignal = MappedSignal.new(ChromeService:onIntegrationStatusChanged(), function()
	return ChromeService:isWindowOpen("music_entrypoint")
end)

return ChromeService:register({
	initialAvailability = ChromeService.AvailabilitySignal.Available,
	id = "music_entrypoint",
	draggable = true,
	cachePosition = true,
	windowSize = windowSize,
	label = "CoreScripts.TopBar.Music",
	activated = function()
		ChromeService:toggleWindow("music_entrypoint")
	end,
	isActivated = function()
		return mappedMusicOpenSignal:get()
	end,
	components = {
		Icon = function(props)
			return CommonIcon("icons/common/music", "icons/common/musicFilled_medium", mappedMusicOpenSignal)
		end,
		Window = function()
			return React.createElement(Foundation.View, {
				tag = "auto-xy",
				onAbsoluteSizeChanged = function(rbx: GuiObject)
					windowSize:requestSize(rbx.AbsoluteSize.X, rbx.AbsoluteSize.Y)
				end,
			}, {
				ChromeWindowWrapper = React.createElement(Songbird.ChromeWindowWrapper, {
					onClose = function()
						ChromeService:toggleWindow("music_entrypoint")
					end,
				}),
			})
		end,
	},
})
