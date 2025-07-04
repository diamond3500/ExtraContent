--!nonstrict
--[[
	// FileName: ChatSelector.lua
	// Written by: Xsitsu
	// Description: Code for determining which chat version to use in game.
]]

local FORCE_IS_CONSOLE = false

local CoreGuiService = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local RobloxGui = CoreGuiService:WaitForChild("RobloxGui")
local Modules = RobloxGui:WaitForChild("Modules")

local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Players = game:GetService("Players")

local Util = require(RobloxGui.Modules.ChatUtil)

local ClassicChatEnabled = Players.ClassicChat
local BubbleChatEnabled = Players.BubbleChat

local VRService = game:GetService("VRService")

local SharedFlags = require(CorePackages.Workspace.Packages.SharedFlags)
local getFFlagAppChatCoreUIConflictFix = SharedFlags.getFFlagAppChatCoreUIConflictFix
local GetFFlagChatActiveChangedSignal = SharedFlags.GetFFlagChatActiveChangedSignal
local getFFlagExposeChatWindowToggled = SharedFlags.getFFlagExposeChatWindowToggled
local FFlagConsoleChatOnExpControls = SharedFlags.FFlagConsoleChatOnExpControls
local FFlagChromeChatGamepadSupportFix = SharedFlags.FFlagChromeChatGamepadSupportFix

local SocialExperiments = require(CorePackages.Workspace.Packages.SocialExperiments)
local TenFootInterfaceExpChatExperimentation = SocialExperiments.TenFootInterfaceExpChatExperimentation

local useModule = nil

local visibilityBeforeTempKeyAdded = nil
local hideTempKeys = if getFFlagAppChatCoreUIConflictFix() then {} else nil :: never
local state = {Visible = not VRService.VREnabled}
local interface = {}
do
	function interface:ToggleVisibility()
		if (useModule) then
			useModule:ToggleVisibility()
		else
			state.Visible = not state.Visible
		end
	end

	function interface:SetVisible(visible)
		if (useModule) then
			useModule:SetVisible(visible)
		else
			state.Visible = visible
		end
	end

	function interface:FocusChatBar()
		if (useModule) then
			useModule:FocusChatBar()
		end
	end

	function interface:FocusSelectChatBar(onSelectionLost: ()->()?, keybinds: {Enum.KeyCode}?)
		if (useModule) then
			if FFlagConsoleChatOnExpControls and (FFlagChromeChatGamepadSupportFix or TenFootInterfaceExpChatExperimentation.getIsEnabled()) then
				useModule:FocusSelectChatBar(onSelectionLost, keybinds)
			end
		end
	end

	function interface:EnterWhisperState(player)
		if useModule then
			return useModule:EnterWhisperState(player)
		end
	end

	function interface:GetVisibility()
		if (useModule) then
			return useModule:GetVisibility()
		else
			return state.Visible
		end
	end

	function interface:GetMessageCount()
		if (useModule) then
			return useModule:GetMessageCount()
		else
			return 0
		end
	end

	function interface:TopbarEnabledChanged(...)
		if (useModule) then
			return useModule:TopbarEnabledChanged(...)
		end
	end

	function interface:IsFocused(useWasFocused)
		if (useModule) then
			return useModule:IsFocused(useWasFocused)
		else
			return false
		end
	end

	function interface:ClassicChatEnabled()
		if useModule then
			return useModule:ClassicChatEnabled()
		else
			return ClassicChatEnabled
		end
	end

	function interface:IsBubbleChatOnly()
		if useModule then
			return useModule:IsBubbleChatOnly()
		end
		return BubbleChatEnabled and not ClassicChatEnabled
	end

	function interface:IsDisabled()
		if useModule then
			return useModule:IsDisabled()
		end
		return not (BubbleChatEnabled or ClassicChatEnabled)
	end

	if getFFlagAppChatCoreUIConflictFix() then
		function interface:HideTemp(key: string, hidden: boolean)
			local function isHideTempKeysEmpty()
				return next(hideTempKeys) == nil
			end

			if isHideTempKeysEmpty() then
				visibilityBeforeTempKeyAdded = interface:GetVisibility()
			end

			if hidden then
				hideTempKeys[key] = hidden
			else
				hideTempKeys[key] = nil
			end

			interface:SetVisible(visibilityBeforeTempKeyAdded and isHideTempKeysEmpty())
		end
	end


	interface.ChatBarFocusChanged = Util.Signal()
	if getFFlagExposeChatWindowToggled() then
		interface.ChatWindowToggled = Util.Signal()
	end
	if GetFFlagChatActiveChangedSignal() then
		interface.ChatActiveChanged = Util.Signal()
		interface.ChatActiveChanged:connect(function(visible)
			 interface:SetVisible(visible)
		end)
	end
	interface.VisibilityStateChanged = Util.Signal()
	interface.MessagesChanged = Util.Signal()

	-- Signals that are called when we get information on if Bubble Chat and Classic chat are enabled from the chat.
	interface.BubbleChatOnlySet = Util.Signal()
	interface.ChatDisabled = Util.Signal()
