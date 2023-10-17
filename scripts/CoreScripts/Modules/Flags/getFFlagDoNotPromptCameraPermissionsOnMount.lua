local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")

-- Blocking flags due to getCamMicPermissions bugs below
local getFFlagDecoupleHasAndRequestPermissions = require(RobloxGui.Modules.Flags.getFFlagDecoupleHasAndRequestPermissions)
local getFFlagPermissionsEarlyOutStallsQueue = require(RobloxGui.Modules.Flags.getFFlagPermissionsEarlyOutStallsQueue)

game:DefineFastFlag("DoNotPromptCameraPermissionsOnMount", false)

return function()
    return (game:GetFastFlag("DoNotPromptCameraPermissionsOnMount")
        and getFFlagDecoupleHasAndRequestPermissions()
        and getFFlagPermissionsEarlyOutStallsQueue())
end
