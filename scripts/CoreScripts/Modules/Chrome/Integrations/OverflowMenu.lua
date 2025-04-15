local Chrome = script:FindFirstAncestor("Chrome")

local CorePackages = game:GetService("CorePackages")
local React = require(CorePackages.Packages.React)

local ChromeService = require(Chrome.Service)
local ChromeUtils = require(Chrome.ChromeShared.Service.ChromeUtils)
local ChromeIntegrationUtils = require(Chrome.Integrations.ChromeIntegrationUtils)
local MappedSignal = ChromeUtils.MappedSignal

local CommonIcon = require(Chrome.Integrations.CommonIcon)
local CommonFtuxTooltip = require(Chrome.Integrations.CommonFtuxTooltip)
local VRService = game:GetService("VRService")
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local PlayerListMaster = require(RobloxGui.Modules.PlayerList.PlayerListManager)
local EmotesMenuMaster = require(RobloxGui.Modules.EmotesMenu.EmotesMenuMaster)
local BackpackModule = require(RobloxGui.Modules.BackpackScript)
local LocalStore = require(Chrome.ChromeShared.Service.LocalStore)
local useMappedSignal = require(Chrome.ChromeShared.Hooks.useMappedSignal)
local SignalLib = require(CorePackages.Workspace.Packages.AppCommonLib)
local SquadExperimentation = require(CorePackages.Workspace.Packages.SocialExperiments).SquadExperimentation
local Signal = SignalLib.Signal

local UIBlox = require(CorePackages.Packages.UIBlox)
local Images = UIBlox.App.ImageSet.Images
local useStyle = UIBlox.Core.Style.useStyle
local ImageSetLabel = UIBlox.Core.ImageSet.ImageSetLabel

local useCallback = React.useCallback
local useEffect = React.useEffect
local useMemo = React.useMemo
local useState = React.useState

local Constants = require(Chrome.ChromeShared.Unibar.Constants)

local SelfieView = require(RobloxGui.Modules.SelfieView)

local AppChat = require(CorePackages.Workspace.Packages.AppChat)
local InExperienceAppChatExperimentation = AppChat.App.InExperienceAppChatExperimentation

local Songbird = require(CorePackages.Workspace.Packages.Songbird)
local useCurrentSong = Songbird.useCurrentSong

local GetFFlagUnpinUnavailable = require(Chrome.Flags.GetFFlagUnpinUnavailable)
local GetFStringConnectTooltipLocalStorageKey = require(Chrome.Flags.GetFStringConnectTooltipLocalStorageKey)
local FFlagEnableUnibarFtuxTooltips = require(CorePackages.Workspace.Packages.SharedFlags).FFlagEnableUnibarFtuxTooltips
local GetFIntRobloxConnectFtuxShowDelayMs = require(Chrome.Flags.GetFIntRobloxConnectFtuxShowDelayMs)
local GetFIntRobloxConnectFtuxDismissDelayMs = require(Chrome.Flags.GetFIntRobloxConnectFtuxDismissDelayMs)
local GetFFlagEnableAppChatInExperience =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagEnableAppChatInExperience
local GetShouldShowPlatformChatBasedOnPolicy = require(Chrome.Flags.GetShouldShowPlatformChatBasedOnPolicy)
local GetFFlagShouldShowMusicFtuxTooltip = require(Chrome.Flags.GetFFlagShouldShowMusicFtuxTooltip)
local GetFStringMusicTooltipLocalStorageKey = require(Chrome.Flags.GetFStringMusicTooltipLocalStorageKey)
local GetFIntMusicFtuxShowDelayMs = require(Chrome.Flags.GetFIntMusicFtuxShowDelayMs)
local GetFIntMusicFtuxDismissDelayMs = require(Chrome.Flags.GetFIntMusicFtuxDismissDelayMs)
local GetFFlagShouldShowMusicFtuxTooltipXTimes = require(Chrome.Flags.GetFFlagShouldShowMusicFtuxTooltipXTimes)
local GetFStringMusicTooltipLocalStorageKey_v2 = require(Chrome.Flags.GetFStringMusicTooltipLocalStorageKey_v2)
local GetFFlagEnableSongbirdInChrome = require(Chrome.Flags.GetFFlagEnableSongbirdInChrome)
local GetFFlagShouldShowSimpleMusicFtuxTooltip = require(Chrome.Flags.GetFFlagShouldShowSimpleMusicFtuxTooltip)

