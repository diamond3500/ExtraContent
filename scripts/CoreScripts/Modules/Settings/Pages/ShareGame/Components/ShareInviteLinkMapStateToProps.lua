local CorePackages = game:GetService("CorePackages")
local dependencies = require(CorePackages.Workspace.Packages.NotificationsCommon).ReducerDependencies

local FFlagEnableLuaAppsShareLinksPackages = require(CorePackages.Workspace.Packages.SharedFlags).FFlagEnableLuaAppsShareLinksPackages

local NetworkingShareLinks = dependencies.NetworkingShareLinks
local RoduxShareLinks = dependencies.RoduxShareLinks
local ShareLinksNetworking = dependencies.ShareLinksNetworking
local ShareLinksRodux = dependencies.ShareLinksRodux


local mapStateToProps = function(state)
	return {
		shareInviteLink = state.ShareLinks.Invites.ShareInviteLink :: {
			shortUrl: string?,
			linkId: string?,
		},
		fetchShareInviteLinkNetworkStatus = if FFlagEnableLuaAppsShareLinksPackages then
			(ShareLinksNetworking :: any).GenerateLink.getStatus(state, { linkType = (ShareLinksRodux :: any).Enums.LinkType.ExperienceInvite.rawValue() }) :: string -- Remove any cast with FFlagEnableLuaAppsShareLinksPackages
			else NetworkingShareLinks.GenerateLink.getStatus(state, { linkType = RoduxShareLinks.Enums.LinkType.ExperienceInvite.rawValue() }) :: string,
	}
end

export type Props = typeof(mapStateToProps(...))

return mapStateToProps
