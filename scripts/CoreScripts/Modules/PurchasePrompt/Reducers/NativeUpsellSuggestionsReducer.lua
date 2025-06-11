local Root = script.Parent.Parent

local CorePackages = game:GetService("CorePackages")
local PurchasePromptDeps = require(CorePackages.Workspace.Packages.PurchasePromptDeps)
local Rodux = PurchasePromptDeps.Rodux

local PromptNativeUpsellSuggestions = require(Root.Actions.PromptNativeUpsellSuggestions)

return Rodux.createReducer({}, {
	[PromptNativeUpsellSuggestions.name] = function(state, action)
		local newState = {
			products = action.products,
			selection = action.selection,
			virtualItemBadgeType = action.virtualItemBadgeType,
		}
		return newState
	end,
})