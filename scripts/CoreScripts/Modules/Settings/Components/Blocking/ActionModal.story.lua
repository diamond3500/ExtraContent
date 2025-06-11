local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(CorePackages.Packages.Roact)
local Cryo = require(CorePackages.Packages.Cryo)
local ActionModal = require(script.Parent.ActionModal)

local FFlagEnableNewBlockingModal = require(Modules.Common.Flags.FFlagEnableNewBlockingModal)

local noOpt = function() end

return function(props)
	return Roact.createElement(
		ActionModal,
		Cryo.Dictionary.join({
			action = if FFlagEnableNewBlockingModal then nil else noOpt,
			actionText = if FFlagEnableNewBlockingModal then nil else "Block",
			body = "block now",
			cancel = noOpt,
			cancelText = "Cancel",
			displayName = "DisplayName",
			title = "remove someone",
			block = if FFlagEnableNewBlockingModal then noOpt else nil,
			blockText = if FFlagEnableNewBlockingModal then "Block" else nil,
			blockAndReport = if FFlagEnableNewBlockingModal then noOpt else nil,
			blockAndReportText = if FFlagEnableNewBlockingModal then "BlockAndReport" else nil,
		}, props)
	)
end
