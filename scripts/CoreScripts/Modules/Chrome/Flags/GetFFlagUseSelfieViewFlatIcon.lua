local Chrome = script:FindFirstAncestor("Chrome")

game:DefineFastFlag("UseSelfieViewFlatIcon", false)

local IsExperienceMenuABTestEnabled = require(Chrome.Parent.IsExperienceMenuABTestEnabled)
local ExperienceMenuABTestManager = require(Chrome.Parent.ExperienceMenuABTestManager)

return function()
	if IsExperienceMenuABTestEnabled() and ExperienceMenuABTestManager.default:shouldShowStaticSelfView() then
		return true
	end

	return game:GetFastFlag("UseSelfieViewFlatIcon")
end
