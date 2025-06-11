local FFlagEnableNewBlockingModal = require(script.Parent.FFlagEnableNewBlockingModal)
local FFlagNavigateToBlockingModal = require(script.Parent.FFlagNavigateToBlockingModal)

return FFlagEnableNewBlockingModal and FFlagNavigateToBlockingModal and game:DefineFastFlag("EnableNewBlockingModalDevApiPrompt", false)
