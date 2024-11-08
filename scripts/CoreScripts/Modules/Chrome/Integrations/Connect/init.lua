local Chrome = script:FindFirstAncestor("Chrome")

local CorePackages = game:GetService("CorePackages")

local React = require(CorePackages.Packages.React)
local ChromeService = require(Chrome.Service)
local ConnectIcon = require(script.ConnectIcon)
local GetFFlagEnableAppChatInExperience =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagEnableAppChatInExperience
local AppChat = require(CorePackages.Workspace.Packages.AppChat)
local InExperienceAppChatExperimentation = AppChat.App.InExperienceAppChatExperimentation
local InExperienceAppChatModal = AppChat.App.InExperienceAppChatModal
local LocalStore = require(Chrome.Service.LocalStore)

local GetFFlagAppChatInExpConnectIconEnableSquadIndicator =
	require(Chrome.Flags.GetFFlagAppChatInExpConnectIconEnableSquadIndicator)
local GetFStringConnectTooltipLocalStorageKey = require(Chrome.Flags.GetFStringConnectTooltipLocalStorageKey)
local FFlagEnableUnibarFtuxTooltips = require(Chrome.Parent.Flags.FFlagEnableUnibarFtuxTooltips)
local GetShouldShowPlatformChatBasedOnPolicy = require(Chrome.Flags.GetShouldShowPlatformChatBasedOnPolicy)

local MouseIconOverrideService = require(CorePackages.InGameServices.MouseIconOverrideService)
local Symbol = require(CorePackages.Symbol)

local FFlagAppChatInExpUseUnibarNotification = game:DefineFastFlag("AppChatInExpUseUnibarNotification", false)
local FFlagAppChatInExpForceCursor = game:DefineFastFlag("AppChatInExpForceCursor", false)
-- "Connect" icon and option are used to open AppChat (InExperienceAppChat)
-- It will also serve as an entry point for Party

local integration = nil
if
	GetFFlagEnableAppChatInExperience()
	and InExperienceAppChatExperimentation.getShowPlatformChatInChrome()
	and GetShouldShowPlatformChatBasedOnPolicy()
then
	integration = ChromeService:register({
		id = "connect",
		label = "Feature.Chat.Label.Connect", -- intentially not translated
		activated = function()
			InExperienceAppChatModal:toggleVisibility()
			if FFlagEnableUnibarFtuxTooltips then
				LocalStore.storeForLocalPlayer(GetFStringConnectTooltipLocalStorageKey(), true)
			end
		end,
		isActivated = function()
			return InExperienceAppChatModal:getVisible()
		end,
		components = {
			Icon = function(props)
				return React.createElement(ConnectIcon, {
					isIconVisible = props.visible,
					shouldShowCustomBadge = not FFlagAppChatInExpUseUnibarNotification,
				})
			end,
		},
		initialAvailability = if InExperienceAppChatExperimentation.default.variant.ShowPlatformChatChromeUnibarEntryPoint
			then ChromeService.AvailabilitySignal.Pinned
			elseif
				InExperienceAppChatExperimentation.default.variant.ShowPlatformChatChromeDropdownEntryPoint
			then ChromeService.AvailabilitySignal.Available
			else ChromeService.AvailabilitySignal.Unavailable,
	})

	if FFlagAppChatInExpUseUnibarNotification then
		if GetFFlagAppChatInExpConnectIconEnableSquadIndicator() then
			local function updateNotificationBadge(newCount: number, hasCurrentSquad: boolean)
				-- The squad presence dot is prioritized over the unread count.
				if newCount == 0 or hasCurrentSquad then
					integration.notification:clear()
				else
					integration.notification:fireCount(newCount)
				end
			end

			InExperienceAppChatModal.default.currentSquadIdSignal.Event:Connect(function(currentSquadId)
				updateNotificationBadge(InExperienceAppChatModal.default.unreadCount, currentSquadId ~= "")
			end)

			InExperienceAppChatModal.default.unreadCountSignal.Event:Connect(function(newUnreadCount)
				updateNotificationBadge(newUnreadCount, InExperienceAppChatModal.default.currentSquadId ~= "")
			end)

			updateNotificationBadge(
				InExperienceAppChatModal.default.unreadCount,
				InExperienceAppChatModal.default.currentSquadId ~= ""
			)
		else
			local function updateUnreadMessageCount(newCount)
				if newCount == 0 then
					integration.notification:clear()
				else
					integration.notification:fireCount(newCount)
				end
			end

			InExperienceAppChatModal.default.unreadCountSignal.Event:Connect(function(newUnreadCount)
				updateUnreadMessageCount(newUnreadCount)
			end)

			updateUnreadMessageCount(InExperienceAppChatModal.default.unreadCount)
		end
	end

	if FFlagAppChatInExpForceCursor then
		-- Force the cursor to show when the AppChat modal is visible
		local MOUSE_OVERRIDE_KEY = Symbol.named("InExperienceRobloxConnect")
		InExperienceAppChatModal.default.visibilitySignal.Event:Connect(function(visible)
			if visible then
				MouseIconOverrideService.push(MOUSE_OVERRIDE_KEY, Enum.OverrideMouseIconBehavior.ForceShow)
			else
				MouseIconOverrideService.pop(MOUSE_OVERRIDE_KEY)
			end
		end)
	end
end

return integration
