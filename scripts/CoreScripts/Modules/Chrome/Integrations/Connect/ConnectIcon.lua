local Chrome = script:FindFirstAncestor("Chrome")
local CorePackages = game:GetService("CorePackages")

local Cryo = require(CorePackages.Packages.Cryo)
local Foundation = require(CorePackages.Packages.Foundation)
local React = require(CorePackages.Packages.React)
local CommonFtuxTooltip = require(Chrome.Integrations.CommonFtuxTooltip)
local ChromeConstants = require(Chrome.ChromeShared.Unibar.Constants)
local ChromeUtils = require(Chrome.ChromeShared.Service.ChromeUtils)
local useMappedSignal = require(Chrome.ChromeShared.Hooks.useMappedSignal)
local usePartyIcon = require(Chrome.Integrations.Party.usePartyIcon)

local RoactUtils = require(CorePackages.Workspace.Packages.RoactUtils)
local dependencyArray = RoactUtils.Hooks.dependencyArray

local MappedSignal = ChromeUtils.MappedSignal
local useTokens = Foundation.Hooks.useTokens

local SubMenuContext = require(Chrome.ChromeShared.Unibar.SubMenuContext)
local GetFFlagAnimateSubMenu = require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagAnimateSubMenu

local AppChat = require(CorePackages.Workspace.Packages.AppChat)
local InExperienceAppChatModal = AppChat.App.InExperienceAppChatModal
local InExperienceAppChatExperimentation = AppChat.App.InExperienceAppChatExperimentation

local FFlagEnableUnibarFtuxTooltips = require(CorePackages.Workspace.Packages.SharedFlags).FFlagEnableUnibarFtuxTooltips
local FFlagEnableUnibarTooltipQueue = require(Chrome.Flags.FFlagEnableUnibarTooltipQueue)()
local GetFStringConnectTooltipLocalStorageKey = require(Chrome.Flags.GetFStringConnectTooltipLocalStorageKey)
local GetFIntRobloxConnectFtuxShowDelayMs = require(Chrome.Flags.GetFIntRobloxConnectFtuxShowDelayMs)
local GetFIntRobloxConnectFtuxDismissDelayMs = require(Chrome.Flags.GetFIntRobloxConnectFtuxDismissDelayMs)
local getAppChatNavbarItemConfig = AppChat.Utils.getAppChatNavbarItemConfig

local SharedFlags = require(CorePackages.Workspace.Packages.SharedFlags)
local GetFFlagAppChatRebrandStringUpdates = SharedFlags.GetFFlagAppChatRebrandStringUpdates
local FFlagConnectIconUsesAppChatConfig = game:DefineFastFlag("ConnectIconUsesAppChatConfig", false)
local FIntUnibarConnectIconTooltipPriority = game:DefineFastInt("UnibarConnectIconTooltipPriority", 1500)

local SquadExperimentation = require(CorePackages.Workspace.Packages.SocialExperiments).SquadExperimentation

local AVATAR_SIZE = 24

local ICON_OFF = "icons/menu/platformChatOff"
local ICON_ON = "icons/menu/platformChatOn"

if FFlagConnectIconUsesAppChatConfig then
	local visualConfig = getAppChatNavbarItemConfig()
	ICON_OFF = visualConfig.icon.off
	ICON_ON = visualConfig.icon.on
end

local ICON_SIZE = ChromeConstants.ICON_SIZE

export type Props = {
	integrationId: string,
	isIconVisible: boolean,
	shouldShowCustomBadge: boolean,
	isSquadIndicatorEnabled: boolean,
}

local defaultProps = {
	integrationId = "",
	shouldShowCustomBadge = true,
	isSquadIndicatorEnabled = false,
}

