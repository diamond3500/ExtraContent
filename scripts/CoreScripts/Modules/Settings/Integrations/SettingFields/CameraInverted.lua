--[[
	This module represents the Camera Inverted setting option in the In-Experience Menu Settings page
]]

local Settings = script:FindFirstAncestor("Settings")
local CorePackages = game:GetService("CorePackages")
local UserSettings = UserSettings()
local UserGameSettings = UserSettings.GameSettings

-- Modules
local SettingsServiceLib = require(CorePackages.Workspace.Packages.SettingsService)
local ValueChangedSignal = SettingsServiceLib.ValueChangedSignal
local AvailabilitySignal = SettingsServiceLib.AvailabilitySignal
local FieldType = SettingsServiceLib.FieldType
local Constants = require(Settings.Integrations.Constants)

-- Constants
local SettingsLayoutOrder = Constants.GAMESETTINGS.LAYOUT_ORDER

-- Core Module

local function CameraInvertedValue()
	local value = ValueChangedSignal.new(UserGameSettings.CameraYInverted)

	value:connect(function(cameraInverted: boolean)
		local oldCameraInverted = UserGameSettings.CameraYInverted
		if oldCameraInverted == cameraInverted then
			return
		end
		UserGameSettings.CameraYInverted = cameraInverted
	end, true)

	return value
end

local function CameraInvertedAvailability()
	local availability = AvailabilitySignal.new(UserGameSettings.IsUsingCameraYInverted)

	UserGameSettings.Changed:Connect(function(prop)
		if prop == "IsUsingCameraYInverted" then
			availability:set(UserGameSettings.IsUsingCameraYInverted)
		end
	end)

	return availability
end

local CameraInvertedConfig = {
	id = "camera-inverted",
	field_type = FieldType.Toggle,
	label = "CoreScripts.InGameMenu.GameSettings.InvertedCamera",
	alreadyLocalized = false,
	onChanged = CameraInvertedValue(),
	availability = CameraInvertedAvailability(),
	layoutOrder = SettingsLayoutOrder.CameraInvertedFrame,
} :: SettingsServiceLib.ToggleRegisterConfig

return CameraInvertedConfig
