local Chrome = script:FindFirstAncestor("Chrome")

local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")

local ChromeService = require(Chrome.Service)
local CommonIcon = require(Chrome.Integrations.CommonIcon)
local ChromeUtils = require(Chrome.Service.ChromeUtils)
local ScreenshotsApp = require(RobloxGui.Modules.Screenshots.ScreenshotsApp)
local MappedSignal = ChromeUtils.MappedSignal

local GetFFlagChromeCapturesToggle = require(Chrome.Flags.GetFFlagChromeCapturesToggle)
local GetFFlagEnableScreenshotUtility =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagEnableScreenshotUtility
local GetFFlagEnableToggleCaptureIntegration =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagEnableToggleCaptureIntegration
local GetFFlagFixCapturesAvailability = require(Chrome.Flags.GetFFlagFixCapturesAvailability)
local GetFFlagAddChromeActivatedEvents = require(Chrome.Flags.GetFFlagAddChromeActivatedEvents)

local initialAvailability = ChromeService.AvailabilitySignal.Available
if GetFFlagChromeCapturesToggle() then
	if
		StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.All) or StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Captures)
	then
		initialAvailability = ChromeService.AvailabilitySignal.Available
	else
		initialAvailability = ChromeService.AvailabilitySignal.Unavailable
	end
end

local isActive
if GetFFlagEnableToggleCaptureIntegration() then
	isActive = MappedSignal.new(ScreenshotsApp.onIsActiveChanged, function()
		return ScreenshotsApp.getIsActive()
	end)
end

local cameraEntrypointIntegration = GetFFlagEnableScreenshotUtility()
		and ChromeService:register({
			initialAvailability = initialAvailability,
			id = "camera_entrypoint",
			label = "Feature.SettingsHub.Label.Captures",
			activated = function(self)
				if GetFFlagEnableToggleCaptureIntegration() then
					ScreenshotsApp.onToggleActivationFromChrome()
				else
					ChromeService:toggleCompactUtility("camera_utility")
				end
			end,
			isActivated = if GetFFlagAddChromeActivatedEvents()
				then function()
					return isActive:get()
				end
				else nil,
			components = {
				Icon = function(props)
					if GetFFlagEnableToggleCaptureIntegration() then
						return CommonIcon("icons/controls/cameraOff", "icons/controls/cameraOn", isActive)
					else
						return CommonIcon("icons/controls/cameraOff")
					end
				end,
			},
		})
	or nil

-- TODO: APPEXP-1879 Remove cameraEntrypointIntegration from this predicate when cleaning up GetFFlagEnableScreenshotUtility
if GetFFlagFixCapturesAvailability() and cameraEntrypointIntegration then
	ChromeUtils.setCoreGuiAvailability(cameraEntrypointIntegration, Enum.CoreGuiType.Captures)
elseif GetFFlagChromeCapturesToggle() then
	StarterGui.CoreGuiChangedSignal:Connect(function(coreGuiType, _enabled)
		if coreGuiType == Enum.CoreGuiType.All or coreGuiType == Enum.CoreGuiType.Captures then
			local integration: any = cameraEntrypointIntegration
			if integration == nil then
				return
			end
			ChromeUtils.setCoreGuiAvailability(integration, coreGuiType, function(enabled)
				local cameraEntryPointAvailabilitySignal: any = integration.availability
				if enabled then
					cameraEntryPointAvailabilitySignal:available()
				else
					if ChromeService:getCurrentUtility():get() == "camera_utility" then
						ChromeService:toggleCompactUtility("camera_utility")
					end
					cameraEntryPointAvailabilitySignal:unavailable()
				end
			end)
		end
	end)
end

-- function _toggleCaptures()
-- 	while true do
-- 		task.wait(3)
-- 		StarterGui:SetCoreGuiEnabled(
-- 			Enum.CoreGuiType.Captures,
-- 			not StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Captures)
-- 		)
-- 	end
-- end

-- coroutine.resume(coroutine.create(_toggleCaptures))

return cameraEntrypointIntegration
