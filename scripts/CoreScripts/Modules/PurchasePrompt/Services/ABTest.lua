--!nonstrict
--[[
	Used to query ABTest data to run IXP experiments

	Make sure you add your layer data to IXPServiceWrapper:InitializeAsync in order to query layer data
	In game UI shares the same init so you'll find this in StarterScript.lua (init script for all in game lua)
]]
local CorePackages = game:GetService("CorePackages")

local IXPServiceWrapper = require(CorePackages.Workspace.Packages.IxpServiceWrapper).IXPServiceWrapper

local ABTest = {}

function ABTest.new()
	local service = {}

	setmetatable(service, {
		__tostring = function()
			return "Service(ABTest)"
		end,
	})

	function service.getLayerData(layerName)
		return IXPServiceWrapper:GetLayerData(layerName)
	end

	function service.logUserLayerExposure(layerName)
		IXPServiceWrapper:LogUserLayerExposure(layerName)
	end

	return service
end

return ABTest