end

local StopQueueingSystemMessages = false
local MakeSystemMessageQueue = {}
local function MakeSystemMessageQueueingFunction(data)
	if (StopQueueingSystemMessages) then return end
	table.insert(MakeSystemMessageQueue, data)
end

local function NonFunc() end
StarterGui:RegisterSetCore("ChatMakeSystemMessage", MakeSystemMessageQueueingFunction)
StarterGui:RegisterSetCore("ChatWindowPosition", NonFunc)
StarterGui:RegisterGetCore("ChatWindowPosition", NonFunc)
StarterGui:RegisterSetCore("ChatWindowSize", NonFunc)
StarterGui:RegisterGetCore("ChatWindowSize", NonFunc)
StarterGui:RegisterSetCore("ChatBarDisabled", NonFunc)
StarterGui:RegisterGetCore("ChatBarDisabled", NonFunc)


StarterGui:RegisterGetCore("ChatActive", function()
	return interface:GetVisibility()
end)
StarterGui:RegisterSetCore("ChatActive", function(visible)
	if GetFFlagChatActiveChangedSignal() then
		interface.ChatActiveChanged:fire(visible)
	else
		return interface:SetVisible(visible)
	end
end)


local function ConnectSignals(useModule, interface, sigName)
	--// "MessagesChanged" event is not created for Studio Start Server
	if (useModule[sigName]) then
		useModule[sigName]:connect(function(...) interface[sigName]:fire(...) end)
	end
end

local isConsole = GuiService:IsTenFootInterface() or FORCE_IS_CONSOLE

if TenFootInterfaceExpChatExperimentation.getIsEnabled() or (not isConsole) then
	coroutine.wrap(function()
		useModule = require(RobloxGui.Modules.NewChat)

		ConnectSignals(useModule, interface, "ChatBarFocusChanged")
		ConnectSignals(useModule, interface, "VisibilityStateChanged")
		if getFFlagExposeChatWindowToggled() then
			ConnectSignals(useModule, interface, "ChatWindowToggled")
		end
		if GetFFlagChatActiveChangedSignal() then
			ConnectSignals(useModule, interface, "ChatActiveChanged")
		end
		ConnectSignals(useModule, interface, "BubbleChatOnlySet")
		ConnectSignals(useModule, interface, "ChatDisabled")

		while Players.LocalPlayer == nil do Players.ChildAdded:wait() end
		local LocalPlayer = Players.LocalPlayer

		ConnectSignals(useModule, interface, "MessagesChanged")
		-- Retained for legacy reasons, no longer used by the chat scripts.
		StarterGui:RegisterGetCore("UseNewLuaChat", function() return true end)

		useModule:SetVisible(state.Visible)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Chat))

		StopQueueingSystemMessages = true
		for i, messageData in pairs(MakeSystemMessageQueue) do
			pcall(function() StarterGui:SetCore("ChatMakeSystemMessage", messageData) end)
		end
	end)()
end

return interface
