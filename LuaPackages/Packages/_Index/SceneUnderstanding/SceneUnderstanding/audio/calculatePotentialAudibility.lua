local Root = script:FindFirstAncestor("SceneUnderstanding")

local UserGameSettings = UserSettings():GetService("UserGameSettings")

local safelyAccessProperty = require(Root.safelyAccessProperty)
local getConnectedWires = require(Root.audio.getConnectedWires)
local getOutputWires = require(Root.wiring.getOutputWires)
local wiringTypes = require(Root.wiring.types)
local toWirableInstance = require(Root.wiring.toWirableInstance)

local getFFlagNormalizeAudibilityForAudioSources = require(Root.flags.getFFlagNormalizeAudibilityForAudioSources)
local getFFlagSupportAudioChannelSplitters = require(Root.flags.getFFlagSupportAudioChannelSplitters)

type Wirable = wiringTypes.Wirable
type WirableInstance = wiringTypes.WirableInstance

local AUDIO_GRAPH_CLASSES = {
	"Wire",
	"AudioAnalyzer",
	"AudioChorus",
	"AudioCompressor",
	"AudioDeviceInput",
	"AudioDeviceOutput",
	"AudioDistortion",
	"AudioEcho",
	"AudioEmitter",
	"AudioEqualizer",
	"AudioFader",
	"AudioFilter",
	"AudioFlanger",
	"AudioLimiter",
	"AudioListener",
	"AudioPitchShifter",
	"AudioPlayer",
	"AudioReverb",
}

type AudioGraphNode =
	Wire
	| AudioAnalyzer
	| AudioChorus
	| AudioCompressor
	| AudioDeviceInput
	| AudioDeviceOutput
	| AudioDistortion
	| AudioEcho
	| AudioEmitter
	| AudioEqualizer
	| AudioFader
	| AudioFilter
	| AudioFlanger
	| AudioLimiter
	| AudioListener
	| AudioPitchShifter
	| AudioPlayer
	| AudioReverb

local function toAudioGraphNode(instance: Instance?): AudioGraphNode?
	if instance then
		for _, class in AUDIO_GRAPH_CLASSES do
			if instance:IsA(class) then
				return (instance :: any) :: AudioGraphNode
			end
		end
	end
	return nil
end

local function calculateSoundPotentialAudibility(sound: Sound)
	if not sound.IsPlaying then
		return 0
	end

	-- These properties are integral to determining audibility but are not
	-- accessible in lower security levels. To ensure we don't accidentally
	-- lie about how audible something is we simply zero them out
	local rollOffGain = safelyAccessProperty(sound, "RollOffGain", 0)

	local groupVolume = if sound.SoundGroup then sound.SoundGroup.Volume else 1

	-- This step normalizes the potential audibility of Sounds and the Audio
	-- API. `AudioListener:GetAudibilityFor` returns equivalent values to
	-- RollOffGain but is shifted by a factor of 10. So for example, a Sound
	-- returning 0.5 would map to an AudioListener returning 0.05.
	--
	-- Since Sound instances are the legacy system we choose to shift them to be
	-- in-line with the new Audio API.
	if getFFlagNormalizeAudibilityForAudioSources() and rollOffGain < 1 then
		rollOffGain /= 10
	end

	-- TODO MUS-1159: Add PlaybackLoudness as a factor for audibility. It looks
	-- to considerably increase accuracy
	return groupVolume * sound.Volume * rollOffGain
end

local getAudibilityOf
if getFFlagSupportAudioChannelSplitters() then
	local function getOutputsOf(node: WirableInstance): { WirableInstance }
		if typeof(node) == "Instance" then
			if node:IsA("AudioEmitter") then
				return node:GetInteractingListeners() :: any
			end
		end

		local outs: { WirableInstance } = {}

		for _, wire in getOutputWires(node :: Wirable) do
			local target = toWirableInstance(wire.TargetInstance)
			if target then
				table.insert(outs, target)
			end
		end

		return outs
	end

	local function getAudibilityMultiplierFor(emitter: AudioEmitter): number
		local total = 0
		for _, listener in emitter:GetInteractingListeners() do
			total += listener:GetAudibilityFor(emitter)
		end
		return total
	end

	function getAudibilityOf(node: WirableInstance, seen: { [WirableInstance]: boolean }?): number
		local seenHere = if seen then seen else {}
		if seenHere[node] then
			return 0
		end

		seenHere[node] = true
		local multiplier = 1
		if typeof(node) == "Instance" then
			if node:IsA("AudioPlayer") or node:IsA("AudioFader") then
				multiplier = node.Volume
			elseif node:IsA("AudioEmitter") then
				multiplier = getAudibilityMultiplierFor(node)
			elseif node:IsA("AudioDeviceOutput") then
				return 1
			end
		end

		local total = 0
		for _, output in getOutputsOf(node) do
			total += multiplier * getAudibilityOf(output, seenHere)
		end
		return total
	end
else
	local function getOutputsOf(node: AudioGraphNode): { AudioGraphNode }
		if node:IsA("AudioEmitter") then
			return node:GetInteractingListeners() :: any
		end

		local outs: { AudioGraphNode } = {}
		for _, wire in getConnectedWires(node, "Output") do
			local target = toAudioGraphNode(wire.TargetInstance)
			if target then
				table.insert(outs, target)
			end
		end
		return outs
	end

	local function getAudibilityMultiplierFor(emitter: AudioEmitter): number
		local total = 0
		for _, listener in emitter:GetInteractingListeners() do
			total += listener:GetAudibilityFor(emitter)
		end
		return total
	end

	function getAudibilityOf(node: AudioGraphNode, seen: { [AudioGraphNode]: boolean }?): number
		local seenHere = if seen then seen else {}
		if seenHere[node] then
			return 0
		end

		seenHere[node] = true
		local multiplier = 1
		if node:IsA("AudioPlayer") or node:IsA("AudioFader") then
			multiplier = node.Volume
		elseif node:IsA("AudioEmitter") then
			multiplier = getAudibilityMultiplierFor(node)
		elseif node:IsA("AudioDeviceOutput") then
			return 1
		end

		local total = 0
		for _, output in getOutputsOf(node) do
			total += multiplier * getAudibilityOf(output, seenHere)
		end
		return total
	end
end

--[=[
	Determines the potential audibility of an audio source relative to the
	client.

	This function makes use of internal APIs and will return 0 in the following
	cases:
	1. [UserGameSettings.MasterVolume] is inaccessible
	2. For [Sound] instances, [Sound.RollOffGain] is inaccessible.

	@within SceneUnderstanding
	@tag internal
]=]
local function calculatePotentialAudibility(audioSource: AudioPlayer | Sound): number
	local masterVolume = safelyAccessProperty(UserGameSettings, "MasterVolume", 0)
	local potentialAudibility = 0

	if audioSource:IsA("Sound") then
		potentialAudibility = calculateSoundPotentialAudibility(audioSource)
	else
		potentialAudibility = getAudibilityOf(audioSource)
	end

	return masterVolume * potentialAudibility
end

return calculatePotentialAudibility
