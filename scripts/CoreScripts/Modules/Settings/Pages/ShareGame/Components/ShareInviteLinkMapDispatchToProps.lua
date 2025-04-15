local CorePackages = game:GetService("CorePackages")
local dependencies = require(CorePackages.Workspace.Packages.NotificationsCommon).ReducerDependencies

local FFlagEnableLuaAppsShareLinksPackages = require(CorePackages.Workspace.Packages.SharedFlags).FFlagEnableLuaAppsShareLinksPackages

local NetworkingShareLinks = dependencies.NetworkingShareLinks
local RoduxShareLinks = dependencies.RoduxShareLinks
local ShareLinksNetworking = dependencies.ShareLinksNetworking
local ShareLinksRodux = dependencies.ShareLinksRodux

local mapDispatchToProps = function(dispatch)
    return {
        fetchShareInviteLink = function()
            if FFlagEnableLuaAppsShareLinksPackages then
                dispatch((ShareLinksNetworking :: any).GenerateLink.API({ linkType = (ShareLinksRodux :: any).Enums.LinkType.ExperienceInvite.rawValue() })) -- Remove any cast with FFlagEnableLuaAppsShareLinksPackages
            else
                dispatch(NetworkingShareLinks.GenerateLink.API({ linkType = RoduxShareLinks.Enums.LinkType.ExperienceInvite.rawValue() }))
            end
        end
    }
end

export type Props = typeof(mapDispatchToProps(...))

return mapDispatchToProps
