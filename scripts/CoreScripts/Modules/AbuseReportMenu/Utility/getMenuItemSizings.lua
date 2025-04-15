--!nonstrict
local root = script:FindFirstAncestor("AbuseReportMenu")
local CorePackages = game:GetService("CorePackages")
local Constants = require(root.Components.Constants)

local UIBlox = require(CorePackages.Packages.UIBlox)
local useStyle = UIBlox.Core.Style.useStyle

local GetFFlagAddAbuseReportMenuCoreScriptsProvider = require(root.Flags.GetFFlagAddAbuseReportMenuCoreScriptsProvider)

function getMenuItemSizings()
	local style = useStyle()

	if GetFFlagAddAbuseReportMenuCoreScriptsProvider() then
		return {
			ItemPadding = style.Tokens.Global.Space_125, -- 12 for desktop, 18 for console
			DropdownTextSize = style.Tokens.Global.FontSize_100, -- 20.16 for desktop, 30.24 for console
			FontStyle = Constants.ReportMenuFontStyle,
			ButtonSize = Constants.ReportMenuButtonSizeConsole,
		}
	else
		return {
			ItemPadding = style.Tokens.Global.Size_150, -- 12 for desktop, 18 for console
			DropdownTextSize = style.Tokens.Global.FontSize_100, -- 20.16 for desktop, 30.24 for console
			FontStyle = Constants.ReportMenuFontStyle,
			ButtonSize = Constants.ReportMenuButtonSizeConsole,
		}
	end
end

return getMenuItemSizings
