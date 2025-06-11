local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")

local Roact = require(CorePackages.Packages.Roact)
local React = require(CorePackages.Packages.React)
local RoactRodux = require(CorePackages.Packages.RoactRodux)

local RobloxGui = CoreGui:WaitForChild("RobloxGui")

local TenFootInterface = require(RobloxGui.Modules.TenFootInterface)

local PlayerList = script.Parent.Parent.Parent
local FFlagPlayerListReduceRerenders = require(PlayerList.Flags.FFlagPlayerListReduceRerenders)

-- TODO: This top stat thing is bad, can just make TenFootInterface fully responsible?
-- Or just move this whole thing into new Roact PlayerList?
local topStat = nil
if TenFootInterface:IsEnabled() then
	topStat = TenFootInterface:SetupTopStat()
end

local TopStatConnector = Roact.PureComponent:extend("TopStatConnector")

function TopStatConnector:render()
	if topStat then
		topStat:SetTopStatEnabled(self.props.displayOptions.playerlistCoreGuiEnabled)
	end
	return nil
end

local function mapStateToProps(state)
	return {
		displayOptions = state.displayOptions,
	}
end

if FFlagPlayerListReduceRerenders then
	return React.memo(RoactRodux.connect(mapStateToProps, nil)(TopStatConnector))
end

return RoactRodux.connect(mapStateToProps, nil)(TopStatConnector)
