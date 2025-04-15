local CorePackages = game:GetService("CorePackages")

local Rodux = require(CorePackages.Packages.Rodux)

local RobloxTranslator = require(CorePackages.Workspace.Packages.RobloxTranslator)

local Actions = script.Parent.Parent.Actions

local SetGameName = require(Actions.SetGameName)

return Rodux.createReducer({
	name = RobloxTranslator:FormatByKey("CoreScripts.TopBar.GameNamePlaceHolder"),
}, {
	[SetGameName.name] = function(state, action)
		return {
			name = action.gameName,
		}
	end,
})
