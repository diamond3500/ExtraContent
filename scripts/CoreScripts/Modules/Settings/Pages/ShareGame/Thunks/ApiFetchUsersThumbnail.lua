-- FIXME(dbanks)
-- 2023/06/15
-- Remove with FFlagWriteRbxthumbsIntoStore
local CorePackages = game:GetService("CorePackages")

local Requests = require(CorePackages.Workspace.Packages.Http).Requests

local UsersGetThumbnail = Requests.UsersGetThumbnail

local SetUserThumbnail = require(CorePackages.Workspace.Packages.UserLib).Actions.SetUserThumbnail
local Promise = require(CorePackages.AppTempCommon.LuaApp.Promise)

local function fetchThumbnailsBatch(userIds, thumbnailRequest)
	local fetchedPromises = {}

	for _, userId in pairs(userIds) do
		table.insert(fetchedPromises,
			UsersGetThumbnail(userId, thumbnailRequest.thumbnailType, thumbnailRequest.thumbnailSize)
		)
	end

	return Promise.all(fetchedPromises)
end

return function(networkImpl, userIds, thumbnailRequests)
	return function(store)
		-- We currently cannot batch request user avatar thumbnails,
		-- so each thumbnailRequest has to be processed individually.

		local fetchedPromises = {}
		for _, thumbnailRequest in pairs(thumbnailRequests) do
			table.insert(fetchedPromises,
				fetchThumbnailsBatch(userIds, thumbnailRequest):andThen(function(result)
					for _, data in pairs(result) do
						store:dispatch(SetUserThumbnail(data.id, data.image, data.thumbnailType, data.thumbnailSize))
					end
				end)
			)
		end

		return Promise.all(fetchedPromises)
	end
end
