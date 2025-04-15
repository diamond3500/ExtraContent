local Chrome = script:FindFirstAncestor("Chrome")

local CorePackages = game:GetService("CorePackages")

local AppChat = require(CorePackages.Workspace.Packages.AppChat)
local InExperienceAppChatExperimentation = AppChat.App.InExperienceAppChatExperimentation

local GetFFlagEnableAppChatInExperience =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagEnableAppChatInExperience
local GetShouldShowPlatformChatBasedOnPolicy = require(Chrome.Flags.GetShouldShowPlatformChatBasedOnPolicy)

return function()
	return GetFFlagEnableAppChatInExperience()
		and InExperienceAppChatExperimentation.default.variant.ShowPlatformChatChromeDropdownEntryPoint
		and GetShouldShowPlatformChatBasedOnPolicy()
end
