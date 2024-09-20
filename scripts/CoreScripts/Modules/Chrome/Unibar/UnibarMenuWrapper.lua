local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")

local ReactUtils = require(CorePackages.Workspace.Packages.ReactUtils)
local React = require(CorePackages.Packages.React)
local UnibarMenu = require(script.Parent.UnibarMenu)
local ReactSceneUnderstanding = require(CorePackages.Packages.ReactSceneUnderstanding)
local UIBlox = require(CorePackages.UIBlox)
local VoiceStateContext = require(RobloxGui.Modules.VoiceChat.VoiceStateContext)

local SelectionCursorProvider = UIBlox.App.SelectionImage.SelectionCursorProvider

local GetFFlagUnibarSceneAnalysisContext =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagUnibarSceneAnalysisContext
local GetFIntUnibarSceneAnalysisMaxScreenDivisions =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFIntUnibarSceneAnalysisMaxScreenDivisions
local GetFIntUnibarSceneAnalysisMaxDistance =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFIntUnibarSceneAnalysisMaxScreenDivisions

local function UnibarMenuWrapper(props: UnibarMenu.UnibarMenuProp)
	return React.createElement(ReactUtils.ContextStack, {
		providers = if GetFFlagUnibarSceneAnalysisContext()
			then {
				React.createElement(ReactSceneUnderstanding.SceneAnalysisProvider, {
					viewportQueryOptions = {
						maxScreenDivisions = GetFIntUnibarSceneAnalysisMaxScreenDivisions(),
					},
					rangeQueryOptions = {
						maxDistance = GetFIntUnibarSceneAnalysisMaxDistance(),
					},
				}),
				React.createElement(VoiceStateContext.Provider),
				React.createElement(SelectionCursorProvider),
			}
			else {
				React.createElement(VoiceStateContext.Provider),
				React.createElement(SelectionCursorProvider),
			},
	}, {
		UnibarMenu = React.createElement(UnibarMenu, props),
	})
end

return UnibarMenuWrapper
