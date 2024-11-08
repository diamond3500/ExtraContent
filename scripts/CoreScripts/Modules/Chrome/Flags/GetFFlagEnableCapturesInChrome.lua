local Chrome = script:FindFirstAncestor("Chrome")

game:DefineFastFlag("EnableCapturesInChrome", false)

local IsExperienceMenuABTestEnabled = require(Chrome.Parent.IsExperienceMenuABTestEnabled)
local ExperienceMenuABTestManager = require(Chrome.Parent.ExperienceMenuABTestManager)

return function()
	if IsExperienceMenuABTestEnabled() and ExperienceMenuABTestManager.default:shouldShowCaptures() then
		return true
	end

	return game:GetFastFlag("EnableCapturesInChrome")
end
