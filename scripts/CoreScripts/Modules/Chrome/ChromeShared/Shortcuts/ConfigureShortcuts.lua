local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local CorePackages = game:GetService("CorePackages")
local GamepadService = game:GetService("GamepadService")

local Root = script:FindFirstAncestor("ChromeShared")
local FocusSelectExpChat = require(Root.Utility.FocusSelectExpChat)
local ChromeService = require(Root.Service)
local GuiService = game:GetService("GuiService")
local Constants = require(Root.Unibar.Constants)
local SharedFlags = require(CorePackages.Workspace.Packages.SharedFlags)
local FFlagConsoleChatOnExpControls = SharedFlags.FFlagConsoleChatOnExpControls
local FFlagTweakTiltMenuShortcuts = SharedFlags.FFlagTweakTiltMenuShortcuts

local ChatSelector = if FFlagConsoleChatOnExpControls then require(RobloxGui.Modules.ChatSelector) else nil :: never
local leaveGame = require(RobloxGui.Modules.Settings.leaveGame)

local FFlagConsoleSinglePressIntegrationExit = SharedFlags.FFlagConsoleSinglePressIntegrationExit
local FFlagShowUnibarOnVirtualCursor = SharedFlags.FFlagShowUnibarOnVirtualCursor

function registerShortcuts()
	ChromeService:registerShortcut({
		id = "leave",
		label = "CoreScripts.TopBar.Leave",
		keyCode = Enum.KeyCode.ButtonX,
		integration = nil,
		actionName = "UnibarGamepadLeaveGame",
		activated = function()
			local SettingsHub = require(RobloxGui.Modules.Settings.SettingsHub)
			if SettingsHub:GetVisibility() then
				if SettingsHub.Instance.Pages.CurrentPage == SettingsHub.Instance.LeaveGamePage then
					leaveGame(true)
				else
					SettingsHub:SwitchToPage(SettingsHub.Instance.LeaveGamePage, true)
				end
			else
				SettingsHub:SetVisibility(true, false, SettingsHub.Instance.LeaveGamePage)
			end
			return
		end,
	})

	ChromeService:registerShortcut({
		id = "respawn",
		label = "CoreScripts.InGameMenu.QuickActions.Respawn",
		keyCode = Enum.KeyCode.ButtonY,
		integration = "respawn",
		actionName = "UnibarGamepadRespawn",
		activated = function()
			local SettingsHub = require(RobloxGui.Modules.Settings.SettingsHub)
			if
				SettingsHub:GetVisibility()
				and SettingsHub.Instance.Pages.CurrentPage == SettingsHub.Instance.ResetCharacterPage
			then
				SettingsHub.Instance.ResetCharacterPage.ResetFunction()
			else
				ChromeService:activate("respawn")
			end
			return
		end,
	})

	ChromeService:registerShortcut({
		id = "chat",
		label = "CoreScripts.TopBar.Chat",
		keyCode = Enum.KeyCode.ButtonR1,
		integration = "chat",
		actionName = "UnibarGamepadChat",
		activated = if FFlagConsoleChatOnExpControls
			then function()
				local chatVisible = ChatSelector:GetVisibility()
				ChatSelector:SetVisible(not chatVisible)
				if not chatVisible then
					FocusSelectExpChat("chat")
				end
				return
			end
			else nil,
	})

	ChromeService:registerShortcut({
		id = "tiltMenu",
		label = "CoreScripts.TopBar.Menu",
		keyCode = Enum.KeyCode.ButtonR2,
		integration = nil,
		actionName = "UnibarGamepadMenu",
		activated = function()
			local SettingsHub = require(RobloxGui.Modules.Settings.SettingsHub)
			if SettingsHub:GetVisibility() then
				SettingsHub:SetVisibility(false)
			else
				SettingsHub:SetVisibility(true)
			end
			return
		end,
	})

	ChromeService:registerShortcut({
		id = "back",
		label = "CoreScripts.TopBar.Back",
		keyCode = Enum.KeyCode.ButtonB,
		integration = nil,
		actionName = "UnibarGamepadBack",
		activated = function()
			local SettingsHub = require(RobloxGui.Modules.Settings.SettingsHub)
			if SettingsHub:GetVisibility() then
				SettingsHub.Instance:PopMenu(false, true)
				if not SettingsHub:GetVisibility() then
					ChromeService:selectMenuIcon()
				end
			else
				local subMenuId = ChromeService:currentSubMenu():get()
				if subMenuId then
					ChromeService:toggleSubMenu(subMenuId)
					ChromeService:setSelected(subMenuId)
				else
					ChromeService:disableFocusNav()
					ChromeService:setShortcutBar(nil)
					GuiService.SelectedCoreObject = nil
					if FFlagConsoleSinglePressIntegrationExit then
						return Enum.ContextActionResult.Pass
					end
				end
			end
			return
		end,
	})

	ChromeService:registerShortcut({
		id = "close",
		-- non-visible shortcut
		label = nil,
		keyCode = Enum.KeyCode.ButtonStart,
		actionName = "UnibarGamepadClose",
		activated = function()
			local SettingsHub = require(RobloxGui.Modules.Settings.SettingsHub)
			SettingsHub:SetVisibility(false)
			ChromeService:disableFocusNav()
			ChromeService:setShortcutBar(nil)
			GuiService.SelectedCoreObject = nil
			return
		end,
	})

	ChromeService:registerShortcut({
		id = "virtualCursor",
		-- non-visible shortcut
		label = nil,
		keyCode = Enum.KeyCode.ButtonSelect,
		actionName = "VirtualCursorShortcut",
		activated = function()
			ChromeService:disableFocusNav()
			ChromeService:setShortcutBar(nil)
			GuiService.SelectedCoreObject = nil
			GamepadService.GamepadCursorEnabled = true
			return
		end,
	})

	ChromeService:registerShortcut({
		id = "tiltMenuPreviousTab",
		label = "CoreScripts.InGameMenu.Controls.PreviousTab",
		keyCode = Enum.KeyCode.ButtonL1,
		integration = nil,
		actionName = nil,
		-- tab movement is handled in SettingsHub
		activated = nil,
	})

	ChromeService:registerShortcut({
		id = "tiltMenuNextTab",
		label = "CoreScripts.InGameMenu.Controls.NextTab",
		keyCode = Enum.KeyCode.ButtonR1,
		integration = nil,
		actionName = nil,
		-- tab movement is handled in SettingsHub
		activated = nil,
	})
end

function configureShortcutBars()
	ChromeService:configureShortcutBar(
		Constants.UNIBAR_SHORTCUTBAR_ID,
		if FFlagShowUnibarOnVirtualCursor
			then { "leave", "respawn", "chat", "tiltMenu", "back", "virtualCursor" }
			else { "leave", "respawn", "chat", "tiltMenu", "back" }
	)

	ChromeService:configureShortcutBar(
		Constants.TILTMENU_SHORTCUTBAR_ID,
		if FFlagTweakTiltMenuShortcuts
			then { "tiltMenuPreviousTab", "tiltMenuNextTab", "back", "close" }
			else { "leave", "respawn", "tiltMenuPreviousTab", "tiltMenuNextTab", "back", "close" }
	)

	-- in the future, some kind of availability system for shortcuts would probably be cleaner
	ChromeService:configureShortcutBar(
		Constants.TILTMENU_DIALOG_SHORTCUTBAR_ID,
		{ "leave", "respawn", "back", "close" }
	)
end

return function()
	registerShortcuts()
	configureShortcutBars()
end
