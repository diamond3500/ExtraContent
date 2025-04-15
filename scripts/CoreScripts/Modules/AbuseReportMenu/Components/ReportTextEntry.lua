local CorePackages = game:GetService("CorePackages")
local React = require(CorePackages.Packages.React)
local UIBlox = require(CorePackages.Packages.UIBlox)
local useStyle = UIBlox.Core.Style.useStyle

local FFlagReportTextEntryBackgroundColor = game:DefineFastFlag("ReportTextEntryBackgroundColor", false)

type Props = { text: string, placeholderText: string, onUpdate: (newValue: string) -> () }

local TEXT_ENTRY_HEIGHT = 40

local function ReportTextEntry(props: Props)
	local style = useStyle()
	local font = style.Font.Body.Font
	local textSize = style.Tokens.Global.FontSize_100
	local theme = style.Theme

	return React.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, TEXT_ENTRY_HEIGHT + style.Tokens.Global.Space_300 + 20),
		BackgroundTransparency = style.Theme.BackgroundDefault.Transparency,
		BackgroundColor3 = if FFlagReportTextEntryBackgroundColor
			then style.Theme.BackgroundUIDefault.Color
			else style.Theme.BackgroundDefault.Color,
		AutomaticSize = Enum.AutomaticSize.Y,
	}, {
		UIPadding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
		}),
		UICorner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		AbuseReportsText = React.createElement("TextBox", {
			Size = UDim2.new(1, 0, 0, TEXT_ENTRY_HEIGHT + style.Tokens.Global.Space_300),
			AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.new(0, 0, 0, 0),
			AnchorPoint = Vector2.new(0, 0),
			BackgroundColor3 = if FFlagReportTextEntryBackgroundColor
				then theme.BackgroundUIDefault.Color
				else theme.BackgroundDefault.Color,
			PlaceholderText = props.placeholderText,
			Font = font,
			Text = props.text,
			TextSize = textSize,
			TextColor3 = theme.TextDefault.Color,
			TextTransparency = theme.TextDefault.Transparency,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			BackgroundTransparency = theme.BackgroundDefault.Transparency,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			RichText = false,
			MultiLine = true,
			TextWrapped = true,
			ClearTextOnFocus = false,
			OverlayNativeInput = true,
			[React.Event.FocusLost] = function() end,
			[React.Event.Focused] = function() end,
			[React.Change.AbsoluteSize] = function() end,
			[React.Change.Text] = function(rbx: any)
				if props.text ~= rbx.Text then
					props.onUpdate(rbx.Text)
				end
			end,
		}),
	})
end

return ReportTextEntry
