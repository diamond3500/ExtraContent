local root = script:FindFirstAncestor("AbuseReportMenu")
local CorePackages = game:GetService("CorePackages")

local ExperienceStateCaptureService = game:GetService("ExperienceStateCaptureService")

local TnSIXPWrapper = require(root.IXP.TnSIXPWrapper)
local GetFFlagSelectInSceneReportMenu =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagSelectInSceneReportMenu
local isInSelectInSceneReportMenuOverrideList = require(root.Utility.isInSelectInSceneReportMenuOverrideList)

local overrideEnabled = false
if GetFFlagSelectInSceneReportMenu() then
	task.defer(function()
		overrideEnabled = isInSelectInSceneReportMenuOverrideList()
	end)
end

return function()
	----------------------------------------------------
	-- Required in order to even try the other checks --
	if not GetFFlagSelectInSceneReportMenu() then
		return false
	end

	--------------------------------------
	-- Required for the feature to work --
	if not game:GetEngineFeature("SafetyServiceCaptureModeReportProp") then
		return false
	end

	if not game:GetEngineFeature("CaptureModeEnabled") then
		return false
	end

	if game:GetEngineFeature("ExperienceStateCaptureMinMemEnabled") then
		if not ExperienceStateCaptureService:CanEnterCaptureMode() then
			return false
		end
	end

	if not game:GetEngineFeature("ExperienceStateCaptureHiddenSelection") then
		return false
	end

	----------------------------------
	-- Gating access to the feature --
	if overrideEnabled then
		return true
	end

	if not TnSIXPWrapper.getSelectInSceneEnabled() then
		return false
	end

	return true
end
