--!nonstrict
local MIN_ENGINE_MOUSE_SENSITIVITY = 0
local MAX_ENGINE_MOUSE_SENSITIVITY = 10
local MIN_GUI_MOUSE_SENSITIVITY = 0
local MAX_GUI_MOUSE_SENSITIVITY = 10
local GUI_MOUSE_SENSITIVITY_GRANULARITY = 0.01

local UserGameSettings = UserSettings():GetService("UserGameSettings")
local CorePackages = game:GetService("CorePackages")

local InGameMenuDependencies = require(CorePackages.Packages.InGameMenuDependencies)
local Roact = InGameMenuDependencies.Roact
local t = InGameMenuDependencies.t

local sensitivityEvents = {
	UserGameSettings:GetPropertyChangedSignal("GamepadCameraSensitivity"),
	UserGameSettings:GetPropertyChangedSignal("MouseSensitivity"),
	UserGameSettings:GetPropertyChangedSignal("MouseSensitivityFirstPerson"),
	UserGameSettings:GetPropertyChangedSignal("MouseSensitivityThirdPerson"),
}

local InGameMenu = script.Parent.Parent.Parent

local ExternalEventConnection = require(InGameMenu.Utility.ExternalEventConnection)
local SliderEntry = require(script.Parent.SliderEntry)

local SendAnalytics = require(InGameMenu.Utility.SendAnalytics)
local Constants = require(InGameMenu.Resources.Constants)

local function guiToEngineSensitivity(guiSensitivity)
	local engineSensitivity
	if guiSensitivity <= 5 then
		engineSensitivity = 0.198 * guiSensitivity + 0.01
	else
		engineSensitivity = 0.6 * guiSensitivity - 2
	end

	return math.clamp(engineSensitivity, MIN_ENGINE_MOUSE_SENSITIVITY, MAX_ENGINE_MOUSE_SENSITIVITY)
end

local function engineToGuiSensitivity(engineSensitivity)
	local guiSensitivity
	if engineSensitivity <= 1 then
		guiSensitivity = (engineSensitivity - 0.01) / 0.198
	else
		guiSensitivity = (engineSensitivity + 2) / 0.6
	end

	guiSensitivity = math.floor(guiSensitivity / GUI_MOUSE_SENSITIVITY_GRANULARITY + 0.5)
		* GUI_MOUSE_SENSITIVITY_GRANULARITY

	return math.clamp(guiSensitivity, MIN_GUI_MOUSE_SENSITIVITY, MAX_GUI_MOUSE_SENSITIVITY)
end

local CameraSensitivityEntry = Roact.PureComponent:extend("CameraSensitivityEntry")
CameraSensitivityEntry.validateProps = t.strictInterface({
	LayoutOrder = t.integer,
	canCaptureFocus = t.optional(t.boolean),
	isMenuOpen = t.optional(t.boolean),
})

function CameraSensitivityEntry:init()
	self.onSensitivityChanged = function()
		self:setState({
			-- TODO: Implement gamepad sensitivity.
			engineSensitivity = UserGameSettings.MouseSensitivityFirstPerson.X,
		})
	end

	self.onSensitivityChanged()
end

function CameraSensitivityEntry:render()
	local children = {
		-- TODO: Switch to gamepad sensitivity when appropriate
		CameraSensitivityMouseSlider = Roact.createElement(SliderEntry, {
			LayoutOrder = self.props.LayoutOrder,
			labelKey = "CoreScripts.InGameMenu.GameSettings.CameraSensitivity",
			value = engineToGuiSensitivity(self.state.engineSensitivity),
			min = MIN_GUI_MOUSE_SENSITIVITY,
			max = MAX_GUI_MOUSE_SENSITIVITY,
			stepInterval = 1,
			keyboardInputStepInterval = GUI_MOUSE_SENSITIVITY_GRANULARITY,
			valueChanged = function(value)
				local newEngineSensitivity = guiToEngineSensitivity(value)
				local engineSensitivityVector = Vector2.new(newEngineSensitivity, newEngineSensitivity)
				UserGameSettings.MouseSensitivityFirstPerson = engineSensitivityVector
				UserGameSettings.MouseSensitivityThirdPerson = engineSensitivityVector
				SendAnalytics(Constants.AnalyticsSettingsChangeName, nil, {}, true)
			end,
			canCaptureFocus = self.props.canCaptureFocus,
			isMenuOpen = self.props.isMenuOpen,
		}),
	}

	for _, event in ipairs(sensitivityEvents) do
		children[tostring(event) .. "CameraSensitivityControlConnection"] =
			Roact.createElement(ExternalEventConnection, {
				event = event,
				callback = self.onSensitivityChanged,
			})
	end

	return Roact.createFragment(children)
end

return CameraSensitivityEntry
