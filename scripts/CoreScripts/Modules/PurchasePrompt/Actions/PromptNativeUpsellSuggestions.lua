local CorePackages = game:GetService("CorePackages")
local makeActionCreator = require(script.Parent.makeActionCreator)

return makeActionCreator(script.Name, "products", "selection", "virtualItemBadgeType")

