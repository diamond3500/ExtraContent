--!nonstrict

-------------- SERVICES --------------
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui.RobloxGui
local Url = require(RobloxGui.Modules.Common.Url)
local HttpRbxApiService = game:GetService("HttpRbxApiService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local FFlagEnableServerGetUserPosts = game:DefineFastFlag("EnableServerGetUserPosts", false)

----------- BINDABLES --------------
local BatchUpdatePostScores = Instance.new("BindableFunction")
local GetUserPosts = Instance.new("BindableFunction")

----------- UTILS --------------
local function transformPost(post)
	if post.screenshotMetadata then
		if post.screenshotMetadata.fullSizeUrl then
			post.screenshotMetadata.fullSizeUrl = nil
			post.screenshotMetadata.contentId = "rbxpost://" .. post.postId
		end
	end
end

local function transformPosts(posts)
	for _, post in ipairs(posts) do
		transformPost(post)
	end
end

----------- METHODS --------------
local function onBatchUpdatePostScores(postScores, userId)
	-- Guard required parameters
	if not postScores then
		error("postScores cannot be nil")
	end

	-- Construct the API path
	local apiPath = "posts-api/v1/content-posts/batchUpdateExperienceRankingScores"
	local url = string.format("%s%s", Url.APIS_URL, apiPath)

	local request = HttpService:JSONEncode(
		{
			experienceRankingScores = postScores
		}
	)

	if userId ~= nil then
		request = HttpService:JSONEncode(
			{
				experienceRankingScores = postScores,
				userId = userId
			}
		)
	end

	-- Make the HTTP request
	local success, result = pcall(HttpRbxApiService.PostAsyncFullUrl, HttpRbxApiService, url, request)
	return success, result
end

local function onGetUserPosts(userId, postTypeFilter, sortOrder, cursor, limit)
	-- Guard required parameters
	if userId == nil then 
		error(`userId cannot be nil`)
	end

	-- Construct the API path and parameters
	local apiPath = "posts-api/v1/content-posts/findByUser"

	local params = "userId=" .. userId
	if postTypeFilter then
		if typeof(postTypeFilter) == "table" then
			postTypeFilter = table.concat(postTypeFilter, ",")
		end
		params = params .. "&postTypeFilter=" .. postTypeFilter
	end
	if sortOrder then
		params = params .. "&sortOrder=" .. sortOrder
	end
	if cursor ~= nil then 
		params = params .. "&cursor=" .. cursor
	end
	if limit ~= nil then 
		params = params .. "&limit=" .. limit
	end

	local url = string.format("%s%s?%s", Url.APIS_URL, apiPath, params)

	-- Make the HTTP request
	local success, result = pcall(HttpRbxApiService.GetAsyncFullUrl, HttpRbxApiService, url)
	if success then
		local data = HttpService:JSONDecode(result)
		if data["posts"] ~= nil then
			transformPosts(data["posts"])
		end
		return success, data
	end
	return success, {errorMessage = result}
end

----------- CONNECTIONS --------------
BatchUpdatePostScores.Name = "BatchUpdatePostScores"
BatchUpdatePostScores.Parent = ReplicatedStorage
BatchUpdatePostScores.OnInvoke = onBatchUpdatePostScores

-- FindPostsByUser
-- Note: This is added to ServerStorage to prevent a collision with
-- the existing GetUserPosts BindableFunction in ReplicatedStorage
if FFlagEnableServerGetUserPosts then
	GetUserPosts.Name = "GetUserPosts"
	GetUserPosts.Parent = ServerStorage
	GetUserPosts.OnInvoke = onGetUserPosts
end
