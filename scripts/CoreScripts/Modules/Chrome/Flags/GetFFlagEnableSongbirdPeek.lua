local Chrome = script:FindFirstAncestor("Chrome")

local IsExperienceMenuABTestEnabled = require(Chrome.Parent.IsExperienceMenuABTestEnabled)
local ExperienceMenuABTestManager = require(Chrome.Parent.ExperienceMenuABTestManager)

game:DefineFastFlag("EnableSongbirdPeek", false)

return function()
	if IsExperienceMenuABTestEnabled() and ExperienceMenuABTestManager.default:shouldShowSongbirdPeek() then
		return true
	end

	return game:GetFastFlag("EnableSongbirdPeek")
end