local function ConnectIcon(_props: Props): React.ReactElement
	local props = Cryo.Dictionary.union(defaultProps, _props)
	local tokens = useTokens()

	local unreadMessageCount, setUnreadMessageCount = React.useState(InExperienceAppChatModal.default.unreadCount)

	if props.shouldShowCustomBadge then
		React.useEffect(function()
			local connection = InExperienceAppChatModal.default.unreadCountSignal.Event:Connect(function(newUnreadCount)
				setUnreadMessageCount(newUnreadCount)
			end)
			return function()
				connection:Disconnect()
			end
		end, { setUnreadMessageCount })
	else
		unreadMessageCount = 0
	end

	local currentSquadId, setCurrentSquadId, badgeColor
	if props.isSquadIndicatorEnabled then
		currentSquadId, setCurrentSquadId = React.useState(InExperienceAppChatModal.default.currentSquadId)
	end

	React.useEffect(function()
		if props.isSquadIndicatorEnabled then
			local connection = InExperienceAppChatModal.default.currentSquadIdSignal.Event:Connect(
				function(currentSquadId)
					setCurrentSquadId(currentSquadId)
				end
			)
			return function()
				connection:Disconnect()
			end
		end
		return function() end
	end, dependencyArray(props.isSquadIndicatorEnabled, setCurrentSquadId))

	if props.isSquadIndicatorEnabled then
		if currentSquadId ~= "" then
			badgeColor = tokens.Color.System.Success
		elseif unreadMessageCount > 0 then
			badgeColor = tokens.Color.System.Contrast
		end
	end

	local shouldShowBadge = if props.isSquadIndicatorEnabled then badgeColor else unreadMessageCount > 0

	local visibilitySignal = MappedSignal.new(InExperienceAppChatModal.default.visibilitySignal.Event, function(visible)
		return InExperienceAppChatModal:getVisible()
	end)

	local tooltip = if FFlagEnableUnibarFtuxTooltips
			and InExperienceAppChatExperimentation.default.variant.ShowPlatformChatChromeUnibarEntryPoint
		then CommonFtuxTooltip({
			id = if FFlagEnableUnibarTooltipQueue then "CONNECT_ICON_TOOLTIP" else nil,
			priority = if FFlagEnableUnibarTooltipQueue then FIntUnibarConnectIconTooltipPriority else nil,
			isIconVisible = props.isIconVisible,

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

	local visible = useMappedSignal(visibilitySignal)
	local icon = usePartyIcon(ICON_SIZE, AVATAR_SIZE, if visible then ICON_ON else ICON_OFF)

	local submenuTransition = React.useContext(SubMenuContext)
	local function getTransparency(transparency: number): any
		return if GetFFlagAnimateSubMenu() and submenuTransition
			then submenuTransition:map(function(v)
				return transparency + (1 - transparency) * (1 - v)
			end)
			else transparency
	end

	return React.createElement(Foundation.View, {
		Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
	}, {
		Icon = React.createElement(Foundation.Image, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = icon.size:map(function(value)
				return UDim2.fromOffset(value, value)
			end),
			backgroundStyle = if icon.image.backgroundColor
				then {
					Color3 = icon.image.backgroundColor,
					Transparency = getTransparency(0),
				}
				else tokens.Color.None,
			cornerRadius = UDim.new(0, tokens.Radius.Circle),
			Image = icon.image.thumbnail,
			imageStyle = {
				Color3 = tokens.Color.Content.Emphasis.Color3,
				Transparency = getTransparency(tokens.Color.Content.Emphasis.Transparency),
			},
		}),
		Tooltip = tooltip,
		Badge = if shouldShowBadge
			then React.createElement(Foundation.View, {
				Position = UDim2.new(1, -tokens.Stroke.Thicker, 0, tokens.Stroke.Thicker),
				backgroundStyle = if props.isSquadIndicatorEnabled
					then {
						Color3 = badgeColor.Color3,
						Transparency = getTransparency(badgeColor.Transparency),
					}
					else {
						Color3 = tokens.Color.System.Contrast.Color3,
						Transparency = getTransparency(tokens.Color.System.Contrast.Transparency),
					},
				stroke = {
					Color = tokens.Color.Surface.Surface_0.Color3,
					Transparency = getTransparency(tokens.Color.Surface.Surface_0.Transparency),
					Thickness = tokens.Stroke.Thicker,
				},
				tag = "anchor-top-right radius-circle size-200 stroke-thicker",
				ZIndex = 2,
			})
			else nil,
	})
end

return ConnectIcon
