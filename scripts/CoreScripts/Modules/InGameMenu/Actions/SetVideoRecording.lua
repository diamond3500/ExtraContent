local CorePackages = game:GetService("CorePackages")

local Action = require(CorePackages.Packages.Rodux).makeActionCreator

return Action("SET_VIDEO_RECORDING", function(recording)
	return {
		recording = recording,
	}
end)
