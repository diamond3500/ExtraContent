local CorePackages = game:GetService("CorePackages")

local Requests = require(CorePackages.Workspace.Packages.Http).Requests

local Promise = require(CorePackages.AppTempCommon.LuaApp.Promise)
local ApiFetchUsersPresences = require(CorePackages.Workspace.Packages.UserLib).Thunks.ApiFetchUsersPresences
local UsersGetFriends = Requests.UsersGetFriends
--[[
	FIXME(dbanks)
	2023/12/14
	Remove with FFlagStopReadingThumbsOutOfStore
]]
local DEPRECATED_StoreUsersThumbnail =
	require(CorePackages.Workspace.Packages.UserLib).Thunks.DEPRECATED_StoreUsersThumbnail

local FetchUserFriendsStarted = require(CorePackages.Workspace.Packages.LegacyFriendsRodux).Actions.FetchUserFriendsStarted
local FetchUserFriendsFailed = require(CorePackages.Workspace.Packages.LegacyFriendsRodux).Actions.FetchUserFriendsFailed
local FetchUserFriendsCompleted = require(CorePackages.Workspace.Packages.LegacyFriendsRodux).Actions.FetchUserFriendsCompleted
local UserModel = require(CorePackages.Workspace.Packages.UserLib).Models.UserModel
local UpdateUsers = require(CorePackages.Workspace.Packages.UserLib).Thunks.UpdateUsers

local GetFFlagInviteListRerank = require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagInviteListRerank
local FFlagStopReadingThumbsOutOfStore = require(CorePackages.Workspace.Packages.SharedFlags).FFlagStopReadingThumbsOutOfStore

return function(requestImpl, userId, thumbnailRequest, userSort)
	return function(store)
		store:dispatch(FetchUserFriendsStarted(userId))

		return UsersGetFriends(requestImpl, userId, userSort)
			:andThen(function(response)
				local responseBody = response.responseBody

				local userIds = {}
				local newUsers = {}
				for rank, userData in pairs(responseBody.data) do
					local id = tostring(userData.id)
					userData.isFriend = true

					if GetFFlagInviteListRerank() then
						userData.friendRank = rank
					end

					local newUser = UserModel.fromDataTable(userData)

					table.insert(userIds, id)
					newUsers[newUser.id] = newUser
				end
				store:dispatch(UpdateUsers(newUsers))

				return userIds
			end)
			:andThen(function(userIds)
				if not FFlagStopReadingThumbsOutOfStore then
					store:dispatch(DEPRECATED_StoreUsersThumbnail(userIds, thumbnailRequest))
				end
				return store:dispatch(ApiFetchUsersPresences(requestImpl, userIds))
			end)
			:andThen(function(result)
				store:dispatch(FetchUserFriendsCompleted(userId))

				return Promise.resolve(result)
			end, function(response)
				store:dispatch(FetchUserFriendsFailed(userId, response))
				return Promise.reject(response)
			end)
	end
end
