--!nonstrict
local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local Players = game:GetService("Players")
local VRService = game:GetService("VRService")
local TextChatService = game:GetService("TextChatService")

local SharedFlags = require(CorePackages.Workspace.Packages.SharedFlags)
local FFlagAdaptUnibarAndTiltSizing = SharedFlags.GetFFlagAdaptUnibarAndTiltSizing()

local Roact = require(CorePackages.Packages.Roact)
local React = require(CorePackages.Packages.React)
local RoactRodux = require(CorePackages.Packages.RoactRodux)
local t = require(CorePackages.Packages.t)
local UIBlox = require(CorePackages.Packages.UIBlox)
local Interactable = UIBlox.Core.Control.Interactable
local ControlState = UIBlox.Core.Control.Enum.ControlState
local Analytics = require(CorePackages.Workspace.Packages.Analytics).Analytics
local withStyle = UIBlox.Core.Style.withStyle
local ImageSetButton = UIBlox.Core.ImageSet.ImageSetButton
local Images = UIBlox.App.ImageSet.Images
local SelectionCursorProvider = UIBlox.App.SelectionImage.SelectionCursorProvider
local Songbird = require(CorePackages.Workspace.Packages.Songbird)

local GetFFlagFixChromeReferences = SharedFlags.GetFFlagFixChromeReferences

local Presentation = script.Parent.Presentation
local MenuIcon = require(Presentation.MenuIcon)
local ChatIcon = require(Presentation.ChatIcon)
local ConnectIcon = require(Presentation.ConnectIcon)
local MoreMenu = require(Presentation.MoreMenu)
local HealthBar = require(Presentation.HealthBar)
local HurtOverlay = require(Presentation.HurtOverlay)
local GamepadNavigationDialog = require(Presentation.GamepadNavigationDialog)
local HeadsetMenu = require(Presentation.HeadsetMenu)
local VoiceBetaBadge = require(Presentation.VoiceBetaBadge)
local BadgeOver13 = require(Presentation.BadgeOver13)

local Chrome = script.Parent.Parent.Parent.Chrome

local ChromeEnabled = require(Chrome.Enabled)
local GetShouldShowPlatformChatBasedOnPolicy = require(Chrome.Flags.GetShouldShowPlatformChatBasedOnPolicy)
local PeekConstants = require(Chrome.Integrations.MusicUtility.Constants)

local FFlagEnableChromeAnalytics = SharedFlags.GetFFlagEnableChromeAnalytics()

local FFlagConnectGamepadChrome = SharedFlags.GetFFlagConnectGamepadChrome()
local FFlagTiltIconUnibarFocusNav = SharedFlags.FFlagTiltIconUnibarFocusNav
local FFlagHideTopBarConsole = SharedFlags.FFlagHideTopBarConsole

local SocialExperiments = require(CorePackages.Workspace.Packages.SocialExperiments)
local TenFootInterfaceExpChatExperimentation = SocialExperiments.TenFootInterfaceExpChatExperimentation

local Unibar
local KeepOutAreasHandler
local ChromeAnalytics
if ChromeEnabled() then
	Unibar = require(Chrome.ChromeShared.Unibar)
end
if game:GetEngineFeature("InGameChromeSignalAPI") then
	KeepOutAreasHandler = require(Chrome.ChromeShared.Service.KeepOutAreasHandler)
	if FFlagEnableChromeAnalytics and (not GetFFlagFixChromeReferences() or ChromeEnabled()) then
		ChromeAnalytics = require(Chrome.ChromeShared.Analytics)
	end
end

local Connection = require(script.Parent.Connection)

local TopBar = Presentation.Parent.Parent
local Constants = require(TopBar.Constants)
local GetFFlagChangeTopbarHeightCalculation = require(TopBar.Flags.GetFFlagChangeTopbarHeightCalculation)
local FFlagEnableChromeBackwardsSignalAPI = require(TopBar.Flags.GetFFlagEnableChromeBackwardsSignalAPI)()
local FFlagUnibarMenuIconLayoutFix = require(TopBar.Flags.FFlagUnibarMenuIconLayoutFix)
local SetScreenSize = require(TopBar.Actions.SetScreenSize)
local SetKeepOutArea = require(TopBar.Actions.SetKeepOutArea)
local RemoveKeepOutArea = require(TopBar.Actions.RemoveKeepOutArea)
local MenuIconContext = if ChromeEnabled() and FFlagTiltIconUnibarFocusNav
	then require(script.Parent.MenuIconContext)
	else nil :: never
