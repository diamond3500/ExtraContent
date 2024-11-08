local Chrome = script:FindFirstAncestor("Chrome")

local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")

local ReactUtils = require(CorePackages.Packages.ReactUtils)
local React = require(CorePackages.Packages.React)
local UnibarMenu = require(Chrome.Unibar.UnibarMenu)
local UIBlox = require(CorePackages.UIBlox)
local RoactAppPolicy = require(CorePackages.Workspace.Packages.UniversalAppPolicy).RoactAppPolicy
local AppFeaturePolicies = require(CorePackages.Workspace.Packages.UniversalAppPolicy).AppFeaturePolicies
local VoiceStateContext = require(RobloxGui.Modules.VoiceChat.VoiceStateContext)

local SelectionCursorProvider = UIBlox.App.SelectionImage.SelectionCursorProvider

local function UnibarMenuWrapper(props: UnibarMenu.UnibarMenuProp)
	return React.createElement(ReactUtils.ContextStack, {
		providers = {
			React.createElement(VoiceStateContext.Provider),
			React.createElement(SelectionCursorProvider),
			React.createElement(RoactAppPolicy.Provider, {
				policy = {
					AppFeaturePolicies,
				},
			}),
		},
	}, {
		UnibarMenu = React.createElement(UnibarMenu, props),
	})
end

return UnibarMenuWrapper
