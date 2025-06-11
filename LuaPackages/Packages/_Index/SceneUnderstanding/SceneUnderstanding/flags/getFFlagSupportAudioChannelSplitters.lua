local Root = script:FindFirstAncestor("SceneUnderstanding")

local SafeFlags = require(Root.Parent.SafeFlags)

return SafeFlags.createGetFFlag("SupportAudioChannelSplitters")
