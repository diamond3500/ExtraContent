local HTTPService = game:GetService("HttpService")

game:DefineFastFlag("PointAndClickCursor", false)
game:DefineFastFlag("GamepadPointAndClick", false)
game:DefineFastFlag("GamepadDirectionalOverrideByUniverseIDEnabled", false)
game:DefineFastString("GamepadDirectionalOverrideByUniverseID", "{\"allowlist\":[]}")

local Overrides = HTTPService:JSONDecode(game:GetFastString("GamepadDirectionalOverrideByUniverseID"))

local allowed = table.find(Overrides.allowlist or {}, game.GameId) ~= nil

local function getFFlagPointAndClickCursor()
    return game:GetFastFlag("PointAndClickCursor") and game:GetFastFlag("GamepadPointAndClick") and (not game:GetFastFlag("GamepadDirectionalOverrideByUniverseIDEnabled") or allowed)
end

return getFFlagPointAndClickCursor