local GamepadMenu = nil
local GamepadConnector = nil
local FFlagAddMenuNavigationToggleDialog = nil
local MenuNavigationToggleDialog = nil
if ChromeEnabled() and FFlagConnectGamepadChrome then
	GamepadConnector = require(script.Parent.GamepadConnector)
	FFlagAddMenuNavigationToggleDialog = SharedFlags.FFlagAddMenuNavigationToggleDialog
	MenuNavigationToggleDialog = require(Presentation.GamepadMenu.MenuNavigationToggleDialog)
else
	GamepadMenu = require(Presentation.GamepadMenu)
end

local TenFootInterface = require(RobloxGui.Modules.TenFootInterface)
local isNewInGameMenuEnabled = require(RobloxGui.Modules.isNewInGameMenuEnabled)
local isNewTiltIconEnabled = require(RobloxGui.Modules.isNewTiltIconEnabled)
local GetFFlagBetaBadge = require(RobloxGui.Modules.Flags.GetFFlagBetaBadge)
local FFlagTopBarUseNewBadge = game:DefineFastFlag("TopBarUseNewBadge", false)
local FFlagControlBetaBadgeWithGuac = game:DefineFastFlag("ControlBetaBadgeWithGuac", false)
local FFlagVRMoveVoiceIndicatorToBottomBar = require(RobloxGui.Modules.Flags.FFlagVRMoveVoiceIndicatorToBottomBar)
local FFlagGamepadNavigationDialogABTest = require(TopBar.Flags.FFlagGamepadNavigationDialogABTest)
local GetFFlagEnableCrossExpVoice = SharedFlags.GetFFlagEnableCrossExpVoice
local GetFFlagEnablePartyIconInNonChrome = SharedFlags.GetFFlagEnablePartyIconInNonChrome

local PartyMicBinder = require(script.Parent.Parent.Parent.Chrome.Integrations.Party.PartyMicBinder)

local GetFFlagFixSeamlessVoiceIntegrationWithPrivateVoice =
	SharedFlags.GetFFlagFixSeamlessVoiceIntegrationWithPrivateVoice
local GetFFlagEnableJoinVoiceOnUnibar = SharedFlags.GetFFlagEnableJoinVoiceOnUnibar

local JoinVoiceBinder
if
	game:GetEngineFeature("VoiceChatSupported")
	and GetFFlagEnableJoinVoiceOnUnibar()
	and GetFFlagFixSeamlessVoiceIntegrationWithPrivateVoice()
	and ChromeEnabled()
then
	JoinVoiceBinder = require(script.Parent.Parent.Parent.Chrome.Integrations.JoinVoiceBinder)
end

local VoiceChatServiceManager = require(RobloxGui.Modules.VoiceChat.VoiceChatServiceManager).default
local VoiceStateContext = require(RobloxGui.Modules.VoiceChat.VoiceStateContext)
local TopBarAppPolicy = require(script.Parent.Parent.TopBarAppPolicy)

local UseUpdatedHealthBar = ChromeEnabled()

-- vr bottom bar
local VRBottomBar = require(RobloxGui.Modules.VR.VRBottomBar.VRBottomBar)

local function selectMenuOpen(state)
	return state.displayOptions.menuOpen or state.displayOptions.inspectMenuOpen
end

local TopBarApp = Roact.PureComponent:extend("TopBarApp")

TopBarApp.validateProps = t.strictInterface({
	menuOpen = t.optional(t.boolean),
	inspectMenuOpen = t.optional(t.boolean),
	displayBetaBadge = t.boolean,

	setScreenSize = t.callback,
	setKeepOutArea = t.callback,
	removeKeepOutArea = t.callback,
	showBadgeOver12 = t.optional(t.boolean),
})

