local Chrome = script:FindFirstAncestor("Chrome")

local CorePackages = game:GetService("CorePackages")
local React = require(CorePackages.Packages.React)

local ChromeService = require(Chrome.Service)
local ChromeUtils = require(Chrome.Service.ChromeUtils)
local MappedSignal = ChromeUtils.MappedSignal

local CommonIcon = require(Chrome.Integrations.CommonIcon)
local CommonFtuxTooltip = require(Chrome.Integrations.CommonFtuxTooltip)
local VRService = game:GetService("VRService")
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local PlayerListMaster = require(RobloxGui.Modules.PlayerList.PlayerListManager)
local EmotesMenuMaster = require(RobloxGui.Modules.EmotesMenu.EmotesMenuMaster)
local BackpackModule = require(RobloxGui.Modules.BackpackScript)
local Types = require(Chrome.Service.Types)
local useMappedSignal = require(Chrome.Hooks.useMappedSignal)
local SignalLib = require(CorePackages.Workspace.Packages.AppCommonLib)
local Signal = SignalLib.Signal

local UIBlox = require(CorePackages.UIBlox)
local Images = UIBlox.App.ImageSet.Images
local useStyle = UIBlox.Core.Style.useStyle
local ImageSetLabel = UIBlox.Core.ImageSet.ImageSetLabel

local Constants = require(Chrome.Unibar.Constants)
local SelfieView = require(RobloxGui.Modules.SelfieView)

local AppChat = require(CorePackages.Workspace.Packages.AppChat)
local InExperienceAppChatExperimentation = AppChat.App.InExperienceAppChatExperimentation

local GetFFlagSelfieViewV4 = require(RobloxGui.Modules.Flags.GetFFlagSelfieViewV4)
local GetFFlagUnpinUnavailable = require(Chrome.Flags.GetFFlagUnpinUnavailable)
local GetFFlagEnableHamburgerIcon = require(Chrome.Flags.GetFFlagEnableHamburgerIcon)
local GetFFlagEnableAlwaysOpenUnibar = require(RobloxGui.Modules.Flags.GetFFlagEnableAlwaysOpenUnibar)
local GetFFlagPostLaunchUnibarDesignTweaks = require(RobloxGui.Modules.Flags.GetFFlagPostLaunchUnibarDesignTweaks)
local GetFStringConnectTooltipLocalStorageKey = require(Chrome.Flags.GetFStringConnectTooltipLocalStorageKey)
local FFlagEnableUnibarFtuxTooltips = require(Chrome.Parent.Flags.FFlagEnableUnibarFtuxTooltips)
local GetFIntRobloxConnectFtuxShowDelayMs = require(Chrome.Flags.GetFIntRobloxConnectFtuxShowDelayMs)
local GetFIntRobloxConnectFtuxDismissDelayMs = require(Chrome.Flags.GetFIntRobloxConnectFtuxDismissDelayMs)
local GetFFlagFixCapturesAvailability = require(Chrome.Flags.GetFFlagFixCapturesAvailability)
local GetFFlagAddChromeActivatedEvents = require(Chrome.Flags.GetFFlagAddChromeActivatedEvents)
local GetFFlagEnableAppChatInExperience =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagEnableAppChatInExperience
local GetShouldShowPlatformChatBasedOnPolicy = require(Chrome.Flags.GetShouldShowPlatformChatBasedOnPolicy)

local shouldShowConnectTooltip = GetFFlagEnableAppChatInExperience()
	and FFlagEnableUnibarFtuxTooltips
	and InExperienceAppChatExperimentation.default.variant.ShowPlatformChatChromeDropdownEntryPoint
	and GetShouldShowPlatformChatBasedOnPolicy()

local SELFIE_ID = Constants.SELFIE_VIEW_ID
local ICON_SIZE = Constants.ICON_SIZE

function checkCoreGui(
	integration: { availability: ChromeUtils.AvailabilitySignal, id: Types.IntegrationId },
	coreGui,
	callback: (boolean) -> ()?
)
	ChromeUtils.setCoreGuiAvailability(integration, coreGui, function(available)
		if not available then
			ChromeService:removeUserPin(integration.id)
		end

		if callback then
			callback(available)
			return
		end

		if available then
			integration.availability:available()
		else
			integration.availability:unavailable()
		end
	end)
end

