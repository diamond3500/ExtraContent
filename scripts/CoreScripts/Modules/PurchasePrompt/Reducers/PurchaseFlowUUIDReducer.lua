local Root = script.Parent.Parent

local CorePackages = game:GetService("CorePackages")
local PurchasePromptDeps = require(CorePackages.Workspace.Packages.PurchasePromptDeps)
local Rodux = PurchasePromptDeps.Rodux

local SetPurchaseFlowUUID = require(Root.Actions.SetPurchaseFlowUUID)

local PurchaseFlowUUIDReducer = Rodux.createReducer("", {
	[SetPurchaseFlowUUID.name] = function(state, action)
		return action.purchaseFlowUUID
	end,
})

return PurchaseFlowUUIDReducer
