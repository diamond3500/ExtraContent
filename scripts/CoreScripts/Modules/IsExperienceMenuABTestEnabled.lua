local CorePackages = game:GetService("CorePackages")

local GetFFlagEnableInGameMenuChromeABTest = require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagEnableInGameMenuChromeABTest
local GetFFlagEnableInGameMenuSongbirdABTest = require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagEnableInGameMenuSongbirdABTest

return function()
	return game:GetEngineFeature("ExperienceMenuABTest") and (GetFFlagEnableInGameMenuChromeABTest() or GetFFlagEnableInGameMenuSongbirdABTest())
end
