local Packages = script.Parent
local Cryo = require(Packages.Cryo)
local RoduxNetworking = require(Packages.RoduxNetworking)
local NetworkingPresence = require(Packages.NetworkingPresence)

local Reducer = require(script.Reducer)
local Actions = require(script.Actions)
local Selectors = require(script.Selectors)
local Models = require(script.Models)
local Enums = require(script.Enums)

return {
	config = function(options)
		options = Cryo.Dictionary.join(options, {
			presenceNetworking = NetworkingPresence.config({
				roduxNetworking = RoduxNetworking.mock(),
			}),
		})

		return {
			installReducer = function()
				return Reducer(options)
			end,
			Actions = Actions(options),
			Selectors = Selectors(options),
			Models = Models,
			Enums = Enums,
		}
	end,
}
