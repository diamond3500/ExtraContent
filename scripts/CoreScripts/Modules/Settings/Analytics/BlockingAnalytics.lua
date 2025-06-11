local CorePackages = game:GetService("CorePackages")
local PlayersService = game:GetService("Players")
local AnalyticsService = game:GetService("RbxAnalyticsService")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Cryo = require(CorePackages.Packages.Cryo)

local FFlagNavigateToBlockingModal = require(Modules.Common.Flags.FFlagNavigateToBlockingModal)

local BlockingAnalytics = {}
BlockingAnalytics.__index = BlockingAnalytics

local LocalPlayer = nil :: never
if FFlagNavigateToBlockingModal then
	LocalPlayer = PlayersService.LocalPlayer
	while not LocalPlayer do
		PlayersService:GetPropertyChangedSignal("LocalPlayer"):Wait()
		LocalPlayer = PlayersService.LocalPlayer
	end
end

function BlockingAnalytics.new(
	localUserId: number?, config: { EventStream: any? }?
)
	if FFlagNavigateToBlockingModal then
		localUserId = localUserId or LocalPlayer.UserId
	end

	assert(localUserId, "BlockingAnalytics must be passed the ID of the local user")

	local self = {
		_eventStreamImpl = if FFlagNavigateToBlockingModal
			then config and config.EventStream or AnalyticsService
			else (config :: any).EventStream,
		localUserId = localUserId,
	}
	setmetatable(self, BlockingAnalytics)

	return self
end

function BlockingAnalytics:action(eventContext, actionName, additionalArgs)
	local target = "AccountSettingsApi"

	additionalArgs = Cryo.Dictionary.join(additionalArgs or {}, {
		blockerUserId = self.localUserId,
	})

	self._eventStreamImpl:SendEventDeferred(target, eventContext, actionName, additionalArgs)
end

return BlockingAnalytics
