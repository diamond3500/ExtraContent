local Root = script.Parent.Parent

local CorePackages = game:GetService("CorePackages")
local PurchasePromptDeps = require(CorePackages.Workspace.Packages.PurchasePromptDeps)
local Rodux = PurchasePromptDeps.Rodux

local SetPromptState = require(Root.Actions.SetPromptState)
local CompleteRequest = require(Root.Actions.CompleteRequest)
local ErrorOccurred = require(Root.Actions.ErrorOccurred)
local StartPurchase = require(Root.Actions.StartPurchase)
local PromptNativeUpsell = require(Root.Actions.PromptNativeUpsell)
local PromptNativeUpsellSuggestions = require(Root.Actions.PromptNativeUpsellSuggestions)
local PromptState = require(Root.Enums.PromptState)

local PromptStateReducer = Rodux.createReducer(PromptState.None, {
	[SetPromptState.name] = function(state, action)
		return action.promptState
	end,
	[CompleteRequest.name] = function(state, action)
		return PromptState.None
	end,
	[ErrorOccurred.name] = function(state, action)
		return PromptState.Error
	end,
	[StartPurchase.name] = function(state, action)
		return PromptState.PurchaseInProgress
	end,
	[PromptNativeUpsell.name] = function(state, action)
		return PromptState.RobuxUpsell
	end,
	[PromptNativeUpsellSuggestions.name] = function(state, action)
		return PromptState.RobuxUpsell
	end,
})

return PromptStateReducer