local SharedFlags = require(CorePackages.Workspace.Packages.SharedFlags)
local GetFFlagAppChatRebrandStringUpdates = SharedFlags.GetFFlagAppChatRebrandStringUpdates

local FFlagAppChatEnabledChromeDropdownFtuxTooltip =
	game:DefineFastFlag("AppChatEnabledChromeDropdownFtuxTooltip", false)
local shouldShowConnectTooltip = GetFFlagEnableAppChatInExperience()
	and FFlagEnableUnibarFtuxTooltips
	and InExperienceAppChatExperimentation.default.variant.ShowPlatformChatChromeDropdownEntryPoint
	and FFlagAppChatEnabledChromeDropdownFtuxTooltip
	and GetShouldShowPlatformChatBasedOnPolicy()

local shouldShowMusicTooltip = FFlagEnableUnibarFtuxTooltips
	and GetFFlagShouldShowMusicFtuxTooltip()
	and GetFFlagEnableSongbirdInChrome()

local SELFIE_ID = Constants.SELFIE_VIEW_ID
local ICON_SIZE = Constants.ICON_SIZE

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
				ChromeIntegrationUtils.dismissRobloxMenuAndRun(function()
					PlayerListMaster:SetVisibility(not PlayerListMaster:GetSetVisible())
				end)
			end
		end
	end,
	isActivated = function()
		return leaderboardVisibility:get()
	end,
	components = {
		Icon = function(props)
			return CommonIcon("icons/controls/leaderboardOff", "icons/controls/leaderboardOn", leaderboardVisibility)
		end,
	},
})
ChromeUtils.setCoreGuiAvailability(leaderboard, Enum.CoreGuiType.PlayerList)

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
			ChromeIntegrationUtils.dismissRobloxMenuAndRun(function()
				EmotesMenuMaster:open()
			end)
		end
	end,
	isActivated = function()
		return emotesVisibility:get()
	end,
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

ChromeUtils.setCoreGuiAvailability(emotes, Enum.CoreGuiType.EmotesMenu, function(available)
	coreGuiEmoteAvailable = available
	updateEmoteAvailability()
end)

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
			ChromeIntegrationUtils.dismissRobloxMenuAndRun(function()
				BackpackModule:OpenClose()
			end)
		end
	end,
	isActivated = function()
		return backpackVisibility:get()
	end,
	components = {
		Icon = function(props)
			return CommonIcon("icons/menu/inventoryOff", "icons/menu/inventory", backpackVisibility)
		end,
	},
})
ChromeUtils.setCoreGuiAvailability(backpack, Enum.CoreGuiType.Backpack)

local respawnPageOpen = false
local respawnPageOpenSignal = Signal.new()
local mappedRespawnPageOpenSignal = MappedSignal.new(respawnPageOpenSignal, function()
	return respawnPageOpen
end)

task.defer(function()
	local SettingsHub = require(RobloxGui.Modules.Settings.SettingsHub)
	SettingsHub.CurrentPageSignal:connect(function(pageName)
		respawnPageOpen = pageName == SettingsHub.Instance.ResetCharacterPage.Page.Name
		respawnPageOpenSignal:fire()
	end)
end)