local leaderboardVisibility = MappedSignal.new(PlayerListMaster:GetSetVisibleChangedEvent().Event, function()
	return PlayerListMaster:GetSetVisible()
end)

local leaderboard = ChromeService:register({
	id = "leaderboard",
	label = "CoreScripts.TopBar.Leaderboard",
	activated = function(self)
		if VRService.VREnabled then
			local InGameMenu = require(RobloxGui.Modules.InGameMenu)
			InGameMenu.openPlayersPage()
		else
			if PlayerListMaster:GetSetVisible() then
				PlayerListMaster:SetVisibility(not PlayerListMaster:GetSetVisible())
			else
				ChromeUtils.dismissRobloxMenuAndRun(function()
					PlayerListMaster:SetVisibility(not PlayerListMaster:GetSetVisible())
				end)
			end
		end
	end,
	isActivated = if GetFFlagAddChromeActivatedEvents()
		then function()
			return leaderboardVisibility:get()
		end
		else nil,
	components = {
		Icon = function(props)
			return CommonIcon("icons/controls/leaderboardOff", "icons/controls/leaderboardOn", leaderboardVisibility)
		end,
	},
})
if not GetFFlagFixCapturesAvailability() and GetFFlagUnpinUnavailable() then
	checkCoreGui(leaderboard, Enum.CoreGuiType.PlayerList)
else
	ChromeUtils.setCoreGuiAvailability(leaderboard, Enum.CoreGuiType.PlayerList)
end

local emotesVisibility = MappedSignal.new(EmotesMenuMaster.EmotesMenuToggled.Event, function()
	return EmotesMenuMaster:isOpen()
end)
local emotes = ChromeService:register({
	id = "emotes",
	label = "CoreScripts.TopBar.Emotes",
	activated = function(self)
		if EmotesMenuMaster:isOpen() then
			EmotesMenuMaster:close()
		else
			--if self.chatWasHidden then
			--	ChatSelector:SetVisible(true)
			--	self.chatWasHidden = false
			--end
			ChromeUtils.dismissRobloxMenuAndRun(function()
				EmotesMenuMaster:open()
			end)
		end
	end,
	isActivated = if GetFFlagAddChromeActivatedEvents()
		then function()
			return emotesVisibility:get()
		end
		else nil,
	components = {
		Icon = function(props)
			return CommonIcon("icons/controls/emoteOff", "icons/controls/emoteOn", emotesVisibility)
		end,
	},
})

local coreGuiEmoteAvailable = false
local emoteMounted = EmotesMenuMaster.MenuIsVisible

function updateEmoteAvailability()
	if coreGuiEmoteAvailable and emoteMounted then
		emotes.availability:available()
	else
		emotes.availability:unavailable()
	end
end

if not GetFFlagFixCapturesAvailability() and GetFFlagUnpinUnavailable() then
	checkCoreGui(emotes, Enum.CoreGuiType.EmotesMenu, function(available)
		coreGuiEmoteAvailable = available
		updateEmoteAvailability()
	end)
else
	ChromeUtils.setCoreGuiAvailability(emotes, Enum.CoreGuiType.EmotesMenu, function(available)
		coreGuiEmoteAvailable = available
		updateEmoteAvailability()
	end)
end

EmotesMenuMaster.MenuVisibilityChanged.Event:Connect(function()
	emoteMounted = EmotesMenuMaster.MenuIsVisible
	updateEmoteAvailability()
end)

local backpackVisibility = MappedSignal.new(BackpackModule.StateChanged.Event, function()
	return BackpackModule.IsOpen
end)
local backpack = ChromeService:register({
	id = "backpack",
	label = "CoreScripts.TopBar.Inventory",
	activated = function(self)
		if BackpackModule.IsOpen then
			BackpackModule:OpenClose()
		else
			ChromeUtils.dismissRobloxMenuAndRun(function()
				BackpackModule:OpenClose()
			end)
		end
	end,
	isActivated = if GetFFlagAddChromeActivatedEvents()
		then function()
			return backpackVisibility:get()
		end
		else nil,
	components = {
		Icon = function(props)
			return CommonIcon("icons/menu/inventoryOff", "icons/menu/inventory", backpackVisibility)
		end,
	},
})
if not GetFFlagFixCapturesAvailability() and GetFFlagUnpinUnavailable() then
	checkCoreGui(backpack, Enum.CoreGuiType.Backpack)
