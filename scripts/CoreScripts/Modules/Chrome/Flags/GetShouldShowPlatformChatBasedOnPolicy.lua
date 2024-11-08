local CorePackages = game:GetService("CorePackages")

local FFlagAppChatDisableInExpU13 = game:DefineFastFlag("AppChatDisableInExpU13", false)

local UniversalAppPolicy = require(CorePackages.Workspace.Packages.UniversalAppPolicy)

return function()
	local shouldShowPlatformChatBasedOnPolicy = if FFlagAppChatDisableInExpU13
		then UniversalAppPolicy.getAppFeaturePolicies().getCanSeeChatTab()
		else true

	return shouldShowPlatformChatBasedOnPolicy
end
