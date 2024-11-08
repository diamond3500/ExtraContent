local Chrome = script:FindFirstAncestor("Chrome")

game:DefineFastFlag("UseNewUnibarIcon", false)

local IsExperienceMenuABTestEnabled = require(Chrome.Parent.IsExperienceMenuABTestEnabled)
local ExperienceMenuABTestManager = require(Chrome.Parent.ExperienceMenuABTestManager)

return function()
	if IsExperienceMenuABTestEnabled() and ExperienceMenuABTestManager.default:shouldShowNewIcon() then
		return true
	end

	return game:GetFastFlag("UseNewUnibarIcon")
end
