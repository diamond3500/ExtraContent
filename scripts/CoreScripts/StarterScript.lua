--!nonstrict
-- Creates all neccessary scripts for the gui on initial load, everything except build tools
-- Created by Ben T. 10/29/10
-- Please note that these are loaded in a specific order to diminish errors/perceived load time by user

local CorePackages = game:GetService("CorePackages")
local ScriptContext = game:GetService("ScriptContext")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local RobloxGui = game:GetService("CoreGui"):WaitForChild("RobloxGui")
local CoreGuiModules = RobloxGui:WaitForChild("Modules")

local loadErrorHandlerFromEngine = game:GetEngineFeature("LoadErrorHandlerFromEngine")

local initify = require(CorePackages.initify)

-- Initifying CorePackages.Packages is required for the error reporter to work.
-- We need to initify extensively to all CorePackages to accommodate the Packagification works.
initify(CorePackages)
initify(CoreGuiModules)

-- Load the error reporter as early as possible, even before we finish requiring,
-- so that it can report any errors that come after this point.
ScriptContext:AddCoreScriptLocal("CoreScripts/CoreScriptErrorReporter", RobloxGui)

local Roact = require(CorePackages.Roact)
local PolicyService = require(CoreGuiModules:WaitForChild("Common"):WaitForChild("PolicyService"))

-- remove this when removing FFlagConnectErrorHandlerInLoadingScript
local FFlagConnectionScriptEnabled = settings():GetFFlag("ConnectionScriptEnabled")
local FFlagVRAvatarGestures = game:DefineFastFlag("VRAvatarGestures", false)

local FFlagUseRoactGlobalConfigInCoreScripts = require(RobloxGui.Modules.Flags.FFlagUseRoactGlobalConfigInCoreScripts)
local FFlagConnectErrorHandlerInLoadingScript = require(RobloxGui.Modules.Flags.FFlagConnectErrorHandlerInLoadingScript)

local FFlagDebugAvatarChatVisualization = game:DefineFastFlag("DebugAvatarChatVisualization", false)

local GetFFlagScreenshotHudApi = require(RobloxGui.Modules.Flags.GetFFlagScreenshotHudApi)

local GetFFlagEnableVoiceDefaultChannel = require(RobloxGui.Modules.Flags.GetFFlagEnableVoiceDefaultChannel)

local GetFFlagShareInviteLinkContextMenuABTestEnabled =
	require(RobloxGui.Modules.Flags.GetFFlagShareInviteLinkContextMenuABTestEnabled)
local ShareInviteLinkABTestManager = require(RobloxGui.Modules.ShareInviteLinkABTestManager)
local IsExperienceMenuABTestEnabled = require(CoreGuiModules.IsExperienceMenuABTestEnabled)
local ExperienceMenuABTestManager = require(CoreGuiModules.ExperienceMenuABTestManager)
local GetFFlagEnableNewInviteMenuIXP = require(CoreGuiModules.Flags.GetFFlagEnableNewInviteMenuIXP)
local NewInviteMenuExperimentManager = require(CoreGuiModules.Settings.Pages.ShareGame.NewInviteMenuExperimentManager)
local GetFFlagEnableSoundTelemetry = require(CoreGuiModules.Flags.GetFFlagEnableSoundTelemetry)
local GetFFlagReportAnythingAnnotationIXP = require(CoreGuiModules.Settings.Flags.GetFFlagReportAnythingAnnotationIXP)
local TrustAndSafetyIXPManager = require(RobloxGui.Modules.TrustAndSafety.TrustAndSafetyIXPManager)

local GetCoreScriptsLayers = require(CoreGuiModules.Experiment.GetCoreScriptsLayers)

