local Chrome = script:FindFirstAncestor("Chrome")

local CorePackages = game:GetService("CorePackages")

local SharedFlags = require(CorePackages.Workspace.Packages.SharedFlags)
local FFlagAdaptUnibarAndTiltSizing = SharedFlags.GetFFlagAdaptUnibarAndTiltSizing()

local React = require(CorePackages.Packages.React)
local UIBlox = require(CorePackages.Packages.UIBlox)
local useStyle = UIBlox.Core.Style.useStyle
local ChromeShared = Chrome.ChromeShared
local GetStyleTokens = if FFlagAdaptUnibarAndTiltSizing
	then require(ChromeShared.Utility.GetStyleTokens)
	else nil :: never

local chromeService = require(Chrome.Service)
local RedVoiceDot = require(Chrome.Integrations.RedVoiceDot)
local StyleTokens = if FFlagAdaptUnibarAndTiltSizing then GetStyleTokens() else nil :: never

local GetFFlagTweakedMicPinning = require(Chrome.Flags.GetFFlagTweakedMicPinning)

local burgerSpacing = 0.17
local TOGGLE_MENU_SIZE = if FFlagAdaptUnibarAndTiltSizing
	then UDim2.new(0, StyleTokens.Size.Size_900, 0, StyleTokens.Size.Size_900)
	else UDim2.new(0, 36, 0, 36)
local TOPLINE_SIZE = if FFlagAdaptUnibarAndTiltSizing
	then UDim2.new(0, StyleTokens.Size.Size_400, 0, StyleTokens.Size.Size_50)
	else UDim2.new(0, 16, 0, 2)
local CENTERLINE_SIZE = if FFlagAdaptUnibarAndTiltSizing
	then UDim2.new(0, StyleTokens.Size.Size_400, 0, StyleTokens.Size.Size_50)
	else UDim2.new(0, 16, 0, 2)
local BOTTOMLINE_SIZE = if FFlagAdaptUnibarAndTiltSizing
	then UDim2.new(0, StyleTokens.Size.Size_400, 0, StyleTokens.Size.Size_50)
	else UDim2.new(0, 16, 0, 2)
local RED_VOICE_DOT_POSITION = if FFlagAdaptUnibarAndTiltSizing
	then UDim2.new(1, StyleTokens.Config.UI.Scale * -7, 1, StyleTokens.Config.UI.Scale * -7)
	else UDim2.new(1, -7, 1, -7)

function ToggleMenuButton(props)
	local toggleIconTransition = props.toggleTransition
	local style = useStyle()

	local iconColor = style.Theme.IconEmphasis

	return React.createElement("Frame", {
		Size = TOGGLE_MENU_SIZE,
		BorderSizePixel = 0,
		BackgroundColor3 = style.Theme.BackgroundMuted.Color,
		BackgroundTransparency = style.Theme.BackgroundMuted.Transparency,
	}, {
		React.createElement("UICorner", {
			Name = "Corner",
			CornerRadius = UDim.new(1, 0),
		}) :: any,
		React.createElement("Frame", {
			Name = "TopLine",
			Position = toggleIconTransition:map(function(value): any
				return UDim2.new(0.5, 0, 0.5 - burgerSpacing * (1 - value), 0)
			end),
			AnchorPoint = Vector2.new(0.5, 0),
			Size = TOPLINE_SIZE,
			BorderSizePixel = 0,
			BackgroundColor3 = iconColor.Color,
			BackgroundTransparency = iconColor.Transparency,
			Rotation = toggleIconTransition:map(function(value): any
				return 45 * value
			end),
		}) :: any,
		React.createElement("Frame", {
			Name = "CenterLine",
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Size = CENTERLINE_SIZE,
			BorderSizePixel = 0,
			BackgroundColor3 = iconColor.Color,
			BackgroundTransparency = toggleIconTransition:map(function(value)
				return 1 - ((1 - iconColor.Transparency) * (1 - value))
			end),
		}) :: any,
		React.createElement("Frame", {
			Name = "BottomLine",
			Position = toggleIconTransition:map(function(value): any
				return UDim2.new(0.5, 0, 0.5 + burgerSpacing * (1 - value), 0)
			end),
			AnchorPoint = Vector2.new(0.5, 0),
			Size = BOTTOMLINE_SIZE,
			BorderSizePixel = 0,
			BackgroundColor3 = iconColor.Color,
			BackgroundTransparency = iconColor.Transparency,
			Rotation = toggleIconTransition:map(function(value)
				return -45 * value
			end),
		}) :: any,
		if GetFFlagTweakedMicPinning()
			then nil
			else React.createElement("Frame", {
					Name = "RedVoiceDotVisibleContiner",
					-- If MicToggle isn't always visible in Unibar we'll need to make this more advanced
					-- ie. a signal from ChromeService to say if MicToggle is visible
					Visible = toggleIconTransition:map(function(value): any
						return value < 0.5
					end),
					Size = UDim2.new(1, 0, 1, 0),
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
				}, {
					React.createElement(RedVoiceDot, {
						position = RED_VOICE_DOT_POSITION,
					}),
				}) :: any,
	})
end

return chromeService:register({
	id = "chrome_toggle",
	label = "CoreScripts.TopBar.MenuToggle",
	hideNotificationCountWhileOpen = true,
	activated = function() end,
	components = {
		Icon = function(props)
			return ToggleMenuButton(props)
		end,
	},
	notification = chromeService:totalNotifications(),
	initialAvailability = chromeService.AvailabilitySignal.Pinned,
})
