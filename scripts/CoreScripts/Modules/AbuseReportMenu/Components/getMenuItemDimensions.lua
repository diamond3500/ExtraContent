local root = script:FindFirstAncestor("AbuseReportMenu")
local CorePackages = game:GetService("CorePackages")
local Constants = require(root.Components.Constants)

local UIBlox = require(CorePackages.Packages.UIBlox)
local useStyle = UIBlox.Core.Style.useStyle

local GetFFlagAddAbuseReportMenuCoreScriptsProvider = require(root.Flags.GetFFlagAddAbuseReportMenuCoreScriptsProvider)

function getMenuItemDimensions(menuWidth)
	local style = useStyle()

	if menuWidth < Constants.SmallLayoutThreshold then
		return {
			LeftWidth = Constants.LeftContainerWidthSmall,
			RightWidth = Constants.RightContainerWidthSmall,
			TextSize = Constants.FieldLabelSizeSmall,
		}
	end
	if GetFFlagAddAbuseReportMenuCoreScriptsProvider() then
		return {
			LeftWidth = style.Tokens.Global.Space_1000 * 3, -- 240 for desktop, 360 for console
			RightWidth = style.Tokens.Global.Space_1000 * 4, -- 320 for desktop, 480 for console
			TextSize = style.Tokens.Global.FontSize_100, -- 20.16 for desktop, 30.24 for console
		}
	else
		return {
			LeftWidth = Constants.LeftContainerWidth,
			RightWidth = Constants.RightContainerWidth,
			TextSize = Constants.FieldLabelSize,
		}
	end
end

return getMenuItemDimensions