local respawn = ChromeService:register({
	id = "respawn",
	label = "CoreScripts.InGameMenu.QuickActions.Respawn",
	activated = function(self)
		local SettingsHub = require(RobloxGui.Modules.Settings.SettingsHub)
		if SettingsHub:GetVisibility() then
			if respawnPageOpen then
				SettingsHub:SetVisibility(false)
			else
				SettingsHub:SwitchToPage(SettingsHub.Instance.ResetCharacterPage, true)
			end
		else
			SettingsHub:SetVisibility(true, false, SettingsHub.Instance.ResetCharacterPage)
		end
	end,
	isActivated = function()
		return mappedRespawnPageOpenSignal:get()
	end,
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

	local submenuOpen = submenuVisibility and useMappedSignal(submenuVisibility) or false

	-- Only show the Music Ftux Tooltip if a track with valid ISRC is encountered
	-- @aquach - Clean this block up once GetFFlagShouldShowSimpleMusicFtuxTooltip is cleaned up
	local songMeetsCriteria = false
	if
		shouldShowMusicTooltip
		and not GetFFlagShouldShowSimpleMusicFtuxTooltip()
		and GetFFlagShouldShowMusicFtuxTooltipXTimes()
	then
		local song = useCurrentSong()
		songMeetsCriteria = useMemo(function()
			return if song then song.meetsCriteria else false
		end, { song })
	end

	-- Tooltips should be shown one after the other (Connect, then Music)
	local hasUserAlreadySeenConnectTooltip = if shouldShowConnectTooltip
		then LocalStore.getValue(GetFStringConnectTooltipLocalStorageKey()) or false
		else true
	local hasUserAlreadySeenMusicTooltip = if GetFFlagShouldShowMusicFtuxTooltipXTimes()
		then LocalStore.getNumUniversesExposedTo(GetFStringMusicTooltipLocalStorageKey_v2())
			>= Constants.MAX_NUM_UNIVERSES_SHOWN
		else LocalStore.getValue(GetFStringMusicTooltipLocalStorageKey())

	local isMusicTooltipVisible, setMusicTooltipVisibility, onMusicTooltipDismissed
	if GetFFlagShouldShowMusicFtuxTooltipXTimes() then
		if GetFFlagShouldShowSimpleMusicFtuxTooltip() then
			isMusicTooltipVisible, setMusicTooltipVisibility =
				useState(shouldShowMusicTooltip and hasUserAlreadySeenConnectTooltip)

			useEffect(function()
				if not isMusicTooltipVisible and shouldShowMusicTooltip and hasUserAlreadySeenConnectTooltip then
					setMusicTooltipVisibility(true)
				end
			end, { isMusicTooltipVisible, shouldShowMusicTooltip, hasUserAlreadySeenConnectTooltip })

			onMusicTooltipDismissed = useCallback(function()
				LocalStore.addUniverseToExposureList(GetFStringMusicTooltipLocalStorageKey_v2(), game.GameId)
			end, { game.GameId })
		else
			isMusicTooltipVisible, setMusicTooltipVisibility =
				useState(shouldShowMusicTooltip and hasUserAlreadySeenConnectTooltip and songMeetsCriteria)

			useEffect(function()
				if
					not isMusicTooltipVisible
					and shouldShowMusicTooltip
					and hasUserAlreadySeenConnectTooltip
					and songMeetsCriteria
				then
					setMusicTooltipVisibility(true)
				end
			end, {
				isMusicTooltipVisible,
				shouldShowMusicTooltip,
				hasUserAlreadySeenConnectTooltip,
				songMeetsCriteria,
			})

			onMusicTooltipDismissed = useCallback(function()
				LocalStore.addUniverseToExposureList(GetFStringMusicTooltipLocalStorageKey_v2(), game.GameId)
			end, { game.GameId })
		end
	else
		isMusicTooltipVisible, setMusicTooltipVisibility =
			useState(shouldShowMusicTooltip and hasUserAlreadySeenConnectTooltip)
	end

	local onConnectTooltipDismissed = useCallback(function()
		setMusicTooltipVisibility(true)
	end)

	local connectTooltip = if shouldShowConnectTooltip
		then if shouldShowMusicTooltip and not hasUserAlreadySeenConnectTooltip
			then CommonFtuxTooltip({
				isIconVisible = props.visible,

				headerKey = if GetFFlagAppChatRebrandStringUpdates()
						and SquadExperimentation.getSquadEntrypointsEnabled()
					then "CoreScripts.FTUX.Heading.CheckOutRobloxParty"
					else "CoreScripts.FTUX.Heading.CheckOutRobloxConnect",
				bodyKey = if GetFFlagAppChatRebrandStringUpdates()
						and SquadExperimentation.getSquadEntrypointsEnabled()
					then "CoreScripts.FTUX.Label.PartyWithYourFriendsAnytime"
					else "CoreScripts.FTUX.Label.ChatWithYourFriendsAnytime",

				localStorageKey = GetFStringConnectTooltipLocalStorageKey(),

				showDelay = GetFIntRobloxConnectFtuxShowDelayMs(),
				dismissDelay = GetFIntRobloxConnectFtuxDismissDelayMs(),
				onDismissed = if shouldShowMusicTooltip then onConnectTooltipDismissed else nil,
			})
			else CommonFtuxTooltip({
				isIconVisible = props.visible,

				headerKey = if GetFFlagAppChatRebrandStringUpdates()
						and SquadExperimentation.getSquadEntrypointsEnabled()
					then "CoreScripts.FTUX.Heading.CheckOutRobloxParty"
					else "CoreScripts.FTUX.Heading.CheckOutRobloxConnect",
				bodyKey = if GetFFlagAppChatRebrandStringUpdates()
						and SquadExperimentation.getSquadEntrypointsEnabled()
					then "CoreScripts.FTUX.Label.PartyWithYourFriendsAnytime"
					else "CoreScripts.FTUX.Label.ChatWithYourFriendsAnytime",

				localStorageKey = GetFStringConnectTooltipLocalStorageKey(),

				showDelay = GetFIntRobloxConnectFtuxShowDelayMs(),
				dismissDelay = GetFIntRobloxConnectFtuxDismissDelayMs(),
			})
		else nil

	local musicTooltip = if isMusicTooltipVisible and not hasUserAlreadySeenMusicTooltip
		then CommonFtuxTooltip({
			isIconVisible = props.visible,

			headerKey = "CoreScripts.FTUX.Heading.MusicIsAvailable",
			bodyKey = "CoreScripts.FTUX.Label.MusicViewCurrentTrack",

			localStorageKey = if GetFFlagShouldShowMusicFtuxTooltipXTimes()
				then
					-- Prevents the tooltip from being shown again in an experience where it was already seen
					GetFStringMusicTooltipLocalStorageKey_v2()
						.. "_"
						.. tostring(game.GameId)
				else GetFStringMusicTooltipLocalStorageKey(),

			showDelay = GetFIntMusicFtuxShowDelayMs(),
			dismissDelay = GetFIntMusicFtuxDismissDelayMs(),
			onDismissed = if GetFFlagShouldShowMusicFtuxTooltipXTimes() then onMusicTooltipDismissed else nil,
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
		React.createElement(ImageSetLabel, {
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
		}),
		if SelfieView.useCameraOn()
				and not ChromeService:isWindowOpen(SELFIE_ID)
				and not submenuOpen
			then React.createElement(SelfieView.CameraStatusDot, {
				Name = "CameraStatusDot",
				Position = UDim2.new(1, -4, 1, -7),
				ZIndex = 2,
			})
			else nil,
		connectTooltip,
		musicTooltip,
	})
end

return ChromeService:register({
	initialAvailability = ChromeService.AvailabilitySignal.Pinned,
	notification = ChromeService:subMenuNotifications("nine_dot"),
	id = "nine_dot",
	label = "CoreScripts.TopBar.MoreMenu",
	components = {
		Icon = function(props)
			return React.createElement(HamburgerButton, props)
		end,
	},
})
