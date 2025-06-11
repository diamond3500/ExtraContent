local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

return React.createContext({
	isTitleVisible = false,
	titleHeight = 0,
	setTitleHeight = function(titleHeight: number) end,
	hasMediaBleed = false,
	setHasMediaBleed = function(hasMediaBleed: boolean) end,
})
