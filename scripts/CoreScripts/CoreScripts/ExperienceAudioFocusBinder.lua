local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local CorePackages = game:GetService("CorePackages")
local Promise = require(CorePackages.Packages.Promise)
local log = require(CorePackages.Workspace.Packages.CoreScriptsInitializer).CoreLogger:new(script.Name)
local GetFFlagFixSeamlessVoiceIntegrationWithPrivateVoice =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagFixSeamlessVoiceIntegrationWithPrivateVoice

local VoiceConstants = require(RobloxGui.Modules.VoiceChat.Constants)
local VoiceChatServiceManager = require(RobloxGui.Modules.VoiceChat.VoiceChatServiceManager).default
local CrossExperience = require(CorePackages.Workspace.Packages.CrossExperience)
local Constants = CrossExperience.Constants

local wasVoiceEverSuspended = false
local voiceChatState = nil
local muteWasHandled = false
local wasInitialFocusRequestHandled = false

if GetFFlagFixSeamlessVoiceIntegrationWithPrivateVoice() then
	VoiceChatServiceManager:subscribe("OnStateChanged", function(oldState, newState)
		voiceChatState = newState
		if newState == Enum.VoiceChatState.Ended then
			muteWasHandled = false
		end
	end)
	VoiceChatServiceManager.VoiceJoinProgressChanged.Event:Connect(function(state)
		if state == VoiceConstants.VOICE_JOIN_PROGRESS.Suspended then
			wasVoiceEverSuspended = true
		end
	end)

	function performVoiceOperationWhenReady(callback)
		VoiceChatServiceManager:asyncInit()
			:andThen(function()
				callback()
			end)
			:catch(function()
				log:info("VCSM was not initialized to perform operation [CEV ExperienceAudioFocusBinder]")
			end)
	end

	function isConnectedToPublicVoice()
		return not VoiceChatServiceManager:ShouldShowJoinVoice() or voiceChatState == (Enum :: any).VoiceChatState.Joined
	end

	function initializeAFM()
		local success, AudioFocusService = pcall(function()
			return game:GetService("AudioFocusService")
		end)
		if success and AudioFocusService then
			local contextId = Constants.AUDIO_FOCUS_MANAGEMENT.UGC.CONTEXT_ID
			local focusPriority = Constants.AUDIO_FOCUS_MANAGEMENT.UGC.FOCUS_PRIORITY
	
			AudioFocusService:RegisterContextIdFromLua(contextId)

			local deafenAll = function()
				if isConnectedToPublicVoice() then
					VoiceChatServiceManager:MuteAll(true, "AudioFocusManagement UGC")
					if not VoiceChatServiceManager.localMuted then
						VoiceChatServiceManager:ToggleMic()
					end
	
					-- Hide the in-exp voice UI when the user is deafened
					VoiceChatServiceManager:HideVoiceUI()
				end
			end
	
			local undeafenAll = function()
				if isConnectedToPublicVoice() then
					VoiceChatServiceManager:MuteAll(false, "AudioFocusManagement UGC")
					if not VoiceChatServiceManager.localMuted then
						VoiceChatServiceManager:ToggleMic()
					end
					
					-- Show the in-exp voice UI when the user is deafened
					VoiceChatServiceManager:ShowVoiceUI()
				end
			end

			AudioFocusService.OnDeafenVoiceAudio:Connect(function(serviceContextId)
				if serviceContextId == contextId then
					log:info("UGC OnDeafenVoiceAudio fired" .. serviceContextId)
					performVoiceOperationWhenReady(deafenAll)
				end
			end)
	
			AudioFocusService.OnUndeafenVoiceAudio:Connect(function(serviceContextId)
				if serviceContextId == contextId then
					log:info("UGC OnUndeafenVoiceAudio fired" .. serviceContextId)
					performVoiceOperationWhenReady(undeafenAll)
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

			local handleMuteChangedEvent = function(muted, shouldFocusPublicVoice)
				if muted ~= nil then
					if shouldFocusPublicVoice then
						log:info("UGC audio focus request granted, preparing to undeafen.")
						VoiceChatServiceManager:MuteAll(false, "AudioFocusManagement UGC")
						VoiceChatServiceManager:ShowVoiceUI()
					else
						log:info("UGC audio focus requested denied, preparing to deafen.")
						VoiceChatServiceManager:MuteAll(true, "AudioFocusManagement UGC")
						VoiceChatServiceManager:HideVoiceUI()
					end
				end
			end

			local onMuteChangedEvent = function(muted, shouldFocusPublicVoice)
				if not muteWasHandled then
					performVoiceOperationWhenReady(function()
						if not wasVoiceEverSuspended then
							handleMuteChangedEvent(muted, shouldFocusPublicVoice)
						end
					end)
					muteWasHandled = true
				end
			end

			requestAudioFocusWithPromise(contextId, focusPriority)
				:andThen(function(focusGranted)
					VoiceChatServiceManager.muteChanged.Event:Connect(function(muted)
						if not wasInitialFocusRequestHandled then
							onMuteChangedEvent(muted, focusGranted)
							wasInitialFocusRequestHandled = true
						else
							onMuteChangedEvent(muted, isConnectedToPublicVoice())
						end
					end)
				end)
				:catch(function()
					log:info("[UGC] Error requesting focus inside UGCdatamodel")
				end)
		end
	end

	local canUseService = VoiceChatServiceManager.canUseServiceResult
	if canUseService then
		initializeAFM()
	elseif canUseService == nil then
		VoiceChatServiceManager:subscribe("OnCanUseServiceResult", function(result)
			if result then
				initializeAFM()
			else
				log:info("VCSM cannot be used [CEV ExperienceAudioFocusBinder]")
			end
		end)
	else
		log:info("VCSM cannot be used [CEV ExperienceAudioFocusBinder]")
	end

else
	VoiceChatServiceManager:asyncInit()
		:andThen(function()
			local success, AudioFocusService = pcall(function()
				return game:GetService("AudioFocusService")
			end)
			if success and AudioFocusService then
				local contextId = Constants.AUDIO_FOCUS_MANAGEMENT.UGC.CONTEXT_ID
				local focusPriority = Constants.AUDIO_FOCUS_MANAGEMENT.UGC.FOCUS_PRIORITY

				AudioFocusService:RegisterContextIdFromLua(contextId)

				local deafenAll = function()
					VoiceChatServiceManager:MuteAll(true, "AudioFocusManagement UGC")
					if not VoiceChatServiceManager.localMuted then
						VoiceChatServiceManager:ToggleMic()
					end

					-- Hide the in-exp voice UI when the user is deafened
					VoiceChatServiceManager:HideVoiceUI()
				end

				local undeafenAll = function()
					VoiceChatServiceManager:MuteAll(false, "AudioFocusManagement UGC")
					if not VoiceChatServiceManager.localMuted then
						VoiceChatServiceManager:ToggleMic()
					end

					-- Show the in-exp voice UI when the user is deafened
					VoiceChatServiceManager:ShowVoiceUI()
				end

				AudioFocusService.OnDeafenVoiceAudio:Connect(function(serviceContextId)
					if serviceContextId == contextId then
						log:info("UGC OnDeafenVoiceAudio fired" .. serviceContextId)
						deafenAll()
					end
				end)

				AudioFocusService.OnUndeafenVoiceAudio:Connect(function(serviceContextId)
					if serviceContextId == contextId then
						log:info("UGC OnUndeafenVoiceAudio fired" .. serviceContextId)
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
							log:info("UGC audio focus request granted, preparing to undeafen.")
							VoiceChatServiceManager.muteChanged.Event:Once(function(muted)
								if muted ~= nil then
									VoiceChatServiceManager:MuteAll(false, "AudioFocusManagement UGC")
								end
							end)
							VoiceChatServiceManager:ShowVoiceUI()
						else
							log:info("UGC audio focus requested denied, preparing to deafen.")
							VoiceChatServiceManager.muteChanged.Event:Once(function(muted)
								if muted ~= nil then
									VoiceChatServiceManager:MuteAll(true, "AudioFocusManagement UGC")
								end
							end)
							VoiceChatServiceManager:HideVoiceUI()
						end
					end)
					:catch(function()
						log:info("[UGC] Error requesting focus inside UGCdatamodel")
					end)
			end
		end)
		:catch(function()
			log:info("VCSM was not initialized [CEV ExperienceAudioFocusBinder]")
		end)
end
