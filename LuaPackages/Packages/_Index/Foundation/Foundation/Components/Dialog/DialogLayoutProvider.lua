local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local withDefaults = require(Foundation.Utility.withDefaults)
local DialogLayoutContext = require(script.Parent.DialogLayoutContext)

export type DialogLayoutProps = {
	isTitleVisible: boolean?,
	titleHeight: number?,
	hasMediaBleed: boolean?,
	children: React.ReactNode,
}

local defaultProps = {
	isTitleVisible = false,
	titleHeight = 0,
	hasMediaBleed = false,
}

local function DialogLayoutProvider(layoutProps: DialogLayoutProps)
	local props = withDefaults(layoutProps, defaultProps)
	local titleHeight, setTitleHeight = React.useState(props.titleHeight)
	local hasMediaBleed, setHasMediaBleed = React.useState(props.hasMediaBleed)

	return React.createElement(DialogLayoutContext.Provider, {
		value = {
			isTitleVisible = props.isTitleVisible,
			titleHeight = titleHeight,
			setTitleHeight = setTitleHeight,
			hasMediaBleed = hasMediaBleed,
			setHasMediaBleed = setHasMediaBleed,
		},
	}, props.children)
end

return DialogLayoutProvider