else
	ChromeUtils.setCoreGuiAvailability(backpack, Enum.CoreGuiType.Backpack)
end

local respawnPageOpen, respawnPageOpenSignal, mappedRespawnPageOpenSignal
if GetFFlagAddChromeActivatedEvents() then
	respawnPageOpen = false
	respawnPageOpenSignal = Signal.new()
	mappedRespawnPageOpenSignal = MappedSignal.new(respawnPageOpenSignal, function()
		return respawnPageOpen
	end)

	task.defer(function()
		local SettingsHub = require(RobloxGui.Modules.Settings.SettingsHub)
		SettingsHub.CurrentPageSignal:connect(function(pageName)
			respawnPageOpen = pageName == SettingsHub.Instance.ResetCharacterPage.Page.Name
			respawnPageOpenSignal:fire()
		end)
	end)
end

local respawn = ChromeService:register({
	id = "respawn",
	label = "CoreScripts.InGameMenu.QuickActions.Respawn",
	activated = function(self)
		local SettingsHub = require(RobloxGui.Modules.Settings.SettingsHub)
		if GetFFlagAddChromeActivatedEvents() then
			if SettingsHub:GetVisibility() then
				if respawnPageOpen then
					SettingsHub:SetVisibility(false)
				else
					SettingsHub:SwitchToPage(SettingsHub.Instance.ResetCharacterPage, true)
				end
			else
				SettingsHub:SetVisibility(true, false, SettingsHub.Instance.ResetCharacterPage)
			end
		else
			SettingsHub:SetVisibility(true, false, SettingsHub.Instance.ResetCharacterPage)
			SettingsHub:SwitchToPage(SettingsHub.Instance.ResetCharacterPage)
		end
	end,
	isActivated = if GetFFlagAddChromeActivatedEvents()
		then function()
			return mappedRespawnPageOpenSignal:get()
		end
		else nil,
	components = {
		Icon = function(props)
			return CommonIcon("icons/actions/respawn")
		end,
	},
})

function updateRespawn(enabled)
	if enabled then
		respawn.availability:available()
	else
		respawn.availability:unavailable()
		if GetFFlagUnpinUnavailable() then
			ChromeService:removeUserPin(respawn.id)
		end
	end
end

task.defer(function()
	local SettingsHub = require(RobloxGui.Modules.Settings.SettingsHub)
	SettingsHub.RespawnBehaviourChangedEvent.Event:connect(updateRespawn)
	updateRespawn(SettingsHub:GetRespawnBehaviour())
end)

local currentSubMenu = ChromeService:currentSubMenu()
local submenuVisibility = MappedSignal.new(currentSubMenu:signal(), function()
	return currentSubMenu:get() == "nine_dot"
end)

if ChromeService:orderAlignment():get() == Enum.HorizontalAlignment.Right then
	submenuVisibility:connect(function(menuVisible)
		PlayerListMaster:SetMinimized(menuVisible)
	end)
end

