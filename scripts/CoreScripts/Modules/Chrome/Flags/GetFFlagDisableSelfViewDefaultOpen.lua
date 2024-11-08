local Chrome = script:FindFirstAncestor("Chrome")

game:DefineFastFlag("DisableSelfViewDefaultOpen", false)

local IsExperienceMenuABTestEnabled = require(Chrome.Parent.IsExperienceMenuABTestEnabled)
local ExperienceMenuABTestManager = require(Chrome.Parent.ExperienceMenuABTestManager)

return function()
	if IsExperienceMenuABTestEnabled() and ExperienceMenuABTestManager.default:shouldCloseSelfViewAtStartup() then
		return true
	end

	return game:GetFastFlag("DisableSelfViewDefaultOpen")
end
