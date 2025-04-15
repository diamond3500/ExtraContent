local CorePackages = game:GetService("CorePackages")
local GetFFlagLuaAppEnableSquadPage = require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagLuaAppEnableSquadPage

game:DefineFastFlag("AppChatInExpConnectIconEnableSquadIndicator2", false)

return function()
	return game:GetFastFlag("AppChatInExpConnectIconEnableSquadIndicator2") and GetFFlagLuaAppEnableSquadPage()
end