function TopBarApp:init()
	self.unibarRightSidePosition, self.setUnibarRightSidePosition = Roact.createBinding(UDim2.new())
	self.closeButtonState, self.setCloseButtonState = Roact.createBinding(false)
	self.badgeOver13Visible, self.setBadgeOver13Visible = Roact.createBinding(false)
	self.onCloseBtnStateChange = function(_, newControlState)
		self.setCloseButtonState(newControlState)
	end
	if ChromeEnabled() then
		local ChromeService = require(Chrome.Service)
		self:setState({
			unibarAlignment = ChromeService:orderAlignment():get(),
		})

		if FFlagConnectGamepadChrome then
			if FFlagHideTopBarConsole then
				-- in flag cleanup, replace `self.GamepadConnector` with just `GamepadConnector`
				self.GamepadConnector = GamepadConnector
			else
				self.GamepadConnector = GamepadConnector.new()
			end
		end

		if FFlagTiltIconUnibarFocusNav then
			self.unibarMenuRef = React.createRef()
			self.menuIconRef = Roact.createRef()
		end
	end

	if TenFootInterfaceExpChatExperimentation.getIsEnabled() then
		-- This chatVersion may be inaccurate if the game isn't loaded
		self:setState({
			chatVersion = TextChatService.ChatVersion,
		})

		-- If the game isn't loaded, then set the real chat version when the game is loaded
		if not game:IsLoaded() then
			game.Loaded:Connect(function()
				self:setState({
					chatVersion = TextChatService.ChatVersion,
				})
			end)
		end
	end
end

function TopBarApp:didMount()
	if ChromeEnabled() then
		local ChromeService = require(Chrome.Service)
		self.orderAlignmentConnection = ChromeService:orderAlignment():connect(function()
			self:setState({
				unibarAlignment = ChromeService:orderAlignment():get(),
			})
		end)

		if FFlagConnectGamepadChrome then
			self.GamepadConnector:connectToTopbar()
		end
	end
end

function TopBarApp:willUnmount()
	if ChromeEnabled() then
		if self.orderAlignmentConnection then
			self.orderAlignmentConnection:disconnect()
			self.orderAlignmentConnection = nil
		end

		if FFlagConnectGamepadChrome then
			self.GamepadConnector:disconnectFromTopbar()
		end
	end
end

function TopBarApp:render()
	return withStyle(function(style)
		return self:renderWithStyle(style)
	end)
end

