local root = script:FindFirstAncestor("AbuseReportMenu")
local GuiService = game:GetService("GuiService")
local Constants = require(root.Components.Constants)

function getMenuItemDimensions(menuWidth)
	if menuWidth < Constants.SmallLayoutThreshold then
		return {
			LeftWidth = Constants.LeftContainerWidthSmall,
			RightWidth = Constants.RightContainerWidthSmall,
			TextSize = Constants.FieldLabelSizeSmall,
		}
	elseif GuiService:IsTenFootInterface() then
		return {
			LeftWidth = Constants.LeftContainerWidthConsole,
			RightWidth = Constants.RightContainerWidthConsole,
			TextSize = Constants.FieldLabelSizeConsole,
		}
	end
	return {
		LeftWidth = Constants.LeftContainerWidth,
		RightWidth = Constants.RightContainerWidth,
		TextSize = Constants.FieldLabelSize,
	}
end

return getMenuItemDimensions
