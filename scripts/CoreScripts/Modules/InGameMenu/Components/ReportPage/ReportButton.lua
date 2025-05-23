local CorePackages = game:GetService("CorePackages")

local InGameMenuDependencies = require(CorePackages.Packages.InGameMenuDependencies)
local Roact = InGameMenuDependencies.Roact
local RoactRodux = InGameMenuDependencies.RoactRodux
local t = InGameMenuDependencies.t
local UIBlox = InGameMenuDependencies.UIBlox

local InGameMenu = script.Parent.Parent.Parent

local GlobalConfig = require(InGameMenu.GlobalConfig)

local Assets = require(InGameMenu.Resources.Assets)

local OpenReportDialog = require(InGameMenu.Actions.OpenReportDialog)

local ImageSetButton = UIBlox.Core.ImageSet.ImageSetButton
local withSelectionCursorProvider = UIBlox.App.SelectionImage.withSelectionCursorProvider
local CursorKind = UIBlox.App.SelectionImage.CursorKind

local validateProps = t.strictInterface({
	userId = t.optional(t.integer),
	userName = t.optional(t.string),
	LayoutOrder = t.integer,
	dispatchOpenReportDialog = t.callback,
})

local function ReportButton(props)
	if GlobalConfig.propValidation then
		assert(validateProps(props))
	end

	return withSelectionCursorProvider(function(getSelectionCursor)
		return Roact.createElement(ImageSetButton, {
			Selectable = false,
			Image = Assets.Images.ReportIcon,
			Size = UDim2.new(0, 36, 0, 36),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			LayoutOrder = props.LayoutOrder,
			SelectionImageObject = getSelectionCursor(CursorKind.RoundedRectNoInset),
			[Roact.Event.Activated] = function()
				props.dispatchOpenReportDialog(props.userId, props.userName)
			end,
		})
	end)
end

return RoactRodux.UNSTABLE_connect2(nil, function(dispatch)
	return {
		dispatchOpenReportDialog = function(userId, userName)
			dispatch(OpenReportDialog(userId, userName))
		end,
	}
end)(ReportButton)