function TopBarApp:renderWithStyle(style)
	local chromeEnabled = ChromeEnabled()
	local showBetaBadge = GetFFlagBetaBadge() and not chromeEnabled
	local policyAllowsBetaBadge
	if FFlagControlBetaBadgeWithGuac then
		policyAllowsBetaBadge = self.props.displayBetaBadge
	end

	local unibarAlignment = Enum.HorizontalAlignment.Right
	if self.state.unibarAlignment ~= nil then
		unibarAlignment = self.state.unibarAlignment
	end

	local screenSideOffset = Constants.ScreenSideOffset
	local topBarHeight = if not isNewTiltIconEnabled() then 36 else Constants.TopBarHeight
	if GetFFlagChangeTopbarHeightCalculation() then
		topBarHeight = Constants.TopBarHeight
	end

	if TenFootInterface:IsEnabled() then
		if not FFlagUnibarMenuIconLayoutFix or not ChromeEnabled() then
			screenSideOffset = Constants.ScreenSideOffsetTenFoot
			topBarHeight = Constants.TopBarHeightTenFoot
		end
	end
	local isTopBarVisible = not (self.props.menuOpen or self.props.inspectMenuOpen)
	local topBarFramePosition =
		UDim2.new(0, 0, 0, if GetFFlagChangeTopbarHeightCalculation() then Constants.TopBarTopMargin else 0)
	local topBarFrameHeight = topBarHeight - Constants.TopBarTopMargin
	local topBarLeftFramePosition = UDim2.new(0, screenSideOffset, 0, 0)
	local topBarRightFramePosition = UDim2.new(1, -screenSideOffset, 0, 0)
	local topBarRightUnibarFramePosition = UDim2.new(1, -screenSideOffset, 0, Constants.TopBarTopMargin)
	local closeMenuButtonPosition = UDim2.new(0, 0, 0.5, 0)

	local bottomBar = if FFlagVRMoveVoiceIndicatorToBottomBar
		then Roact.createElement(VoiceStateContext.Provider, {}, {
			VRBottomBar = VoiceStateContext.withVoiceState(function(voiceContext)
				return Roact.createElement(VRBottomBar, {
					voiceChatServiceManager = VoiceChatServiceManager,
					voiceEnabled = voiceContext.voiceEnabled,
					voiceState = voiceContext.voiceState,
				})
			end),
		})
		else Roact.createElement(VRBottomBar)

	local newMenuIcon = Roact.createElement(MenuIcon, {
		iconScale = if self.props.menuOpen then 1.25 else 1,
		layoutOrder = 1,
		showBadgeOver12 = self.props.showBadgeOver12,
		menuIconRef = if chromeEnabled and FFlagTiltIconUnibarFocusNav then self.menuIconRef else nil :: never,
		unibarMenuRef = if chromeEnabled and FFlagTiltIconUnibarFocusNav then self.unibarMenuRef else nil :: never,
	})
	newMenuIcon = Roact.createElement(SelectionCursorProvider, {}, {
		Icon = newMenuIcon,
	})

	return Roact.createElement("ScreenGui", {
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		AutoLocalize = false,
		DisplayOrder = 6,

		[Roact.Change.AbsoluteSize] = function(rbx)
			self.props.setScreenSize(rbx.AbsoluteSize)
		end,
	}, {
		Connection = Roact.createElement(Connection),
		GamepadMenu = if not FFlagConnectGamepadChrome
			then if TenFootInterfaceExpChatExperimentation.getIsEnabled()
				then Roact.createElement(GamepadMenu, {
					chatVersion = self.state.chatVersion,
				})
				else Roact.createElement(GamepadMenu)
			else nil,
		MenuNavigationToggleDialog = if chromeEnabled
				and FFlagAddMenuNavigationToggleDialog
				and FFlagConnectGamepadChrome
			then Roact.createElement(MenuNavigationToggleDialog, {
				Position = UDim2.fromScale(0.5, 0.1),
				GamepadConnector = if FFlagTiltIconUnibarFocusNav then self.GamepadConnector else nil :: never,
			})
			else nil,
		GamepadNavigationDialog = if FFlagGamepadNavigationDialogABTest
			then Roact.createElement(GamepadNavigationDialog)
			else nil,
		HeadsetMenu = Roact.createElement(HeadsetMenu),
		VRBottomBar = VRService.VREnabled and bottomBar or nil,
		KeepOutAreasHandler = if FFlagEnableChromeBackwardsSignalAPI and KeepOutAreasHandler
			then Roact.createElement(KeepOutAreasHandler)
			else nil,

		FullScreenFrame = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Visible = isTopBarVisible,
		}, {
			HurtOverlay = Roact.createElement(HurtOverlay),
		}),

		MenuIconHolder = isNewTiltIconEnabled() and Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.new(
				0,
				screenSideOffset,
				0,
				if GetFFlagChangeTopbarHeightCalculation() then Constants.TopBarTopMargin else 0
			),
			Size = UDim2.new(
				1,
				0,
				0,
				if GetFFlagChangeTopbarHeightCalculation() then topBarFrameHeight else topBarHeight
			),
		}, {
			MenuIcon = newMenuIcon,
		}),

		--Remove with isNewInGameMenuEnabled
		LegacyCloseMenu = not Unibar and not isNewInGameMenuEnabled() and Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, screenSideOffset, 0, 0),
			Size = UDim2.new(1, 0, 0, topBarHeight),
			Visible = self.props.menuOpen,
		}, {
			-- Backup  Unibar Impl
			CloseMenuButtonRound = Unibar and Roact.createElement(Interactable, {
				onStateChanged = self.onCloseBtnStateChange,
				Visible = not TenFootInterface:IsEnabled(),
				BackgroundTransparency = style.Theme.Overlay.Transparency,
				Position = closeMenuButtonPosition,
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, Constants.LegacyCloseMenuIconSize, 0, Constants.LegacyCloseMenuIconSize),
				BackgroundColor3 = style.Theme.Overlay.Color,
				[Roact.Event.Activated] = function()
					local SettingsHub = require(RobloxGui.Modules.Settings.SettingsHub)
					SettingsHub:ToggleVisibility()
				end,
			}, {

				UICorner = chromeEnabled and Roact.createElement("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}) or nil,

				Line1 = Roact.createElement("Frame", {
					Name = "TopLine",
					Position = UDim2.new(0.5, 0, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0),
					Size = UDim2.new(0, 16, 0, 2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.new(1, 1, 1),
					Rotation = 45,
				}) :: any,
				Line2 = Roact.createElement("Frame", {
					Name = "BottomLine",
					Position = UDim2.new(0.5, 0, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0),
					Size = UDim2.new(0, 16, 0, 2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.new(1, 1, 1),
					Rotation = -45,
				}) :: any,

				StateOverlayRound = not chromeEnabled and Roact.createElement("Frame", {
					BackgroundTransparency = self.closeButtonState:map(function(controlState)
						if controlState == ControlState.Pressed then
							return style.Theme.BackgroundOnPress.Transparency
						elseif controlState == ControlState.Hover then
							return style.Theme.BackgroundOnHover.Transparency
						else
							return 1
						end
					end),
					BackgroundColor3 = self.closeButtonState:map(function(controlState)
						if controlState == ControlState.Pressed then
							return style.Theme.BackgroundOnPress.Color
						elseif controlState == ControlState.Hover then
							return style.Theme.BackgroundOnHover.Color
						end

						return Color3.new(1, 1, 1)
					end),
					Size = UDim2.fromScale(1, 1),
					ZIndex = 2,
				}, {
					UICorner = chromeEnabled and Roact.createElement("UICorner", {
						CornerRadius = UDim.new(1, 0),
					}) or nil,
				}) or nil,
			}) or nil,

			CloseMenuButton = not Unibar and Roact.createElement(ImageSetButton, {
				Visible = not TenFootInterface:IsEnabled(),
				BackgroundTransparency = 1,
				Position = closeMenuButtonPosition,
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, Constants.LegacyCloseMenuIconSize, 0, Constants.LegacyCloseMenuIconSize),
				Image = Images["icons/controls/close-ingame"],

				[Roact.Event.Activated] = function()
					local SettingsHub = require(RobloxGui.Modules.Settings.SettingsHub)
					SettingsHub:ToggleVisibility()
				end,
			}) or nil,
		}),

		SongbirdDebugAudio = Roact.createElement(Songbird.DebugAudioEmitters),

		SongbirdReportAudioFrame = ChromeEnabled() and Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, 0, 0, PeekConstants.AUDIO_REPORTING_WINDOW_MIN_HEIGHT),
		}, {
			ReportAudioPopup = Roact.createElement(Songbird.ReportAudioPopup),
		}),

		UnibarLeftFrame = Unibar
				and unibarAlignment == Enum.HorizontalAlignment.Left
				and Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(
						1,
						0,
						0,
						if GetFFlagChangeTopbarHeightCalculation() then topBarFrameHeight else topBarHeight
					),
					Position = if GetFFlagChangeTopbarHeightCalculation()
						then topBarRightUnibarFramePosition
						else topBarRightFramePosition,
					AnchorPoint = Vector2.new(1, 0),
				}, {
					JoinVoiceBinder = if chromeEnabled and JoinVoiceBinder
						then Roact.createElement(JoinVoiceBinder)
						else nil,
					PartyMicBinder = if chromeEnabled and GetFFlagEnableCrossExpVoice()
						then Roact.createElement(PartyMicBinder)
						else nil,
					ChromeAnalytics = if ChromeAnalytics then Roact.createElement(ChromeAnalytics) else nil,
					KeepOutAreasHandler = if not FFlagEnableChromeBackwardsSignalAPI and KeepOutAreasHandler
						then Roact.createElement(KeepOutAreasHandler)
						else nil,
					Padding = Roact.createElement("UIPadding", {
						PaddingTop = UDim.new(0, Constants.UnibarFrame.PaddingTop),
						PaddingBottom = UDim.new(0, Constants.UnibarFrame.PaddingBottom),
						PaddingLeft = UDim.new(0, Constants.UnibarFrame.PaddingLeft),
					}),

					Unibar = if FFlagTiltIconUnibarFocusNav
						then React.createElement(MenuIconContext.Provider, {
							value = {
								menuIconRef = self.menuIconRef,
							},
						}, {
							React.createElement(Unibar, {
								layoutOrder = 1,
								onAreaChanged = self.props.setKeepOutArea,
								onMinWidthChanged = function(width: number)
									self.setUnibarRightSidePosition(UDim2.new(0, width, 0, 0))
								end,
								menuRef = if chromeEnabled and FFlagTiltIconUnibarFocusNav
									then self.unibarMenuRef
									else nil :: never,
							}),
						})
						else Roact.createElement(Unibar, {
							layoutOrder = 1,
							onAreaChanged = self.props.setKeepOutArea,
							onMinWidthChanged = function(width: number)
								self.setUnibarRightSidePosition(UDim2.new(0, width, 0, 0))
							end,
						}),

					HealthBar = if UseUpdatedHealthBar then Roact.createElement(HealthBar, {}) else nil,

					StackedElements = Roact.createElement("Frame", {
						BackgroundTransparency = 1,
						Position = self.unibarRightSidePosition,
						Size = UDim2.new(1, 0, 1, 0),
					}, {
						Padding = Roact.createElement("UIPadding", {
							PaddingLeft = UDim.new(0, Constants.TopBarPadding),
						}),
						Layout = Roact.createElement("UIListLayout", {
							Padding = UDim.new(0, Constants.TopBarPadding),
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Left,
							VerticalAlignment = Enum.VerticalAlignment.Top,
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),

						HealthBar = if UseUpdatedHealthBar
							then nil
							else Roact.createElement(HealthBar, {
								layoutOrder = 10,
							}),

						CenterBadgeOver13 = if FFlagTopBarUseNewBadge
							then Roact.createElement("Frame", {
								BackgroundTransparency = 1,
								AutomaticSize = Enum.AutomaticSize.X,
								Size = UDim2.new(0, 0, 1, 0),
								LayoutOrder = 4,
								Visible = self.badgeOver13Visible,
							}, {
								Layout = Roact.createElement("UIListLayout", {
									FillDirection = Enum.FillDirection.Horizontal,
									HorizontalAlignment = Enum.HorizontalAlignment.Left,
									VerticalAlignment = Enum.VerticalAlignment.Center,
									SortOrder = Enum.SortOrder.LayoutOrder,
								}),
								BadgeOver13 = Roact.createElement(BadgeOver13, {
									layoutOrder = 1,
									analytics = Analytics.new(),
									player = Players.LocalPlayer,
									voiceChatServiceManager = VoiceChatServiceManager,
									VRService = game:GetService("VRService"),
									visibilityChanged = self.setBadgeOver13Visible,
								}),
							})
							else nil,

						VoiceBetaBadge = if GetFFlagBetaBadge() and policyAllowsBetaBadge
							then Roact.createElement(VoiceBetaBadge, {
								layoutOrder = 6,
								Analytics = Analytics.new(),
							})
							else nil,
					}),
				})
			or nil,

		UnibarRightFrame = Unibar
				and unibarAlignment == Enum.HorizontalAlignment.Right
				and Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(
						1,
						0,
						0,
						if GetFFlagChangeTopbarHeightCalculation() then topBarFrameHeight else topBarHeight
					),
					Position = if GetFFlagChangeTopbarHeightCalculation()
						then topBarRightUnibarFramePosition
						else topBarRightFramePosition,
					AnchorPoint = Vector2.new(1, 0),
				}, {
					ChromeAnalytics = if ChromeAnalytics then Roact.createElement(ChromeAnalytics) else nil,
					KeepOutAreasHandler = if not FFlagEnableChromeBackwardsSignalAPI and KeepOutAreasHandler
						then Roact.createElement(KeepOutAreasHandler)
						else nil,
					Padding = Roact.createElement("UIPadding", {
						PaddingTop = UDim.new(0, Constants.UnibarFrame.PaddingTop),
						PaddingBottom = UDim.new(0, Constants.UnibarFrame.PaddingBottom),
					}),
					Layout = Roact.createElement("UIListLayout", {
						Padding = UDim.new(0, Constants.TopBarPadding),
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),

					HealthBar = Roact.createElement(HealthBar, {
						layoutOrder = 1,
					}),

					Unibar = Roact.createElement(Unibar, {
						onAreaChanged = self.props.setKeepOutArea,
						layoutOrder = 2,
					}),
				})
			or nil,

		TopBarFrame = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(
				1,
				0,
				0,
				if GetFFlagChangeTopbarHeightCalculation() then topBarFrameHeight else topBarHeight
			),
			Visible = isTopBarVisible,
			Position = topBarFramePosition,
		}, {
			LeftFrame = (chromeEnabled and FFlagAdaptUnibarAndTiltSizing or not TenFootInterface:IsEnabled())
				and Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0.5, -screenSideOffset, 1, 0),
					Position = topBarLeftFramePosition,
				}, {
					Layout = Roact.createElement("UIListLayout", {
						Padding = UDim.new(0, Constants.TopBarPadding),
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = if FFlagTopBarUseNewBadge
							then Enum.VerticalAlignment.Center
							else Enum.VerticalAlignment.Top,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),

					Blank = chromeEnabled and Roact.createElement("Frame", {
						LayoutOrder = 1,
						Size = UDim2.new(0, Constants.UnibarFrame.ExtendedSize, 0, 1),
						BackgroundTransparency = 1,
					}),

					MenuIcon = not isNewTiltIconEnabled() and Roact.createElement(MenuIcon, {
						layoutOrder = 1,
						showBadgeOver12 = self.props.showBadgeOver12,
					}),

					ConnectIcon = not chromeEnabled
							and GetFFlagEnablePartyIconInNonChrome()
							and GetShouldShowPlatformChatBasedOnPolicy()
							and Roact.createElement(ConnectIcon, {
								setKeepOutArea = self.props.setKeepOutArea,
								removeKeepOutArea = self.props.removeKeepOutArea,
								layoutOrder = 2,
							})
						or nil,

					ChatIcon = not chromeEnabled and Roact.createElement(ChatIcon, {
						layoutOrder = 3,
					}) or nil,

					BadgeOver13 = if FFlagTopBarUseNewBadge and not chromeEnabled
						then Roact.createElement(BadgeOver13, {
							layoutOrder = 4,
							analytics = Analytics.new(),
							player = Players.LocalPlayer,
							voiceChatServiceManager = VoiceChatServiceManager,
							VRService = game:GetService("VRService"),
							visibilityChanged = nil,
						})
						else nil,

					VoiceBetaBadge = if showBetaBadge and policyAllowsBetaBadge
						then Roact.createElement(VoiceBetaBadge, {
							layoutOrder = 4,
							Analytics = Analytics.new(),
						})
						else nil,
				}),

			RightFrame = not Unibar and Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.5, -screenSideOffset, 1, 0),
				Position = topBarRightFramePosition,
				AnchorPoint = Vector2.new(1, 0),
			}, {
				Layout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, Constants.TopBarPadding),
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				HealthBar = Roact.createElement(HealthBar, {
					layoutOrder = 1,
				}),

				MoreMenu = not TenFootInterface:IsEnabled() and Roact.createElement(MoreMenu, {
					layoutOrder = 2,
				}),
			}) or nil,
		}),
	})
end

local function mapStateToProps(state)
	local inspectMenuOpen = state.displayOptions.inspectMenuOpen

	return {
		menuOpen = state.displayOptions.menuOpen,
		inspectMenuOpen = inspectMenuOpen,
	}
end

local TopBarAppWithPolicy = TopBarAppPolicy.connect(function(appPolicy, props)
	return {
		displayBetaBadge = appPolicy.getDisplayVoiceBetaBadge(),
		showBadgeOver12 = appPolicy.showBadgeOver12(),
	}
end)(TopBarApp)

local function mapDispatchToProps(dispatch)
	return {
		setScreenSize = function(screenSize)
			return dispatch(SetScreenSize(screenSize))
		end,
		setKeepOutArea = function(id, position, size)
			return dispatch(SetKeepOutArea(id, position, size))
		end,
		removeKeepOutArea = function(id)
			return dispatch(RemoveKeepOutArea(id))
		end,
	}
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(TopBarAppWithPolicy)
