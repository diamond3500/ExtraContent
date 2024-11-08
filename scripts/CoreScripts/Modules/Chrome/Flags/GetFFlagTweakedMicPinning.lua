local Chrome = script:FindFirstAncestor("Chrome")

game:DefineFastFlag("TweakedMicPinning2", false)

local IsExperienceMenuABTestEnabled = require(Chrome.Parent.IsExperienceMenuABTestEnabled)
local ExperienceMenuABTestManager = require(Chrome.Parent.ExperienceMenuABTestManager)

return function()
	if IsExperienceMenuABTestEnabled() and ExperienceMenuABTestManager.default:shouldDockMic() then
		return true
	end

	return game:GetFastFlag("TweakedMicPinning2")
end