local GetFFlagRtMessaging = require(RobloxGui.Modules.Flags.GetFFlagRtMessaging)
local GetFFlagContactListEnabled = require(RobloxGui.Modules.Common.Flags.GetFFlagContactListEnabled)
local FFlagAddPublishAssetPrompt = game:DefineFastFlag("AddPublishAssetPrompt6", false)
local getFFlagEnableApolloClientInExperience = require(CorePackages.Workspace.Packages.SharedFlags).getFFlagEnableApolloClientInExperience
local isCharacterNameHandlerEnabled = require(CorePackages.Workspace.Packages.SharedFlags).isCharacterNameHandlerEnabled
local GetFFlagCorescriptsSoundManagerEnabled = require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagCorescriptsSoundManagerEnabled
local GetFFlagIrisAlwaysOnTopEnabled = require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagIrisAlwaysOnTopEnabled
local GetFFlagEnableSocialContextToast = require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagEnableSocialContextToast
local GetFFlagTenFootUiAchievements = require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagTenFootUiAchievements

local FFlagLuaAppEnableToastNotificationsCoreScripts = game:DefineFastFlag("LuaAppEnableToastNotificationsCoreScripts4", false)
local FFlagCoreScriptsGlobalEffects = require(CorePackages.Workspace.Packages.SharedFlags).FFlagCoreScriptsGlobalEffects
local FFlagAdPortalTeleportPromptLua = game:DefineFastFlag("AdPortalTeleportPromptLua", false)

local GetFFlagVoiceUserAgency3 = require(RobloxGui.Modules.Flags.GetFFlagVoiceUserAgency3)
local GetFFlagLuaInExperienceCoreScriptsGameInviteUnification = require(RobloxGui.Modules.Flags.GetFFlagLuaInExperienceCoreScriptsGameInviteUnification)

game:DefineFastFlag("MoodsEmoteFix3", false)

local UIBlox = require(CorePackages.UIBlox)
local uiBloxConfig = require(CoreGuiModules.UIBloxInGameConfig)
UIBlox.init(uiBloxConfig)

local localPlayer = Players.LocalPlayer
while not localPlayer do
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	localPlayer = Players.LocalPlayer
end

local FFlagAvatarChatCoreScriptSupport = require(RobloxGui.Modules.Flags.FFlagAvatarChatCoreScriptSupport)
local ChromeEnabled = require(RobloxGui.Modules.Chrome.Enabled)()
if ChromeEnabled then
	local ExperienceChat = require(CorePackages.ExperienceChat)
	ExperienceChat.GlobalFlags.AvatarChatEnabled = FFlagAvatarChatCoreScriptSupport
	ExperienceChat.GlobalFlags.ChromeEnabled = true
elseif FFlagAvatarChatCoreScriptSupport then
	local ExperienceChat = require(CorePackages.ExperienceChat)
	ExperienceChat.GlobalFlags.AvatarChatEnabled = true
end

local Screenshots = require(CorePackages.Workspace.Packages.Screenshots)
local FFlagScreenshotsFeaturesEnabledForAll = Screenshots.Flags.FFlagScreenshotsFeaturesEnabledForAll
local FFlagScreenshotSharingEnableExperiment = Screenshots.Flags.FFlagScreenshotSharingEnableExperiment

-- Since prop validation can be expensive in certain scenarios, you can enable
-- this flag locally to validate props to Roact components.
if FFlagUseRoactGlobalConfigInCoreScripts and RunService:IsStudio() then
	Roact.setGlobalConfig({
		propValidation = true,
		elementTracing = true,
	})
end

local InGameMenuDependencies = require(CorePackages.InGameMenuDependencies)
local InGameMenuUIBlox = InGameMenuDependencies.UIBlox
if InGameMenuUIBlox ~= UIBlox then
	InGameMenuUIBlox.init(uiBloxConfig)
end

local soundFolder = Instance.new("Folder")
soundFolder.Name = "Sounds"
soundFolder.Parent = RobloxGui

