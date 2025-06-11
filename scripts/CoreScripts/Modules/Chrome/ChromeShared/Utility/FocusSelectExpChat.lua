local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local UserInputService = game:GetService("UserInputService")

local SharedFlags = require(CorePackages.Workspace.Packages.SharedFlags)
local FFlagChromeFocusOnAndOffUtils = SharedFlags.FFlagChromeFocusOnAndOffUtils

local Chrome = script:FindFirstAncestor("Chrome")
local ChromeService = require(Chrome.Service)
local ChromeConstants = require(Chrome.ChromeShared.Unibar.Constants)
local Types = require(Chrome.ChromeShared.Service.Types)
local ChromeFocusUtils = require(CorePackages.Workspace.Packages.Chrome).FocusUtils

local InputType = require(CorePackages.Workspace.Packages.InputType)
local getInputGroup = InputType.getInputGroup
local ExpChat = require(CorePackages.Workspace.Packages.ExpChat)
local ExpChatFocusNavigationStore = ExpChat.Stores.GetFocusNavigationStore(false)

local ChatSelector = require(RobloxGui.Modules.ChatSelector)

local function isUsingGamepad()
	-- APPEXP-2014: Todo refactor once Responsive LastInput can be used in any context
	return getInputGroup(UserInputService:GetLastInputType()) == InputType.InputTypeConstants.Gamepad
end

return function(id: Types.IntegrationId)
	if FFlagChromeFocusOnAndOffUtils then
		if ChatSelector:GetVisibility() and isUsingGamepad() then
			ChromeFocusUtils.FocusOffChrome(function()
				ChromeService:setShortcutBar(ChromeConstants.UNIBAR_SHORTCUTBAR_ID)
				ExpChatFocusNavigationStore.focusChatInputBar()
			end)
		end
	elseif UserInputService.GamepadEnabled and ChatSelector:GetVisibility() then
		ChromeService:disableFocusNav()
		ChatSelector:FocusSelectChatBar(function()
			ChromeService:setSelected(id)
			ChromeService:enableFocusNav()
		end, {
			Enum.KeyCode.DPadUp,
			Enum.KeyCode.ButtonB,
			Enum.KeyCode.ButtonR1,
		})
	end
end
