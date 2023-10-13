--!nonstrict
local CorePackages = game:GetService("CorePackages")

local initify = require(CorePackages.initify)
local GetFFlagUpgradeExpChatV4_2_4 = require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagUpgradeExpChatV4_2_4

initify(CorePackages.Packages)

if GetFFlagUpgradeExpChatV4_2_4() then
    return require(CorePackages.Packages.ExperienceChat_New)
else
    return require(CorePackages.Packages.ExperienceChat)
end
