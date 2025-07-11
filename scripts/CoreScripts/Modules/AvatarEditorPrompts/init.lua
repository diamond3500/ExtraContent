local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")

local RobloxGui = CoreGui:WaitForChild("RobloxGui")

local renderWithCoreScriptsStyleProvider = require(RobloxGui.Modules.Common.renderWithCoreScriptsStyleProvider)

local Roact = require(CorePackages.Packages.Roact)
local Rodux = require(CorePackages.Packages.Rodux)
local RoactRodux = require(CorePackages.Packages.RoactRodux)

local AvatarEditorPromptsApp = require(script.Components.AvatarEditorPromptsApp)
local Reducer = require(script.Reducer)

local GetGameName = require(script.Thunks.GetGameName)
local AvatarEditorPromptsPolicy = require(script.AvatarEditorPromptsPolicy)

local RoactGlobalConfig = require(script.RoactGlobalConfig)

local ConnectAvatarEditorServiceEvents = require(script.ConnectAvatarEditorServiceEvents)

local AvatarEditorPrompts = {}
AvatarEditorPrompts.__index = AvatarEditorPrompts

function AvatarEditorPrompts.new()
	local self = setmetatable({}, AvatarEditorPrompts)

	if RoactGlobalConfig.propValidation then
		Roact.setGlobalConfig({
			propValidation = true,
		})
	end
	if RoactGlobalConfig.elementTracing then
		Roact.setGlobalConfig({
			elementTracing = true,
		})
	end

	self.store = Rodux.Store.new(Reducer, nil, {
		Rodux.thunkMiddleware,
	})

	self.store:dispatch(GetGameName)

	local providerWrappedApp = Roact.createElement(RoactRodux.StoreProvider, {
		store = self.store,
	}, {
		PolicyProvider = Roact.createElement(AvatarEditorPromptsPolicy.Provider, {
			policy = { AvatarEditorPromptsPolicy.Mapper },
		}, {
			ThemeProvider = renderWithCoreScriptsStyleProvider({
				AvatarEditorPromptsApp = Roact.createElement(AvatarEditorPromptsApp),
			}),
		}),
	})
	-- Root should be a Folder so that style provider stylesheet elements can be portaled properly; otherwise, they will attach to CoreGui
	self.root = Roact.createElement("Folder", {
		Name = "AvatarEditorPromptsApp",
	}, providerWrappedApp)

	self.element = Roact.mount(self.root, CoreGui, "AvatarEditorPrompts")

	self.serviceConnections = ConnectAvatarEditorServiceEvents(self.store)

	return self
end

return AvatarEditorPrompts.new()
