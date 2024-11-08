local Root = script:FindFirstAncestor("ReactSceneUnderstanding")

local SafeFlags = require(Root.Parent.SafeFlags)

return SafeFlags.createGetFString("SceneAnalysisProcessingMode", "AudioInstances")
