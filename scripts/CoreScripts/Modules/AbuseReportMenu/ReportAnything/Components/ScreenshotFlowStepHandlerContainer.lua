local root = script:FindFirstAncestor("AbuseReportMenu")
local CorePackages = game:GetService("CorePackages")

local React = require(CorePackages.Packages.React)
local Constants = require(root.ReportAnything.Resources.Constants)

local ScreenshotFlowStepHandler = require(script.Parent.ScreenshotFlowStepHandler)

local ScreenshotFlowStepHandlerContainer = React.PureComponent:extend("ScreenshotFlowStepHandlerContainer")

local CoreScriptsRootProvider = require(CorePackages.Workspace.Packages.CoreScriptsRoactCommon).CoreScriptsRootProvider
local FocusNavigationUtils = require(CorePackages.Workspace.Packages.FocusNavigationUtils)
local FocusNavigationCoreScriptsWrapper = FocusNavigationUtils.FocusNavigationCoreScriptsWrapper
local FocusRoot = FocusNavigationUtils.FocusRoot
local FocusNavigableSurfaceIdentifierEnum = FocusNavigationUtils.FocusNavigableSurfaceIdentifierEnum

local FFlagCSFocusWrapperRefactor = require(CorePackages.Workspace.Packages.SharedFlags).FFlagCSFocusWrapperRefactor

export type Props = ScreenshotFlowStepHandler.Props

function ScreenshotFlowStepHandlerContainer:render()
	return React.createElement(CoreScriptsRootProvider, {}, {
		FocusNavigationCoreScriptsWrapper = React.createElement(
			if FFlagCSFocusWrapperRefactor then FocusRoot else FocusNavigationCoreScriptsWrapper,
			if FFlagCSFocusWrapperRefactor
				then {
					surfaceIdentifier = FocusNavigableSurfaceIdentifierEnum.CentralOverlay,
					isIsolated = true,
					isAutoFocusRoot = true,
				}
				else {
					selectionGroupName = Constants.ScreenshotFlowStepHandlerRootName,
					focusNavigableSurfaceIdentifier = FocusNavigableSurfaceIdentifierEnum.CentralOverlay,
				},
			{

				ScreenshotFlowStepHandlerContainer = React.createElement(ScreenshotFlowStepHandler, self.props),
			}
		),
	})
end

return ScreenshotFlowStepHandlerContainer
