--!nonstrict
local root = script:FindFirstAncestor("AbuseReportMenu")
local GuiService = game:GetService("GuiService")
local Constants = require(root.Components.Constants)

function getMenuItemSizings()
	if GuiService:IsTenFootInterface() then
		return {
			ItemPadding = Constants.ReportMenuItemPaddingConsole,
			TopPadding = Constants.ReportMenuTopPaddingConsole,
			TextOffset = Constants.ReportMenuTextOffsetConsole,
			DropdownTextSize = Constants.ReportMenuDropdownTextSizeConsole,
			FontStyle = Constants.ReportMenuFontStyleConsole,
			TextEntryRelativeSize = Constants.ReportTextEntryFontRelativeSizeConsole,
			ButtonSize = Constants.ReportMenuButtonSizeConsole,
		}
	end
	return {
		ItemPadding = Constants.ReportMenuItemPadding,
		TopPadding = Constants.ReportMenuTopPadding,
		TextOffset = Constants.ReportMenuTextOffset,
		DropdownTextSize = Constants.ReportMenuDropdownTextSize,
		FontStyle = Constants.ReportMenuFontStyle,
		TextEntryRelativeSize = Constants.ReportTextEntryFontRelativeSize,
		ButtonSize = Constants.ReportMenuButtonSize,
	}
end

return getMenuItemSizings
