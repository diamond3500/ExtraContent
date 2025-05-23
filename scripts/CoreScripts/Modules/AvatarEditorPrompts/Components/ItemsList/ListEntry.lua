--!nonstrict
local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules

local Cryo = require(CorePackages.Packages.Cryo)
local Roact = require(CorePackages.Packages.Roact)
local t = require(CorePackages.Packages.t)
local UIBlox = require(CorePackages.Packages.UIBlox)
local AvatarExperienceDeps = require(CorePackages.Packages.AvatarExperienceDeps)
local Text = require(CorePackages.Workspace.Packages.AppCommonLib).Text

local RoactFitComponents = AvatarExperienceDeps.RoactFitComponents
local FitTextLabel = RoactFitComponents.FitTextLabel
local withStyle = UIBlox.Style.withStyle

local BULLET_POINT_SYMBOL = "• "

local ListEntry = Roact.PureComponent:extend("ListEntry")

ListEntry.validateProps = t.strictInterface({
	text = t.string,
	hasBullet = t.boolean,
	layoutOrder = t.integer,
	positionChangedCallback = t.optional(t.callback),

	NextSelectionLeft = t.optional(t.table),
	NextSelectionRight = t.optional(t.table),
	NextSelectionUp = t.optional(t.table),
	NextSelectionDown = t.optional(t.table),
	forwardRef = t.optional(t.table),
})

function ListEntry:render()
	return withStyle(function(stylePalette)
		local fontInfo = stylePalette.Font
		local theme = stylePalette.Theme

		local font = fontInfo.CaptionBody.Font
		local fontSize = fontInfo.BaseSize * fontInfo.CaptionBody.RelativeSize

		local bulletPointWidth = Text.GetTextWidth(BULLET_POINT_SYMBOL, font, fontSize)

		local forwardRef = self.props.forwardRef

		return Roact.createElement(RoactFitComponents.FitFrameVertical, {
			width = UDim.new(1, 0),

			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Top,

			BackgroundTransparency = 1,
			LayoutOrder = self.props.layoutOrder,

			[Roact.Change.AbsolutePosition] = self.props.positionChangedCallback,

			NextSelectionLeft = self.props.NextSelectionLeft,
			NextSelectionRight = self.props.NextSelectionRight,
			NextSelectionUp = self.props.NextSelectionUp,
			NextSelectionDown = self.props.NextSelectionDown,
			[Roact.Ref] = forwardRef,
		}, {
			Bullet = self.props.hasBullet and Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(bulletPointWidth, fontSize),
				Text = BULLET_POINT_SYMBOL,
				Font = font,
				TextSize = fontSize,
				TextColor3 = theme.TextDefault.Color,
				TextTransparency = theme.TextDefault.Transparency,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 1,
			}),

			Text = Roact.createElement(FitTextLabel, {
				width = UDim.new(1, self.props.hasBullet and -bulletPointWidth or 0),

				BackgroundTransparency = 1,
				Text = self.props.text,
				Font = font,
				TextSize = fontSize,
				TextColor3 = theme.TextDefault.Color,
				TextTransparency = theme.TextDefault.Transparency,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 2,
			}),
		})
	end)
end

return Roact.forwardRef(function(props, ref)
	return Roact.createElement(
		ListEntry,
		Cryo.Dictionary.join(props, {
			forwardRef = ref,
		})
	)
end)
