local Chrome = script:FindFirstAncestor("Chrome")

local IsExperienceMenuABTestEnabled = require(Chrome.Parent.IsExperienceMenuABTestEnabled)
local ExperienceMenuABTestManager = require(Chrome.Parent.ExperienceMenuABTestManager)

game:DefineFastFlag("EnableChromeFTUX", false)

return function()
	if IsExperienceMenuABTestEnabled() and ExperienceMenuABTestManager.default:shouldShowFTUX() then
		return true
	end

	return game:GetFastFlag("EnableChromeFTUX")
end
