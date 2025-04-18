--[[
	A text input field used in the prompts that allows the user to enter a creation's name.
	Validates the text input as the user types, and displays "Invalid Name" below if invalid.
	Currently, invalid names include names that only consist of spaces.
]]
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Packages.Roact)
local t = require(CorePackages.Packages.t)
local RoactGamepad = require(CorePackages.Packages.RoactGamepad)
local RobloxTranslator = require(CorePackages.Workspace.Packages.RobloxTranslator)

local Focusable = RoactGamepad.Focusable

local UIBlox = require(CorePackages.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local withSelectionCursorProvider = UIBlox.App.SelectionImage.withSelectionCursorProvider
local CursorKind = UIBlox.App.SelectionImage.CursorKind

local TEXTBOX_PADDING = 6

local DEFAULT_MAX_NAME_LENGTH = 50 -- Source of truth is AssetConfigConstants in game-engine
local WARNING_TEXT_SIZE = 12

local NameTextBox = Roact.PureComponent:extend("NameTextBox")
local FFlagRemoveNameRegex = game:DefineFastFlag("RemoveNameRegex", false)

NameTextBox.validateProps = t.strictInterface({
	Size = t.optional(t.UDim2),
	Position = t.optional(t.UDim2),
	centerText = t.optional(t.boolean),
	maxLength = t.optional(t.number),
	onNameUpdated = t.callback, -- function(newName, isNameValid)
	LayoutOrder = t.optional(t.number),
	nameTextBoxRef = t.optional(t.table),
	NextSelectionDown = t.optional(t.table),
	defaultName = t.optional(t.string),
	invalidInputText = t.optional(t.string),
})

NameTextBox.defaultProps = {
	maxLength = DEFAULT_MAX_NAME_LENGTH,
	centerText = true,
	invalidInputText = RobloxTranslator:FormatByKey("CoreScripts.PublishAssetPrompt.InvalidName"),
}

local function isNameTooLong(str: string, maxLength: number)
	local utf8Length: number? = utf8.len(utf8.nfcnormalize(str))
	if utf8Length == nil then
		return true
	else
		return utf8Length > maxLength
	end
end

function NameTextBox:init()
	self:setState({
		name = self.props.defaultName or "",
		lastValidName = "",
		isNameValid = true,
	})

	self.wasInitiallyFocused = false

	self.tryFocusTextBox = function()
		if self.wasInitiallyFocused then
			return
		end

		local textbox = self.props.nameTextBoxRef and self.props.nameTextBoxRef:getValue()
		if textbox and textbox:IsDescendantOf(game) then
			textbox:CaptureFocus()
			self.wasInitiallyFocused = true
		end
	end

	self.onTextChanged = function(rbx)
		local name = rbx.Text

		local maxLength = self.props.maxLength
		if isNameTooLong(name, maxLength) then
			local byteOffset = utf8.offset(name, maxLength + 1) - 1
			name = string.sub(name, 1, byteOffset)
			rbx.Text = name
		end

		local isNameValid = self:checkIsNameValid(name)

		local lastValidName = self.state.lastValidName
		if isNameValid then
			lastValidName = rbx.Text
		end

		self:setState({
			lastValidName = lastValidName,
			isNameValid = isNameValid,
			name = name,
		})

		self.props.onNameUpdated(name, isNameValid)
	end
end

function NameTextBox:checkIsNameValid(name)
	if not FFlagRemoveNameRegex then
		--Name can only be made of alphanumeric, spaces, apostraphes, underscores
		if not string.match(name, "[0-9a-zA-Z_'%s]+$") then
			return false
		end

		-- no leading spaces
		if string.sub(name, 1, 1) == " " then
			return false
		end
	end
	--no names of only spaces
	if string.match(name, "^%s*$") then
		return false
	end

	return true
end

function NameTextBox:renderWithProviders(stylePalette, getSelectionCursor)
	local font = stylePalette.Font
	local theme = stylePalette.Theme

	local textboxStyle = font.Body

	local isNameValid = self.state.isNameValid
	local showWarningText = not isNameValid

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = self.props.Size,
		Position = self.props.Position,
		LayoutOrder = self.props.LayoutOrder,
	}, {
		TextBoxContainer = Roact.createElement("Frame", {
			BackgroundColor3 = theme.BackgroundMuted.Color,
			LayoutOrder = 1,
			Size = self.props.Size,
		}, {
			Textbox = Roact.createElement(Focusable.TextBox, {
				Text = self.state.name,
				BackgroundTransparency = 1,
				ClearTextOnFocus = false,
				Font = textboxStyle.Font,
				TextSize = font.BaseSize * textboxStyle.RelativeSize,
				PlaceholderColor3 = theme.PlaceHolder.Color,
				PlaceholderText = self.props.defaultName,
				Position = UDim2.fromOffset(TEXTBOX_PADDING, 0),
				Size = UDim2.new(1, -TEXTBOX_PADDING * 2, 1, 0),
				TextColor3 = theme.TextDefault.Color,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = if not self.props.centerText then Enum.TextYAlignment.Top else nil,
				OverlayNativeInput = true,
				[Roact.Change.Text] = self.onTextChanged,
				SelectionImageObject = getSelectionCursor(CursorKind.InputFields),
				NextSelectionDown = self.props.NextSelectionDown,

				[Roact.Ref] = self.props.nameTextBoxRef,
				[Roact.Event.AncestryChanged] = self.tryFocusTextBox,
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, TEXTBOX_PADDING),
					PaddingRight = UDim.new(0, TEXTBOX_PADDING),
					PaddingTop = if not self.props.centerText then UDim.new(0, TEXTBOX_PADDING) else nil,
				}),
			}),
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Thickness = 0.5,
				Transparency = theme.Divider.Transparency,
				Color = theme.Divider.Color,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			}),
		}),
		WarningText = showWarningText and Roact.createElement("TextLabel", {
			Position = UDim2.new(0, 0, 1, 0),

			BackgroundTransparency = 1,
			Text = self.props.invalidInputText,
			LayoutOrder = 2,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Size = UDim2.new(1, 0, 0, 20),
			TextColor3 = theme.Alert.Color,
			TextWrapped = true,
			Font = font.Body.Font,
			TextSize = WARNING_TEXT_SIZE,
		}),
	})
end

function NameTextBox:render()
	return withStyle(function(stylePalette)
		return withSelectionCursorProvider(function(getSelectionCursor)
			return self:renderWithProviders(stylePalette, getSelectionCursor)
		end)
	end)
end

function NameTextBox:didMount()
	self.tryFocusTextBox()
end

return NameTextBox
