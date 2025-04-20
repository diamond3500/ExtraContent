local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local UserInputService = game:GetService("UserInputService")

local Chrome = script:FindFirstAncestor("Chrome")
local ChromeService = require(Chrome.Service)
local Types = require(Chrome.ChromeShared.Service.Types)

local ChatSelector = require(RobloxGui.Modules.ChatSelector)

return function(id: Types.IntegrationId)
	if UserInputService.GamepadEnabled and ChatSelector:GetVisibility() then
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