-- This can be useful in cases where a flag configuration issue causes requiring a CoreScript to fail
local function safeRequire(moduleScript)
	local success, ret = pcall(require, moduleScript)
	if success then
		return ret
	else
		warn("Failure to Start CoreScript module " .. moduleScript.Name .. ".\n" .. ret)
	end
end

if not FFlagConnectErrorHandlerInLoadingScript and not loadErrorHandlerFromEngine then
	if FFlagConnectionScriptEnabled and not GuiService:IsTenFootInterface() then
		ScriptContext:AddCoreScriptLocal("Connection", RobloxGui)
	end
end

-- In-game notifications script
ScriptContext:AddCoreScriptLocal("CoreScripts/NotificationScript2", RobloxGui)

-- SelfieView
initify(CoreGuiModules.SelfieView)
coroutine.wrap(safeRequire)(CoreGuiModules.SelfieView)


initify(CoreGuiModules.Chrome)

-- TopBar
initify(CoreGuiModules.TopBar)
coroutine.wrap(safeRequire)(CoreGuiModules.TopBar)

if game:GetEngineFeature("LuobuModerationStatus") then
	coroutine.wrap(function()
		initify(CoreGuiModules.Watermark)
		safeRequire(CoreGuiModules.Watermark)
	end)()
end

-- MainBotChatScript (the Lua part of Dialogs)
ScriptContext:AddCoreScriptLocal("CoreScripts/MainBotChatScript2", RobloxGui)

if game:GetEngineFeature("ProximityPrompts") then
	ScriptContext:AddCoreScriptLocal("CoreScripts/ProximityPrompt", RobloxGui)
end

coroutine.wrap(function() -- this is the first place we call, which can yield so wrap in coroutine
	ScriptContext:AddCoreScriptLocal("CoreScripts/ScreenTimeInGame", RobloxGui)
end)()

coroutine.wrap(function()
	if PolicyService:IsSubjectToChinaPolicies() then
		if not game:IsLoaded() then
			game.Loaded:Wait()
		end
		initify(CoreGuiModules.LuobuWarningToast)
		safeRequire(CoreGuiModules.LuobuWarningToast)
	end
end)()

-- Performance Stats Management
ScriptContext:AddCoreScriptLocal("CoreScripts/PerformanceStatsManagerScript", RobloxGui)

-- Default Alternate Death Ragdoll (China only for now)
ScriptContext:AddCoreScriptLocal("CoreScripts/PlayerRagdoll", RobloxGui)

-- Chat script
coroutine.wrap(safeRequire)(RobloxGui.Modules.ChatSelector)
coroutine.wrap(safeRequire)(RobloxGui.Modules.PlayerList.PlayerListManager)

local UserRoactBubbleChatBeta
do
	local success, value = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserRoactBubbleChatBeta")
	end)
	UserRoactBubbleChatBeta = success and value
end

if game:GetEngineFeature("EnableBubbleChatFromChatService") or UserRoactBubbleChatBeta then
	ScriptContext:AddCoreScriptLocal("CoreScripts/PlayerBillboards", RobloxGui)
end


if GetFFlagIrisAlwaysOnTopEnabled() then
	ScriptContext:AddCoreScriptLocal("CoreScripts/IrisUpdateBubbleChat", RobloxGui)
end

-- Purchase Prompt Script
coroutine.wrap(function()
	initify(CoreGuiModules.PurchasePrompt)
	local PurchasePrompt = safeRequire(CoreGuiModules.PurchasePrompt)

	if PurchasePrompt then
		PurchasePrompt.mountPurchasePrompt()
	end
end)()

-- Publish Asset Prompt
if FFlagAddPublishAssetPrompt then
	coroutine.wrap(safeRequire)(CoreGuiModules.PublishAssetPrompt)
end

-- Prompt Block Player Script
ScriptContext:AddCoreScriptLocal("CoreScripts/BlockPlayerPrompt", RobloxGui)
ScriptContext:AddCoreScriptLocal("CoreScripts/FriendPlayerPrompt", RobloxGui)

