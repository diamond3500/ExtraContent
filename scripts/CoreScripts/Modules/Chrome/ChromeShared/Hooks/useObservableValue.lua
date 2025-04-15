local Root = script:FindFirstAncestor("ChromeShared")

local CorePackages = game:GetService("CorePackages")
local React = require(CorePackages.Packages.React)
local ChromeUtils = require(Root.Service.ChromeUtils)
local FFlagChromeObservableStateCheck =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagChromeObservableStateCheck()

return function<T>(observableValue: ChromeUtils.ObservableValue<T>): T | nil
	if not observableValue then
		warn("observableValue undefined")
		return nil
	end

	local value, setValue = React.useState(observableValue:get())
	React.useEffect(function()
		local conn = observableValue:connect(function()
			setValue(observableValue:get())
		end)

		if FFlagChromeObservableStateCheck then
			if value ~= observableValue:get() then
				setValue(observableValue:get())
			end
		end

		return function()
			conn:disconnect()
		end
	end, { observableValue })

	return value
end
