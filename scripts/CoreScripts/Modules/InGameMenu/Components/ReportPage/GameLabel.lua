local CorePackages = game:GetService("CorePackages")

local InGameMenuDependencies = require(CorePackages.Packages.InGameMenuDependencies)
local Roact = InGameMenuDependencies.Roact
local UIBlox = InGameMenuDependencies.UIBlox
local t = InGameMenuDependencies.t
local Cryo = InGameMenuDependencies.Cryo

local withStyle = UIBlox.Core.Style.withStyle
local withSelectionCursorProvider = UIBlox.App.SelectionImage.withSelectionCursorProvider
local CursorKind = UIBlox.App.SelectionImage.CursorKind
local InGameMenu = script.Parent.Parent.Parent
local ThemedTextLabel = require(InGameMenu.Components.ThemedTextLabel)
local Assets = require(InGameMenu.Resources.Assets)

local React = require(CorePackages.Packages.React)

local ImageSetLabel = UIBlox.Core.ImageSet.ImageSetLabel

local CONTAINER_FRAME_HEIGHT = 70
local GAME_ICON_SIZE = 44
local GAME_ICON_PADDING_LEFT = 24
local GAMENAME_WIDTH = 219
local GAMENAME_HEIGHT = 22
local GAMENAME_LEFT_PADDING = 12
local GAMENAME_X_OFFSET = GAME_ICON_PADDING_LEFT + GAME_ICON_SIZE + GAMENAME_LEFT_PADDING

local BUTTONS_RIGHT_PADDING = 24
local BUTTONS_PADDING = 12

local GameLabel = Roact.PureComponent:extend("GameLabel")

GameLabel.validateProps = t.strictInterface({
	gameId = t.number,
	gameName = t.string,
	LayoutOrder = t.integer,
	onActivated = t.optional(t.callback),
	[Roact.Children] = t.optional(t.table),
	buttonRef = t.optional(t.table),
})

function GameLabel:renderButtons()
	local children = self.props[Roact.Children] or {}
	local buttons = Cryo.Dictionary.join(children, {
		List = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, BUTTONS_PADDING),
		}),
	})

	return buttons
end

function GameLabel:renderWithSelectionCursor(getSelectionCursor)
	local gameId = self.props.gameId
	local gameThumbnail = Assets.Images.PlaceholderGameIcon
	if self.props.gameId > 0 then
		gameThumbnail = "rbxthumb://type=GameIcon&id=" .. gameId .. "&w=150&h=150"
	end

	return withStyle(function(style)
		return Roact.createElement("TextButton", {
			[React.Tag] = "data-testid=experienceLabel",
			BackgroundTransparency = 1,
			LayoutOrder = self.props.LayoutOrder,
			Size = UDim2.new(1, 0, 0, CONTAINER_FRAME_HEIGHT),
			Text = "",
			AutoButtonColor = false,
			SelectionImageObject = getSelectionCursor(CursorKind.Square),
			[Roact.Ref] = self.props.buttonRef,
			[Roact.Event.Activated] = self.props.onActivated,
		}, {
			GameIcon = Roact.createElement(ImageSetLabel, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, GAME_ICON_PADDING_LEFT, 0.5, 0),
				Size = UDim2.new(0, GAME_ICON_SIZE, 0, GAME_ICON_SIZE),
				BackgroundTransparency = 1,
				Image = gameThumbnail,
			}),

			GameNameLabel = Roact.createElement(ThemedTextLabel, {
				fontKey = "Header2",
				themeKey = "TextEmphasis",

				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, GAMENAME_X_OFFSET, 0.5, 0),
				Size = UDim2.new(0, GAMENAME_WIDTH, 0, GAMENAME_HEIGHT),
				Text = self.props.gameName,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}),

			ButtonContainer = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -BUTTONS_RIGHT_PADDING, 0, 0),
				Size = UDim2.new(0, 0, 1, 0),
			}, self:renderButtons()),
		})
	end)
end

function GameLabel:render()
	return withSelectionCursorProvider(function(getSelectionCursor)
		return self:renderWithSelectionCursor(getSelectionCursor)
	end)
end

return Roact.forwardRef(function(props, ref)
	return Roact.createElement(
		GameLabel,
		Cryo.Dictionary.join(props, {
			buttonRef = ref,
		})
	)
end)
