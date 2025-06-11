local CorePackages = game:GetService("CorePackages")
local makeActionCreator = require(script.Parent.makeActionCreator)
local FFlagEnabledEnhancedRobuxUpsellV2 = require(CorePackages.Workspace.Packages.SharedFlags).FFlagEnabledEnhancedRobuxUpsellV2

local actionCreator
if FFlagEnabledEnhancedRobuxUpsellV2 then
    actionCreator = makeActionCreator(script.Name, "robuxProductId", "productId", "robuxPurchaseAmount", "robuxAmountBeforeBonus", "price", "itemProductId", "itemName", "universeId")
else
    actionCreator = makeActionCreator(script.Name, "robuxProductId", "productId", "robuxPurchaseAmount", "robuxAmountBeforeBonus", "price")
end

return actionCreator
