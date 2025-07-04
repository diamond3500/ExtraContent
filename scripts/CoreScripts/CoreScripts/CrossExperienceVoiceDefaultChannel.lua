--!nonstrict

local CorePackages = game:GetService("CorePackages")
local NotificationService = game:GetService("NotificationService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Promise = require(CorePackages.Packages.Promise)
local AnalyticsService = game:GetService("RbxAnalyticsService")


local PlayerAudioFocusChanged = ReplicatedStorage:WaitForChild("PlayerAudioFocusChanged")

local VoiceChatCore = require(CorePackages.Workspace.Packages.VoiceChatCore)
local PermissionsProtocol = require(CorePackages.Workspace.Packages.PermissionsProtocol).PermissionsProtocol.default
local Rodux = require(CorePackages.Packages.Rodux)
local Cryo = require(CorePackages.Packages.Cryo)
local CrossExperience = require(CorePackages.Workspace.Packages.CrossExperience)
local CoreVoiceManager = VoiceChatCore.CoreVoiceManager.default
local createPersistenceMiddleware = CrossExperience.Middlewares.createPersistenceMiddleware

local BlockingUtility = require(CorePackages.Workspace.Packages.BlockingUtility)

local SharedFlags = require(CorePackages.Workspace.Packages.SharedFlags)
local FFlagEnableVoiceChatMuteForVideoCaptures = SharedFlags.GetFFlagEnableVoiceChatMuteForVideoCaptures()

local CaptureService = if FFlagEnableVoiceChatMuteForVideoCaptures then game:GetService("CaptureService") else nil

local LuauPolyfill = require(CorePackages.Packages.LuauPolyfill)
local FFlagPartyVoiceBlockSync = SharedFlags.FFlagPartyVoiceBlockSync
local FFlagPartyVoiceBypassCheck = SharedFlags.FFlagPartyVoiceBypassCheck
local GetFFlagVoiceChatClientRewriteMasterLua = SharedFlags.GetFFlagVoiceChatClientRewriteMasterLua

local FFlagUseNotificationServiceIsConnected = game:DefineFastFlag("UseNotificationServiceIsConnected", false)
local FFlagDefaultChannelEnableDefaultVoice = game:DefineFastFlag("DefaultChannelEnableDefaultVoice", true)
local FFlagAlwaysJoinWhenUsingAudioAPI = game:DefineFastFlag("AlwaysJoinWhenUsingAudioAPI", false)
local FFlagDefaultChannelDontWaitOnCharacterWithAudioApi =
	game:DefineFastFlag("DefaultChannelDontWaitOnCharacterWithAudioApi", false)
local FFlagEnableCrossExpVoiceDebug = game:DefineFastFlag("EnableCrossExpVoiceDebug", false)
local GetFFlagEnableLuaVoiceChatAnalytics = require(VoiceChatCore.Flags.GetFFlagEnableLuaVoiceChatAnalytics)
local GetFFlagFixSeamlessVoiceIntegrationWithPrivateVoice =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagFixSeamlessVoiceIntegrationWithPrivateVoice
local GetFFlagEnableCrossExperienceVoiceCaptureMute =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagEnableCrossExperienceVoiceCaptureMute
local FFlagLogPartyVoiceReconnect = game:DefineFastFlag("LogPartyVoiceReconnect", false)
local FFlagPartyVoiceReportJoinFailed = game:DefineFastFlag("PartyVoiceReportJoinFailed", false)
local FFlagPartyVoiceCatchError = game:DefineFastFlag("PartyVoiceCatchError", false)
local FFlagPartyVoiceExecuteVoiceActionsPostAsyncInit = game:DefineFastFlag("PartyVoiceExecuteVoiceActionsPostAsyncInit", false)

local EnableDefaultVoiceAvailable = game:GetEngineFeature("VoiceServiceEnableDefaultVoiceAvailable")
local NotificationServiceIsConnectedAvailable = game:GetEngineFeature("NotificationServiceIsConnectedAvailable")
local AudioFocusManagementEnabled = game:GetEngineFeature("AudioFocusManagement")

local log = require(CorePackages.Workspace.Packages.CoreScriptsInitializer).CoreLogger:new(script.Name)
local Analytics = VoiceChatCore.Analytics.new()
local observeCurrentContextId = CrossExperience.Utils.observeCurrentContextId

local VoiceChatService = game:GetService("VoiceChatService")

type Promise<T> = LuauPolyfill.Promise<T>

type VoiceStatus = CrossExperience.VoiceStatus
local Constants = CrossExperience.Constants
local VOICE_STATUS = Constants.VOICE_STATUS

local FFlagFixPartyVoiceGetPermissions = SharedFlags.GetFFlagFixPartyVoiceGetPermissions()
local FFlagEnableCoreVoiceManagerPassErrorInReject = SharedFlags.FFlagEnableCoreVoiceManagerPassErrorInReject

if GetFFlagFixSeamlessVoiceIntegrationWithPrivateVoice() then
	CoreVoiceManager:setOptions({
		allowSeamlessVoice = false,
		passInitErrorInPromiseReject = true,
		forceVoiceEnabled = FFlagPartyVoiceBypassCheck,
	})
end

local PersistenceMiddleware = createPersistenceMiddleware({
	storeKey = CrossExperience.Constants.STORAGE_CEV_STORE_KEY,
})

local PartyAudioPlayer = CrossExperience.PartyAudioPlayer.default

local createReducers = function()
	-- In order to simplify the data sync between this background state and foreground state I am using the expected foreground store shape
	return Rodux.combineReducers({
		Squad = Rodux.combineReducers({
			CrossExperienceVoice = CrossExperience.installReducer(),
		}),
	})
end

local executePostVoiceAsyncInit = function(callback)
	CoreVoiceManager:asyncInit()
		:andThen(function()
			callback()
		end)
		:catch(function(err)
			log:info("CoreVoiceManager did not initialize {}", err)
		end)
end

local coreVoiceManagerState = {
	previousGroupId = nil,
	previousMutedState = false,
}
local cevEventManager = CrossExperience.EventManager.new(CrossExperience.Constants.EXPERIENCE_TYPE_VOICE, true)

local function notifyVoiceStatusChange(status: VoiceStatus, detail: string?)
	cevEventManager:notify(CrossExperience.Constants.EVENTS.PARTY_VOICE_STATUS_CHANGED, {
		status = status,
		detail = detail,
	})
end

local store = Rodux.Store.new(createReducers(), nil, {
	Rodux.thunkMiddleware,
	PersistenceMiddleware.getMiddleware(),
})

-- For debugging purposes can pass "log" as a second parameter
cevEventManager:subscribe(store)

-- Await completely the DM readiness for CrossExperience communication and RCC replication
if not game:IsLoaded() then
	game.Loaded:Wait()
end

notifyVoiceStatusChange(Constants.VOICE_STATUS.RCC_CONNECTED)

cevEventManager:notify(CrossExperience.Constants.EVENTS.PARTY_VOICE_EXPERIENCE_JOINED, {
	jobId = if game.JobId == "" or game.JobId == nil then HttpService:GenerateGUID(true) else game.JobId,
	placeId = game.PlaceId,
	gameId = game.GameId,
})

local localUserId = (Players.LocalPlayer and Players.LocalPlayer.UserId) or -1

observeCurrentContextId(function(currentContextId)
	PlayerAudioFocusChanged:FireServer(currentContextId)
end)

PlayerAudioFocusChanged.OnClientEvent:Connect(function(userId, currentContextId, currentContextIds)
	cevEventManager:notify(CrossExperience.Constants.EVENTS.PARTY_VOICE_PARTICIPANT_AUDIO_FOCUS_CHANGED, {
		userId = userId,
		contextId = currentContextId,
		contextIds = currentContextIds,
	})
end)

local onPlayerAdded = function(player)
	cevEventManager:notify(CrossExperience.Constants.EVENTS.PARTY_VOICE_PARTICIPANT_ADDED, {
		userId = player.UserId,
		isLocalUser = player.UserId == localUserId,
		username = player.Name,
		displayname = player.DisplayName,
	})
end

local onPlayerRemoved = function(player)
	cevEventManager:notify(CrossExperience.Constants.EVENTS.PARTY_VOICE_PARTICIPANT_REMOVED, {
		userId = player.UserId,
		isLocalUser = player.UserId == localUserId,
	})
	PartyAudioPlayer:playSound("leave")
end

local onLocalPlayerActiveChanged = function(result)
	local eventName = if result.isActive
		then CrossExperience.Constants.EVENTS.PARTY_VOICE_PARTICIPANT_IS_ACTIVE
		else CrossExperience.Constants.EVENTS.PARTY_VOICE_PARTICIPANT_IS_INACTIVE
	cevEventManager:notify(eventName, {
		userId = localUserId,
		isLocalUser = true,
	})
end

local onLocalPlayerMuteChanged = function(isMuted)
	coreVoiceManagerState.previousMutedState = isMuted
	local eventName = if isMuted
		then CrossExperience.Constants.EVENTS.PARTY_VOICE_PARTICIPANT_WAS_MUTED
		else CrossExperience.Constants.EVENTS.PARTY_VOICE_PARTICIPANT_WAS_UNMUTED

	if FFlagPartyVoiceExecuteVoiceActionsPostAsyncInit then
		executePostVoiceAsyncInit(function()
			cevEventManager:notify(eventName, {
				userId = localUserId,
				isLocalUser = true,
			})	
		end)
	else
		cevEventManager:notify(eventName, {
			userId = localUserId,
			isLocalUser = true,
		})
	end
end

local onParticipantsUpdated = function(participants)
	for userId, participantState in pairs(participants) do
		local isActive = participantState.isSignalActive
		local isMuted = participantState.isMuted

		local activeEventName = if isActive
			then CrossExperience.Constants.EVENTS.PARTY_VOICE_PARTICIPANT_IS_ACTIVE
			else CrossExperience.Constants.EVENTS.PARTY_VOICE_PARTICIPANT_IS_INACTIVE
		local mutedEventName = if isMuted
			then CrossExperience.Constants.EVENTS.PARTY_VOICE_PARTICIPANT_WAS_MUTED
			else CrossExperience.Constants.EVENTS.PARTY_VOICE_PARTICIPANT_WAS_UNMUTED

		local eventPayload = {
			userId = userId,
			isLocalUser = userId == localUserId,
		}

		cevEventManager:notify(mutedEventName, eventPayload)
		cevEventManager:notify(activeEventName, eventPayload)
	end
end

local toggleMutePlayer = function(params)
	local userId = tonumber(params.userId)
	local isLocalPlayer = localUserId == userId

	if FFlagPartyVoiceExecuteVoiceActionsPostAsyncInit then
		executePostVoiceAsyncInit(function()
			if isLocalPlayer then
				CoreVoiceManager:ToggleMic("Squads")
			else
				CoreVoiceManager:ToggleMutePlayer(userId)
			end
		end)
	else
		if isLocalPlayer then
			CoreVoiceManager:ToggleMic("Squads")
		else
			CoreVoiceManager:ToggleMutePlayer(userId)
		end
	end
end

function handleParticipants()
	Players.PlayerAdded:Connect(function(player)
		onPlayerAdded(player)
		PartyAudioPlayer:playSound("join")
	end)
	Players.PlayerRemoving:Connect(onPlayerRemoved)

	for _, player in pairs(Players:GetPlayers()) do
		if player:IsA("Player") then
			onPlayerAdded(player)
			if player.UserId == localUserId then
				PartyAudioPlayer:playSound("join")
			end
		end
	end
end

function handleMicrophone()
	CoreVoiceManager.muteChanged.Event:Connect(onLocalPlayerMuteChanged)
	cevEventManager:addObserver(CrossExperience.Constants.EVENTS.MUTE_PARTY_VOICE_PARTICIPANT, toggleMutePlayer)
	cevEventManager:addObserver(CrossExperience.Constants.EVENTS.UNMUTE_PARTY_VOICE_PARTICIPANT, toggleMutePlayer)
end

local handleBlockedParticipant = function(params: { userId: number })
	local numberUserId = tonumber(params.userId) or 0
	local player = Players:GetPlayerByUserId(numberUserId)
	if player then
		coroutine.wrap(function()
			local success = BlockingUtility:AddPlayerToBlockList(player)
			if success then
				log:info("Participant {} was blocked from party voice", player.DisplayName)
			end
		end)()
	end
end

local handleUnblockedParticipant = function(params: { userId: number })
	local numberUserId = tonumber(params.userId) or 0
	local player = Players:GetPlayerByUserId(numberUserId)
	if player then
		coroutine.wrap(function()
			local success = BlockingUtility:RemovePlayerFromBlockList(player)
			if success then
				log:info("Participant {} was unblocked from party voice", player.DisplayName)
			end
		end)()
	end
end

local isCapturingVideo = function()
	return GetFFlagEnableCrossExperienceVoiceCaptureMute() and CaptureService and CaptureService:IsCapturingVideo()
end

type PermissionResult = {
	hasMicPermissions: boolean,
}

local function isAuthorizedPermission(results, permission): boolean
	if results.missingPermissions then
		return not Cryo.List.find(results.missingPermissions, permission)
	end
	return false
end

local function requestPermissions(permissions): Promise<PermissionResult>
	local result: PermissionResult = {
		hasMicPermissions = false,
	}

	return Promise.new(function(resolve, reject)
		PermissionsProtocol:requestPermissions(permissions)
			:andThen(function(results)
				result.hasMicPermissions =
					isAuthorizedPermission(results, PermissionsProtocol.Permissions.MICROPHONE_ACCESS)
				resolve(result)
			end)
			:catch(function()
				resolve(result)
			end)
	end)
end

local function initializeParticipantBlockListener()
	cevEventManager:addObserver(
		CrossExperience.Constants.EVENTS.PARTY_VOICE_BLOCK_PARTICIPANT,
		handleBlockedParticipant
	)
	cevEventManager:addObserver(
		CrossExperience.Constants.EVENTS.PARTY_VOICE_UNBLOCK_PARTICIPANT,
		handleUnblockedParticipant
	)
end

function onCoreVoiceManagerInitialized()
	CoreVoiceManager:getService().PlayerMicActivitySignalChange:Connect(onLocalPlayerActiveChanged)
	CoreVoiceManager.participantsUpdate.Event:Connect(onParticipantsUpdated)
end

-- This function is used to unmute the microphone once when the player joins the default channel
-- and has set the default mute state which is captured in localMuted of CoreVoiceManager after
-- SetupParticipantListeners() is called in CoreVoiceManager:asyncInit()
-- TODO: JoinByGroupIdToken should respect defaultMuted boolean.
-- This is a temporary solution to unmute the microphone once when the player joins the default channel
local function unmuteMicrophoneOnce()
	CoreVoiceManager.muteChanged.Event:Once(function(muted)
		if muted ~= nil then
			if FFlagPartyVoiceExecuteVoiceActionsPostAsyncInit then
				executePostVoiceAsyncInit(function()
					CoreVoiceManager:ToggleMic("BackgroundDM")
				end)
			else
				CoreVoiceManager:ToggleMic("BackgroundDM")
			end
		end
	end)
end

local function initializeDefaultChannel(defaultMuted)
	local VoiceChatInternal = CoreVoiceManager:getService()

	if not VoiceChatInternal then
		return nil
	end

	log:info("Joining default channel")

	local success = VoiceChatInternal:JoinByGroupIdToken("default", defaultMuted)

	if GetFFlagEnableLuaVoiceChatAnalytics() then
		if success then
			Analytics:reportVoiceChatJoinResult(true, "defaultJoinSuccess")
		else
			Analytics:reportVoiceChatJoinResult(false, "defaultJoinFailed", "error")
		end
	end

	return success
end

local function validateSetup()
	if NotificationServiceIsConnectedAvailable and FFlagUseNotificationServiceIsConnected then
		if not NotificationService.IsConnected then
			log:debug("NotificationService is not yet connected")
			NotificationService:GetPropertyChangedSignal("IsConnected"):Wait()
		end
		log:debug("NotificationService connected")
	end

	if not FFlagDefaultChannelDontWaitOnCharacterWithAudioApi or not VoiceChatService.UseNewAudioApi then
		if not Players.LocalPlayer.Character then
			Players.LocalPlayer.CharacterAdded:Wait()
			log:debug("Player character loaded")
		else
			log:debug("Player character already loaded")
		end
	end

	if EnableDefaultVoiceAvailable and FFlagDefaultChannelEnableDefaultVoice then
		local VoiceChatService = game:FindService("VoiceChatService")
		if FFlagAlwaysJoinWhenUsingAudioAPI then
			if not VoiceChatService then
				log:info("VoiceChatService not found. Assuming default values.")
				-- We only don't want to early out when the new audio API is enabled
			elseif not VoiceChatService.EnableDefaultVoice and not VoiceChatService.UseNewAudioApi then
				log:debug("Default channel is disabled.")
				if GetFFlagEnableLuaVoiceChatAnalytics() then
					Analytics:reportVoiceChatJoinResult(false, "defaultDisabled")
					notifyVoiceStatusChange(Constants.VOICE_STATUS.ERROR_VOICE_SETUP, "Default channel disabled")
				end
				return false
			end
		else
			if not VoiceChatService then
				log:info("VoiceChatService not found. Assuming default values.")
			elseif not VoiceChatService.EnableDefaultVoice then
				log:debug("Default channel is disabled.")
				if GetFFlagEnableLuaVoiceChatAnalytics() then
					Analytics:reportVoiceChatJoinResult(false, "defaultDisabled")
					notifyVoiceStatusChange(Constants.VOICE_STATUS.ERROR_VOICE_SETUP, "Default channel disabled")
				end
				return false
			end
		end
	end
	return true
end

local function getPlayerUsersIds()
	local playerUserIds = {}
	for _, player in ipairs(Players:GetPlayers()) do
		table.insert(playerUserIds, player.UserId)
	end
	return table.concat(playerUserIds, ", ")
end

local function getPermissions(permissions): Promise<PermissionResult>
	local result: PermissionResult = {
		hasMicPermissions = false,
	}

	return Promise.new(function(resolve, reject)
		PermissionsProtocol:hasPermissions(permissions)
			:andThen(function(results)
				result.hasMicPermissions =
					isAuthorizedPermission(results, PermissionsProtocol.Permissions.MICROPHONE_ACCESS)
				if not result.hasMicPermissions then
					requestPermissions(permissions):andThen(resolve)
				else
					resolve(result)
				end
			end)
			:catch(function()
				resolve(result)
			end)
	end)
end

local function setupListeners()
	CoreVoiceManager:subscribe("GetPermissions", function(callback, permissions)
		if FFlagFixPartyVoiceGetPermissions then
			getPermissions(permissions):andThen(callback)
		else
			-- At this point we assume that you were able to join Background DM and the required permissions were resolved prior to that
			callback({
				hasMicPermissions = true,
			})
		end
	end)

	-- setup listeners
	handleParticipants()
	handleMicrophone()
	if FFlagPartyVoiceBlockSync then
		initializeParticipantBlockListener()
	end

	if GetFFlagEnableCrossExperienceVoiceCaptureMute() then
		cevEventManager:addObserver(CrossExperience.Constants.EVENTS.PARTY_VOICE_MUTE_ALL, function(params)
			executePostVoiceAsyncInit(function()
				CoreVoiceManager:MuteAll(true, params.context)
			end)
		end)
		cevEventManager:addObserver(CrossExperience.Constants.EVENTS.PARTY_VOICE_UNMUTE_ALL, function(params)
			executePostVoiceAsyncInit(function()
				CoreVoiceManager:MuteAll(false, params.context)
			end)
		end)
	end

	-- unmute mic at the start once muted state is initialized
	unmuteMicrophoneOnce()

	if FFlagEnableCrossExpVoiceDebug then
		cevEventManager:addObserver(CrossExperience.Constants.EVENTS.DEBUG_COMMAND, function(params)
			if params.name == "dump_session" then
				print("----------- CEV BACKGROUND -----------")
				print("Store State", HttpService:JSONEncode(store:getState()))
				print("--------------------------------------")
				print("CoreVoiceManager State:")
				print("Participants", HttpService:JSONEncode(CoreVoiceManager.participants))
				print("Local Muted", HttpService:JSONEncode({ value = CoreVoiceManager.localMuted }))
				print("Mute All", HttpService:JSONEncode({ value = CoreVoiceManager.muteAll }))
				print("Muted Anyone", HttpService:JSONEncode({ value = CoreVoiceManager._mutedAnyone }))
				print("Is Talking", HttpService:JSONEncode({ value = CoreVoiceManager.isTalking }))
				print("Muted Players", HttpService:JSONEncode(CoreVoiceManager.mutedPlayers))
				for device in CoreVoiceManager.audioDevices do
					if device.Player then
						print(
							"Audio Device ",
							device.Player.UserId,
							" Active:",
							device.Active,
							" MutedByLocalPlayer:",
							device.MutedByLocalUser
						)
					end
				end
				print("Voice Enabled", HttpService:JSONEncode({ value = CoreVoiceManager.voiceEnabled }))
				print("Permissions Result", HttpService:JSONEncode(CoreVoiceManager.communicationPermissionsResult))
				print("Voice Join Progress", HttpService:JSONEncode({ value = CoreVoiceManager.VoiceJoinProgress }))
				print("-----------------------------")
			end
		end)
	end

	CoreVoiceManager:subscribe("OnRequestMicPermissionRejected", function()
		notifyVoiceStatusChange(Constants.VOICE_STATUS.ERROR_VOICE_MIC_REJECTED)
	end)

	CoreVoiceManager:subscribe("OnPlayerModerated", function()
		notifyVoiceStatusChange(Constants.VOICE_STATUS.ERROR_VOICE_MODERATED, "On Player Moderated")
	end)

	CoreVoiceManager:subscribe("OnInitialJoinFailed", function()
		notifyVoiceStatusChange(Constants.VOICE_STATUS.ERROR_VOICE_JOIN, "Initial Join failed")
	end)

	CoreVoiceManager:subscribe("OnRetryRequested", function()
		if FFlagLogPartyVoiceReconnect then
			notifyVoiceStatusChange(Constants.VOICE_STATUS.VOICE_RECONNECTING, "Retry requested")
		else
			notifyVoiceStatusChange(Constants.VOICE_STATUS.VOICE_CONNECTING, "Retry requested")
		end
	end)

	CoreVoiceManager:subscribe("OnStateChanged", function(oldState, newState)
		if newState == Enum.VoiceChatState.Joined then
			local voiceChannelId = CoreVoiceManager:GetChannelId()
			local voiceSessionId = CoreVoiceManager:GetSessionId()

			-- get list of participant userids on time of join
			local playerUserIds = getPlayerUsersIds()
			cevEventManager:notify(CrossExperience.Constants.EVENTS.PARTY_VOICE_STATUS_CHANGED, {
				userId = localUserId,
				status = Constants.VOICE_STATUS.VOICE_CONNECTED,
				voiceChannelId = voiceChannelId,
				voiceSessionId = voiceSessionId,
				voicePlaySessionId = AnalyticsService:GetPlaySessionId(),
				participants = playerUserIds,
				numberActive = #Players:GetPlayers(),
			})
			coreVoiceManagerState.previousGroupId = CoreVoiceManager.service:GetGroupId()
		elseif newState == Enum.VoiceChatState.Failed then
			notifyVoiceStatusChange(Constants.VOICE_STATUS.ERROR_VOICE_FAILED)
		elseif newState == Enum.VoiceChatState.Ended then
			-- Considering catching this state as an error state even though leaving voice only would trigger this as well.
			-- Reason being is that currently leaving voice by user interaction is done by leaving RCC/destroying DM, which shutdowns scripts.
			-- So if we actually capture the end state it means the DM/RCC is still active and voice is not. Most likely voice inactivity
			-- timeout but currently there is no value to check to ensure that's what happened.
			notifyVoiceStatusChange(Constants.VOICE_STATUS.ERROR_VOICE_DISCONNECTED)
		end
	end)

	CoreVoiceManager:subscribe("OnReportJoinFailed", function(result)
		log:error("CEV OnReportJoinFailed " .. result)

		if FFlagPartyVoiceReportJoinFailed then
			notifyVoiceStatusChange(Constants.VOICE_STATUS.ERROR_VOICE_JOIN, result)
		end
	end)
end

function initializeAFM()
	if AudioFocusManagementEnabled then
		local success, AudioFocusService = pcall(function()
			return game:GetService("AudioFocusService")
		end)
		if success and AudioFocusService then
			local contextId = CrossExperience.Constants.AUDIO_FOCUS_MANAGEMENT.CEV.CONTEXT_ID
			local focusPriority = CrossExperience.Constants.AUDIO_FOCUS_MANAGEMENT.CEV.FOCUS_PRIORITY
			AudioFocusService:RegisterContextIdFromLua(contextId)

			local deafenAll = function()
				if not isCapturingVideo then
					CoreVoiceManager:MuteAll(true, "AudioFocusManagement CEV")
				end
	
				if not CoreVoiceManager.localMuted then
					CoreVoiceManager:ToggleMic()
				end
			end

			local undeafenAll = function()
				if not isCapturingVideo then
					CoreVoiceManager:MuteAll(false, "AudioFocusManagement CEV")
				end
				
				if CoreVoiceManager.localMuted then
					CoreVoiceManager:ToggleMic()
				end
			end

			AudioFocusService.OnDeafenVoiceAudio:Connect(function(serviceContextId)
				if serviceContextId == contextId then
					log:info("CEV OnDeafenVoiceAudio fired" .. serviceContextId)
					deafenAll()
				end
			end)

			AudioFocusService.OnUndeafenVoiceAudio:Connect(function(serviceContextId)
				if serviceContextId == contextId then
					log:info("CEV OnUndeafenVoiceAudio fired" .. serviceContextId)
					undeafenAll()
				end
			end)

			local requestAudioFocusWithPromise = function(id, prio)
				return Promise.new(function(resolve, reject)
					local requestSuccess, focusGranted =
						pcall(AudioFocusService.RequestFocus, AudioFocusService, id, prio)
					if requestSuccess then
						resolve(focusGranted) -- Still resolve, but indicate failure to grant focus
					else
						reject("Failed to call RequestFocus due to an error") -- Reject the promise in case of an error
					end
				end)
			end

			requestAudioFocusWithPromise(contextId, focusPriority)
				:andThen(function(focusGranted)
					if focusGranted then
						log:info("CEV audio focus request granted, preparing to undeafen.")
						CoreVoiceManager.muteChanged.Event:Once(function(muted)
							if muted ~= nil and not isCapturingVideo then
								CoreVoiceManager:MuteAll(false, "AudioFocusManagement CEV")
							end
						end)
					else
						log:info("CEV audio focus request denied, preparing to deafen.")
						CoreVoiceManager.muteChanged.Event:Once(function(muted)
							if muted ~= nil and not isCapturingVideo then
								CoreVoiceManager:MuteAll(true, "AudioFocusManagement CEV")
							end
						end)
					end
				end)
				:catch(function()
					log:info("[CEV] Error requesting focus inside CEV")
				end)
		else
			log:info("AudioFocusService did not initialize")
		end
	end
end

function initializeVoice()
	notifyVoiceStatusChange(Constants.VOICE_STATUS.VOICE_CONNECTING)
	CoreVoiceManager:asyncInit()
		:andThen(function()
			local joinInProgress = initializeDefaultChannel(false)
			if joinInProgress == false then
				notifyVoiceStatusChange(Constants.VOICE_STATUS.ERROR_VOICE_JOIN, "Initial Join failed")
			else
				onCoreVoiceManagerInitialized()
			end
			initializeAFM()
		end)
		:catch(function(err)
			-- If voice chat doesn't initialize, silently halt rather than throwing
			-- a unresolved promise error. Don't report an event since the manager
			-- will handle that.
			log:info("CoreVoiceManager did not initialize {}", err)
			if FFlagEnableCoreVoiceManagerPassErrorInReject then
				local detail = "INIT_ERROR_UNKNOWN"

				if FFlagPartyVoiceCatchError then
					if err then
						detail = err.code or err
					end
				else
					if err and err.code then
						detail = err.code
					end
				end

				notifyVoiceStatusChange(Constants.VOICE_STATUS.ERROR_VOICE_INIT, detail)
			else
				notifyVoiceStatusChange(Constants.VOICE_STATUS.ERROR_VOICE_INIT, err)
			end
		end)
end

function rejoinVoice()
	notifyVoiceStatusChange(Constants.VOICE_STATUS.VOICE_CONNECTING)
	if GetFFlagVoiceChatClientRewriteMasterLua() then
		CoreVoiceManager:RejoinVoice()
	else
		CoreVoiceManager:RejoinChannel(coreVoiceManagerState.previousGroupId, coreVoiceManagerState.previousMutedState)
	end
	coreVoiceManagerState = {
		previousGroupId = nil,
		previousMutedState = nil,
	}
end

function startVoice()
	if validateSetup() then
		setupListeners()
		initializeVoice()
	end
end

cevEventManager:addObserver(CrossExperience.Constants.EVENTS.PARTY_VOICE_RECONNECT_REQUESTED, function()
	local voiceStatus = store:getState().Squad.CrossExperienceVoice.Experience.voiceStatus
	if voiceStatus == VOICE_STATUS.ERROR_VOICE_SETUP then
		-- Voice have not managed to confirm basic assumptions, restart the process completely
		startVoice()
	elseif
		voiceStatus == VOICE_STATUS.ERROR_VOICE_INIT
		or (FFlagFixPartyVoiceGetPermissions and voiceStatus == VOICE_STATUS.ERROR_VOICE_MIC_REJECTED)
	then
		-- Voice has correctly set up but failed to succeed in asyncInit due to some generic issue so never connected. Attempt to reinitialize.
		initializeVoice()
	elseif
		voiceStatus == VOICE_STATUS.ERROR_VOICE_JOIN
		or (not FFlagFixPartyVoiceGetPermissions and voiceStatus == VOICE_STATUS.ERROR_VOICE_MIC_REJECTED)
		or voiceStatus == VOICE_STATUS.ERROR_VOICE_MODERATED
		or voiceStatus == VOICE_STATUS.ERROR_VOICE_FAILED
		or voiceStatus == VOICE_STATUS.ERROR_VOICE_DISCONNECTED
	then
		-- Voice has failed after a successful initialization
		rejoinVoice()
	end
end)

startVoice()