function HamburgerButton(props)
	local toggleIconTransition = props.toggleTransition
	local style = useStyle()
	local iconColor = style.Theme.IconEmphasis

	local submenuOpen = submenuVisibility and useMappedSignal(submenuVisibility) or false

	local connectTooltip = if shouldShowConnectTooltip
		then CommonFtuxTooltip({
			isIconVisible = props.visible,

			headerKey = "CoreScripts.FTUX.Heading.CheckOutRobloxConnect",
			bodyKey = "CoreScripts.FTUX.Label.ChatWithYourFriendsAnytime",
			localStorageKey = GetFStringConnectTooltipLocalStorageKey(),

			showDelay = GetFIntRobloxConnectFtuxShowDelayMs(),
			dismissDelay = GetFIntRobloxConnectFtuxDismissDelayMs(),
		})
		else nil

	return React.createElement("Frame", {
		Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
		BorderSizePixel = 0,
		BackgroundColor3 = style.Theme.BackgroundOnHover.Color,
		BackgroundTransparency = toggleIconTransition:map(function(value): any
			return 1 - ((1 - style.Theme.BackgroundOnHover.Transparency) * value)
		end),
	}, {
		React.createElement("UICorner", {
			Name = "Corner",
			CornerRadius = UDim.new(1, 0),
		}) :: any,
		React.createElement(ImageSetLabel, {
			Name = "Overflow",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundTransparency = 1,
			Image = Images["icons/common/hamburgermenu"],
			Size = toggleIconTransition:map(function(value: any): any
				value = 1 - value
				return UDim2.new(0, Constants.ICON_SIZE * value, 0, Constants.ICON_SIZE * value)
			end),
			ImageColor3 = style.Theme.IconEmphasis.Color,

			ImageTransparency = toggleIconTransition:map(function(value: any): any
				return value * style.Theme.IconEmphasis.Transparency
			end),
		}) :: any,
		if GetFFlagPostLaunchUnibarDesignTweaks()
			then React.createElement(ImageSetLabel, {
				Name = "Close",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				BackgroundTransparency = 1,
				Image = Images["icons/navigation/close"],
				Size = toggleIconTransition:map(function(value: any): any
					return UDim2.new(0, Constants.MEDIUM_ICON_SIZE * value, 0, Constants.MEDIUM_ICON_SIZE * value)
				end),
				ImageColor3 = style.Theme.IconEmphasis.Color,

				ImageTransparency = toggleIconTransition:map(function(value: any): any
					return (1 - value) * style.Theme.IconEmphasis.Transparency
				end),
			})
			else nil,
		if not GetFFlagPostLaunchUnibarDesignTweaks()
			then React.createElement("Frame", {
				Name = "X1",
				Position = toggleIconTransition:map(function(value): any
					return UDim2.new(0.5, 0, 0.5, 0)
				end),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = toggleIconTransition:map(function(value: any): any
					return UDim2.new(0, 16 * value, 0, 2)
				end),
				BorderSizePixel = 0,
				BackgroundColor3 = iconColor.Color,
				BackgroundTransparency = toggleIconTransition:map(function(value: any): any
					return 1 - value
				end),
				Rotation = 45,
			}) :: any
			else nil,
		if not GetFFlagPostLaunchUnibarDesignTweaks()
			then React.createElement("Frame", {
				Name = "X2",
				Position = toggleIconTransition:map(function(value): any
					return UDim2.new(0.5, 0, 0.5, 0)
				end),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = toggleIconTransition:map(function(value: any): any
					return UDim2.new(0, 16 * value, 0, 2)
				end),
				BorderSizePixel = 0,
				BackgroundColor3 = iconColor.Color,
				BackgroundTransparency = toggleIconTransition:map(function(value: any): any
					return 1 - value
				end),
				Rotation = -45,
			}) :: any
			else nil,
		if GetFFlagSelfieViewV4()
				and SelfieView.useCameraOn()
				and not ChromeService:isWindowOpen(SELFIE_ID)
				and not submenuOpen
			then React.createElement(SelfieView.CameraStatusDot, {
				Name = "CameraStatusDot",
				Position = UDim2.new(1, -4, 1, -7),
				ZIndex = 2,
			})
			else nil,
		connectTooltip,
	})
end

return ChromeService:register({
	initialAvailability = if GetFFlagEnableAlwaysOpenUnibar()
		then ChromeService.AvailabilitySignal.Pinned
		else ChromeService.AvailabilitySignal.Available,
	notification = ChromeService:subMenuNotifications("nine_dot"),
	id = "nine_dot",
	label = "CoreScripts.TopBar.MoreMenu",
	components = {
		Icon = function(props)
			if GetFFlagEnableHamburgerIcon() then
				return React.createElement(HamburgerButton, props)
			else
				local icon = CommonIcon("icons/menu/9dot", "icons/menu/9dot", submenuVisibility)
				if shouldShowConnectTooltip then
					return React.createElement("Frame", {
						Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
						BorderSizePixel = 0,
						BackgroundTransparency = 1,
					}, {
						icon,
						CommonFtuxTooltip({
							isIconVisible = (props :: any).visible,

							headerKey = "CoreScripts.FTUX.Heading.CheckOutRobloxConnect",
							bodyKey = "CoreScripts.FTUX.Label.ChatWithYourFriendsAnytime",
							localStorageKey = GetFStringConnectTooltipLocalStorageKey(),

							showDelay = GetFIntRobloxConnectFtuxShowDelayMs(),
							dismissDelay = GetFIntRobloxConnectFtuxDismissDelayMs(),
						}) :: any,
					}) :: any
				else
					return icon
				end
			end
		end,
	},
})
