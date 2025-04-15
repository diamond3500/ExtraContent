--!nonstrict
local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local StarterGui = game:GetService("StarterGui")

local Modules = RobloxGui.Modules
local Roact = require(CorePackages.Packages.Roact)
local RoactRodux = require(CorePackages.Packages.RoactRodux)
local t = require(CorePackages.Packages.t)

local Components = script.Parent.Parent
local TopBar = Components.Parent

local UpdateCoreGuiEnabled = require(TopBar.Actions.UpdateCoreGuiEnabled)

local EventConnection = require(TopBar.Parent.Common.EventConnection)

local FFlagMountCoreGuiBackpack = require(Modules.Flags.FFlagMountCoreGuiBackpack)
local FFlagMountCoreGuiHealthBar = require(TopBar.Flags.FFlagMountCoreGuiHealthBar)

local CoreGuiConnector = Roact.PureComponent:extend("CoreGuiConnector")


CoreGuiConnector.validateProps = t.strictInterface({
	updateCoreGuiEnabled = t.callback,
})

function CoreGuiConnector:didMount()
	local initalCoreGuiTypes = Enum.CoreGuiType:GetEnumItems()
	for _, coreGuiType in ipairs(initalCoreGuiTypes) do
		if FFlagMountCoreGuiBackpack then
			if FFlagMountCoreGuiHealthBar then
				if coreGuiType ~= Enum.CoreGuiType.All and coreGuiType ~= Enum.CoreGuiType.Health and coreGuiType ~= Enum.CoreGuiType.Backpack then
					self.props.updateCoreGuiEnabled(coreGuiType, StarterGui:GetCoreGuiEnabled(coreGuiType))
				end
			else
				if coreGuiType ~= Enum.CoreGuiType.All and coreGuiType ~= Enum.CoreGuiType.Backpack then
					self.props.updateCoreGuiEnabled(coreGuiType, StarterGui:GetCoreGuiEnabled(coreGuiType))
				end
			end
		else
			if FFlagMountCoreGuiHealthBar then
				if coreGuiType ~= Enum.CoreGuiType.All and coreGuiType ~= Enum.CoreGuiType.Health then
					self.props.updateCoreGuiEnabled(coreGuiType, StarterGui:GetCoreGuiEnabled(coreGuiType))
				end
			else
				if coreGuiType ~= Enum.CoreGuiType.All then
					self.props.updateCoreGuiEnabled(coreGuiType, StarterGui:GetCoreGuiEnabled(coreGuiType))
				end
			end
		end
	end
end

function CoreGuiConnector:render()
	return Roact.createFragment({
		CoreGuiChangedConnection = Roact.createElement(EventConnection, {
			event = StarterGui.CoreGuiChangedSignal,
			callback = function(coreGuiType, enabled)
				if FFlagMountCoreGuiBackpack then
					if FFlagMountCoreGuiHealthBar then
						if coreGuiType ~= Enum.CoreGuiType.Health and coreGuiType ~= Enum.CoreGuiType.Backpack then
							self.props.updateCoreGuiEnabled(coreGuiType, enabled)
						end
					else
						if coreGuiType ~= Enum.CoreGuiType.Backpack then
							self.props.updateCoreGuiEnabled(coreGuiType, enabled)
						end
					end
				else
					if FFlagMountCoreGuiHealthBar then
						if coreGuiType ~= Enum.CoreGuiType.Health then
							self.props.updateCoreGuiEnabled(coreGuiType, enabled)
						end
					else
						self.props.updateCoreGuiEnabled(coreGuiType, enabled)
					end
				end
			end,
		}),
	})

end

local function mapDispatchToProps(dispatch)
	return {
		updateCoreGuiEnabled = function(coreGuiType, enabled)
			return dispatch(UpdateCoreGuiEnabled(coreGuiType, enabled))
		end,
	}
end

return RoactRodux.UNSTABLE_connect2(nil, mapDispatchToProps)(CoreGuiConnector)
