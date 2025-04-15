local Root = script:FindFirstAncestor("ReactSceneUnderstanding")

local SoundService = game:GetService("SoundService")

local Cryo = require(Root.Parent.Cryo)
local React = require(Root.Parent.React)
local ReactUtils = require(Root.Parent.ReactUtils)
local useTimedLoop = require(Root.useTimedLoop)

local getFFlagFixAudibleSoundDetectionPerformance = require(Root.flags.getFFlagFixAudibleSoundDetectionPerformance)

local useCallback = React.useCallback
local useEffect = React.useEffect
local useState = React.useState
local useEventConnection = ReactUtils.useEventConnection

local AUTO_REFRESH_SECONDS = 1

local function getAllAudioSources(): { AudioPlayer | Sound }
	-- This method was introduced in 645, and lua-apps currently runs tests
	-- against 641+. To allow tests to pass we need to ensure this method is
	-- guarded so attempts to use it on older versions will not cause an error.
	--
	-- This pcall can be be removed once the oldest version lua-apps runs
	-- against is 645,
	local success, results = pcall(function()
		return SoundService:GetAudioInstances()
	end)

	if success then
		return Cryo.List.filter(results, function(instance: Instance)
			return instance:IsA("Sound") or instance:IsA("AudioPlayer")
		end)
	else
		return {}
	end
end

local function useAudioSources(): { AudioPlayer | Sound }
	local audioSources, setAudioSources = useState(getAllAudioSources)

	if getFFlagFixAudibleSoundDetectionPerformance() then
		useTimedLoop(AUTO_REFRESH_SECONDS, function()
			setAudioSources(getAllAudioSources())
		end)
	else
		local onAncestryChanged = useCallback(function(instance: Instance)
			if not instance:IsDescendantOf(game) then
				setAudioSources(function(prev)
					return Cryo.List.filter(prev, function(other)
						return instance ~= other
					end)
				end)
			end
		end, {})

		useEventConnection(SoundService.AudioInstanceAdded, function(instance)
			if instance:IsA("Sound") or instance:IsA("AudioPlayer") then
				setAudioSources(function(prev)
					return Cryo.List.join(prev, { instance })
				end)
			end
		end, {})

		useEffect(function()
			local connections: { RBXScriptConnection } = {}

			for _, audioSource in audioSources do
				table.insert(connections, audioSource.AncestryChanged:Connect(onAncestryChanged))
			end

			return function()
				for _, connection in connections do
					connection:Disconnect()
				end
			end
		end, { audioSources })
	end

	return audioSources
end

return useAudioSources
