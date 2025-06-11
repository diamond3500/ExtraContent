local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local LoggingProtocol = require(CorePackages.Workspace.Packages.LoggingProtocol)

local RobloxGui = CoreGui:WaitForChild("RobloxGui")

local FIntMenuButtonsThrottleHundredthsPercent = require(RobloxGui.Modules.Settings.Flags.FIntMenuButtonsThrottleHundredthsPercent)

type TelemetryEventConfig = LoggingProtocol.TelemetryEventConfig

return {
	eventName = "experienceMenuResetCharacter",
	backends = {
		LoggingProtocol.TelemetryBackends.Counter,
	},
	throttlingPercentage = FIntMenuButtonsThrottleHundredthsPercent,
	lastUpdated = { 25, 4, 23 },
	description = "Report when respawn button in experience menu is activated",
	-- links = "",
} :: TelemetryEventConfig