-- Avatar Context Menu
ScriptContext:AddCoreScriptLocal("CoreScripts/AvatarContextMenu", RobloxGui)

-- Backpack!
coroutine.wrap(safeRequire)(RobloxGui.Modules.BackpackScript)

-- Keyboard Navigation :)
coroutine.wrap(safeRequire)(RobloxGui.Modules.KeyboardUINavigation)

-- Emotes Menu
coroutine.wrap(safeRequire)(RobloxGui.Modules.EmotesMenu.EmotesMenuMaster)

-- Screenshots
if FFlagScreenshotsFeaturesEnabledForAll or FFlagScreenshotSharingEnableExperiment then
	coroutine.wrap(safeRequire)(RobloxGui.Modules.Screenshots.ScreenshotsApp)
end

initify(CoreGuiModules.AvatarEditorPrompts)
coroutine.wrap(safeRequire)(CoreGuiModules.AvatarEditorPrompts)

-- GamepadVirtualCursor
coroutine.wrap(safeRequire)(RobloxGui.Modules.VirtualCursor.VirtualCursorMain)

ScriptContext:AddCoreScriptLocal("CoreScripts/VehicleHud", RobloxGui)
ScriptContext:AddCoreScriptLocal("CoreScripts/InviteToGamePrompt", RobloxGui)

if UserInputService.TouchEnabled then -- touch devices don't use same control frame
	-- only used for touch device button generation
	ScriptContext:AddCoreScriptLocal("CoreScripts/ContextActionTouch", RobloxGui)

	RobloxGui:WaitForChild("ControlFrame")
	RobloxGui.ControlFrame:WaitForChild("BottomLeftControl")
	RobloxGui.ControlFrame.BottomLeftControl.Visible = false
end

ScriptContext:AddCoreScriptLocal("CoreScripts/InspectAndBuy", RobloxGui)

coroutine.wrap(function()
	if not VRService.VREnabled then
		VRService:GetPropertyChangedSignal("VREnabled"):Wait()
	end
	safeRequire(RobloxGui.Modules.VR.VRAvatarHeightScaling)
	safeRequire(RobloxGui.Modules.VR.VirtualKeyboard)
	safeRequire(RobloxGui.Modules.VR.UserGui)
end)()

ScriptContext:AddCoreScriptLocal("CoreScripts/NetworkPause", RobloxGui)

if GetFFlagScreenshotHudApi() and not PolicyService:IsSubjectToChinaPolicies() then
	ScriptContext:AddCoreScriptLocal("CoreScripts/ScreenshotHud", RobloxGui)
end

if game:GetEngineFeature("VoiceChatSupported") and GetFFlagEnableVoiceDefaultChannel() then
	ScriptContext:AddCoreScriptLocal("CoreScripts/VoiceDefaultChannel", RobloxGui)
end

coroutine.wrap(function()
	local IXPServiceWrapper = require(CoreGuiModules.Common.IXPServiceWrapper)
	IXPServiceWrapper:InitializeAsync(localPlayer.UserId, GetCoreScriptsLayers())
	if IsExperienceMenuABTestEnabled() then
		ExperienceMenuABTestManager.default:initialize()
	end

	if GetFFlagShareInviteLinkContextMenuABTestEnabled() then
		ShareInviteLinkABTestManager.default:initialize()
	end

	if GetFFlagEnableNewInviteMenuIXP() then
		NewInviteMenuExperimentManager.default:initialize()
	end

	if GetFFlagReportAnythingAnnotationIXP() then
		TrustAndSafetyIXPManager.default:initialize()
	end
end)()

ScriptContext:AddCoreScriptLocal("CoreScripts/ExperienceChatMain", RobloxGui)

ScriptContext:AddCoreScriptLocal("CoreScripts/ChatEmoteUsage", script.Parent)

