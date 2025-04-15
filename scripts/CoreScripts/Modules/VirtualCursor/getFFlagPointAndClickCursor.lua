game:DefineFastFlag("PointAndClickCursor", false)
game:DefineFastFlag("DirectionalAnalogStick", false)
game:DefineFastFlag("DirectionalAnalogStickBillboardGuiSupport", false)

local function getFFlagPointAndClickCursor()
    return game:GetFastFlag("PointAndClickCursor") and game:GetFastFlag("DirectionalAnalogStick") and game:GetFastFlag("DirectionalAnalogStickBillboardGuiSupport")
end

return getFFlagPointAndClickCursor
