local Root = script:FindFirstAncestor("ChromeShared")

local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local GamepadConnector = require(Root.Parent.Parent.TopBar.Components.GamepadConnector)

local React = require(CorePackages.Packages.React)
local ReactRoblox = require(CorePackages.Packages.ReactRoblox)
local UIBlox = require(CorePackages.Packages.UIBlox)
local ShortcutBar = UIBlox.App.Navigation.ShortcutBar
local Types = require(Root.Service.Types)
local Constants = require(Root.Unibar.Constants)

local ChromeService = require(Root.Service)

local SharedFlags = require(CorePackages.Workspace.Packages.SharedFlags)
local FFlagChromeUnbindShortcutBarOnHide = SharedFlags.FFlagChromeUnbindShortcutBarOnHide

function ChromeShortcutBar(props)
	local shortcuts, setShortcuts = React.useState({})
	local showShortcutBar, setShowShortcutBar = React.useBinding(false)

	React.useEffect(function()
		ChromeService:onShortcutBarChanged():connect(function()
			local s = ChromeService:getCurrentShortcuts()
			setShortcuts(s)
		end)

		local showTopBar = GamepadConnector:getShowTopBar()
		local gamepadActive = GamepadConnector:getGamepadActive()

		if FFlagChromeUnbindShortcutBarOnHide then
			local function shouldHideShortcutBar()
				local shouldHide = not showTopBar:get() or not gamepadActive:get()
				ChromeService:setHideShortcutBar("TopBar", shouldHide)
			end

			showTopBar:connect(shouldHideShortcutBar)
			gamepadActive:connect(shouldHideShortcutBar)
		else
			local function shouldShowShortcutBar()
				local shouldShow = showTopBar:get() and gamepadActive:get()
				setShowShortcutBar(shouldShow)
			end

			showTopBar:connect(shouldShowShortcutBar)
			gamepadActive:connect(shouldShowShortcutBar)
		end
	end, {})

	local shortcutItems = {}
	for k, s in shortcuts do
		local shortcut = s :: Types.ShortcutProps
		if not shortcut.label then
			continue
		end
		local item = { icon = "", text = "" }
		if shortcut.icon then
			item.icon = shortcut.icon
		end
		item.text = shortcut.label

		table.insert(shortcutItems, item)
	end

	return ReactRoblox.createPortal({
		Name = React.createElement("ScreenGui", {
			Name = "ShortcutBar",
			DisplayOrder = Constants.SHORTCUTBAR_DISPLAYORDER,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			Enabled = if FFlagChromeUnbindShortcutBarOnHide then nil else showShortcutBar,
		}, {
			React.createElement(ShortcutBar, {
				position = UDim2.fromScale(0.5, 0.9),
				anchorPoint = Vector2.new(0.5, 0),
				-- ShortcutBar will not render if there are no items
				items = shortcutItems,
			}),
		}),
	}, CoreGui :: Instance)
end

return ChromeShortcutBar