if FFlagLuaAppEnableToastNotificationsCoreScripts then
	ScriptContext:AddCoreScriptLocal("CoreScripts/ToastNotificationGUI", script.Parent)
end

if GetFFlagLuaInExperienceCoreScriptsGameInviteUnification() then
	ScriptContext:AddCoreScriptLocal("CoreScripts/GameInviteModalGUI", script.Parent)
end

if GetFFlagRtMessaging() then
	game:GetService("RtMessagingService")
end

if game:GetEngineFeature("FacialAnimationStreaming2") then
	ScriptContext:AddCoreScriptLocal("CoreScripts/FacialAnimationStreaming", script.Parent)
end

if FFlagAvatarChatCoreScriptSupport then
	ScriptContext:AddCoreScriptLocal("CoreScripts/FaceChatSelfieView", RobloxGui)

	if FFlagDebugAvatarChatVisualization then
		ScriptContext:AddCoreScriptLocal("CoreScripts/AvatarChatDebugVisualization", script.Parent)
	end

	if game:GetEngineFeature("TrackerLodControllerDebugUI") then
		ScriptContext:AddCoreScriptLocal("CoreScripts/TrackerLodControllerDebugUI", script.Parent)
	end
end

if FFlagVRAvatarGestures then
	coroutine.wrap(safeRequire)(RobloxGui.Modules.VR.AvatarGesturesController)
end

if game:GetEngineFeature("NewMoodAnimationTypeApiEnabled") and game:GetFastFlag("MoodsEmoteFix3") then
	ScriptContext:AddCoreScriptLocal("CoreScripts/AvatarMood", script.Parent)
end

ScriptContext:AddCoreScriptLocal("CoreScripts/PortalTeleportGUI", RobloxGui)

if game:GetEngineFeature("PortalAdPrompt") then
	if FFlagAdPortalTeleportPromptLua then
		ScriptContext:AddCoreScriptLocal("CoreScripts/AdTeleportPrompt", RobloxGui)
	end
end

if game:GetEngineFeature("EnableVoiceAttention") then
	ScriptContext:AddCoreScriptLocal("CoreScripts/VoiceAttention", script.Parent)
end

if GetFFlagEnableSoundTelemetry() then
	ScriptContext:AddCoreScriptLocal("CoreScripts/SoundTelemetry", script.Parent)
end

if getFFlagEnableApolloClientInExperience() then
	coroutine.wrap(safeRequire)(CoreGuiModules.ApolloClient)
end

if GetFFlagContactListEnabled() then
	initify(CoreGuiModules.ContactList)
	coroutine.wrap(safeRequire)(CoreGuiModules.ContactList)
end

if isCharacterNameHandlerEnabled() then
	ScriptContext:AddCoreScriptLocal("CoreScripts/CharacterNameHandler", script.Parent)
end

if GetFFlagVoiceUserAgency3() then
	ScriptContext:AddCoreScriptLocal("CoreScripts/VoiceUserAgency", RobloxGui)
end

if FFlagCoreScriptsGlobalEffects then
	-- Mounts a react root that persists while the user is in-experience.
	-- This allows us to use react-based listeners that trigger effects
	if not _G.IsLegacyAppShell then
		ScriptContext:AddCoreScriptLocal("CoreScripts/CoreScriptsGlobalEffects", script.Parent)
	end
end

if GetFFlagCorescriptsSoundManagerEnabled() then
	local SoundManager = require(CorePackages.Workspace.Packages.SoundManager).SoundManager
	SoundManager.init()
end

if GetFFlagEnableSocialContextToast() then
	ScriptContext:AddCoreScriptLocal("CoreScripts/SocialContextToast", RobloxGui)
end

if GetFFlagTenFootUiAchievements() then
	local InExpAchievementManager = require(CorePackages.Workspace.Packages.Achievements).InExpAchievementManager
	local achievementManager = InExpAchievementManager.new()
	achievementManager:startUp()
end
