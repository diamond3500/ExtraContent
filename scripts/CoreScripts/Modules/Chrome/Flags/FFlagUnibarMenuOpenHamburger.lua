local CorePackages = game:GetService("CorePackages")
local SharedFlags = require(CorePackages.Workspace.Packages.SharedFlags)
local FFlagEnableConsoleExpControls = SharedFlags.FFlagEnableConsoleExpControls
local IsExperienceMenuABTestEnabled = require(script.Parent.Parent.Parent.IsExperienceMenuABTestEnabled)
local ExperienceMenuABTestManager = require(script.Parent.Parent.Parent.ExperienceMenuABTestManager)
local FFlagUnibarMenuOpenHamburger = game:DefineFastFlag("UnibarMenuOpenHamburger", false)

return FFlagEnableConsoleExpControls
	and (
		IsExperienceMenuABTestEnabled()
			and ExperienceMenuABTestManager.default:showConsoleExpControlsMenuOpenHamburger()
		or FFlagUnibarMenuOpenHamburger
	)
