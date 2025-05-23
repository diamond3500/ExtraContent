local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PlayerGui = if Players.LocalPlayer and RunService:IsRunning()
	then Players.LocalPlayer:WaitForChild("PlayerGui", 3)
	else nil

local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local isCoreGui = require(Foundation.Utility.isCoreGui)
local Flags = require(Foundation.Utility.Flags)
local useStyleSheet = require(Foundation.Providers.Style.StyleSheetContext).useStyleSheet

local OverlayContext = require(script.Parent.OverlayContext)

local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)

type Props = {
	gui: GuiObject?,
	sheetRef: React.Ref<StyleSheet>?,
	children: React.ReactNode,
}

local mainGui = if isCoreGui then CoreGui else PlayerGui

local function OverlayProvider(props: Props)
	local overlay: GuiObject?, setOverlay = React.useState(props.gui)
	local styleSheet
	if Flags.FoundationStyleSheetContext then
		styleSheet = useStyleSheet()
	end

	local overlayRefCallback = React.useCallback(function(screenGui: GuiObject)
		setOverlay(screenGui)
	end, {})

	React.useEffect(function()
		if props.gui ~= nil then
			setOverlay(props.gui)
		end
	end, { props.gui })

	return React.createElement(OverlayContext.Provider, {
		value = {
			overlay = overlay,
		},
	}, {
		FoundationOverlay = if not props.gui and mainGui
			then ReactRoblox.createPortal(
				React.createElement("ScreenGui", {
					Enabled = true,
					DisplayOrder = math.huge,
					ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
					ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
					ref = overlayRefCallback,
				}, {
					FoundationStyleLink = if not Flags.FoundationStylingPolyfill
						then React.createElement("StyleLink", {
							StyleSheet = if Flags.FoundationStyleSheetContext
								then styleSheet
								else if type(props.sheetRef) == "table" then props.sheetRef.current else nil,
						})
						else nil,
				}),
				mainGui
			)
			else nil,
		Children = React.createElement(React.Fragment, nil, props.children),
	})
end

return OverlayProvider
