local Root = script:FindFirstAncestor("ChromeShared")
local ChromeUtils = require(Root.Service.ChromeUtils)

local CorePackages = game:GetService("CorePackages")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local LocalizationService = game:GetService("LocalizationService")
local Localization = require(CorePackages.Workspace.Packages.InExperienceLocales).Localization
local locales = Localization.new(LocalizationService.RobloxLocaleId)

local AppCommonLib = require(CorePackages.Workspace.Packages.AppCommonLib)

local Types = require(Root.Service.Types)

local Signal = AppCommonLib.Signal

local SharedFlags = require(CorePackages.Workspace.Packages.SharedFlags)
local FFlagConsoleSinglePressIntegrationExit = SharedFlags.FFlagConsoleSinglePressIntegrationExit

type ShortcutId = Types.ShortcutId
type ShortcutBarId = Types.ShortcutBarId
type ShortcutIdList = Types.ShortcutIdList
type ShortcutBarList = Types.ShortcutBarList
type ShortcutList = Types.ShortcutList

local ShortcutService = {} :: ShortcutService
ShortcutService.__index = ShortcutService

export type ShortcutService = {
	__index: ShortcutService,

	new: () -> ShortcutService,

	registerShortcut: (ShortcutService, shortcutProps: Types.ShortcutRegisterProps) -> (),
	activateShortcut: (ShortcutService, shortcutId: ShortcutId) -> Enum.ContextActionResult?,

	configureShortcutBar: (ShortcutService, shortcutBarId: ShortcutBarId, config: Types.ShortcutBarProps) -> (),
	setShortcutBar: (ShortcutService, shortcutBarId: ShortcutBarId?) -> (),
	getShortcut: (ShortcutService, shortcutId: ShortcutId) -> Types.ShortcutProps,
	shortcuts: (ShortcutService) -> Types.ShortcutList,
	getShortcutsFromBar: (
		ShortcutService,
		shortcutBarId: ShortcutBarId?,
		integrationList: Types.IntegrationList
	) -> Types.ShortcutBarItems,
	getCurrentShortcutBar: (ShortcutService) -> ShortcutBarId?,

	onShortcutBarChanged: AppCommonLib.Signal,

	_bindShortcutBar: (ShortcutService, shortcutBarId: ShortcutBarId) -> (),
	_unbindShortcutBar: (ShortcutService, shortcutBarId: ShortcutBarId) -> (),
	_handleShortcutEvent: (
		ShortcutService
	) -> (actionName: string, userInputState: Enum.UserInputState, input: InputObject) -> Enum.ContextActionResult,

	_shortcuts: ShortcutList,
	_shortcutBarList: ShortcutBarList,
	_currentShortcutBar: ShortcutBarId?,
}

local function _handleShortcutEvent(shortcutService: ShortcutService)
	return function(actionName: string, userInputState: Enum.UserInputState, input: InputObject)
		if userInputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		for id, shortcut in shortcutService._shortcuts do
			if shortcut.actionName and shortcut.actionName == actionName then
				if FFlagConsoleSinglePressIntegrationExit then
					return shortcutService:activateShortcut(id) or Enum.ContextActionResult.Sink
				else
					shortcutService:activateShortcut(id)
					return Enum.ContextActionResult.Sink
				end
			end
		end
		return Enum.ContextActionResult.Pass
	end
end

function ShortcutService.new(): ShortcutService
	local self = {}

	self._shortcuts = {} :: ShortcutIdList
	self._shortcutBarList = {} :: ShortcutBarList

	self.onShortcutBarChanged = Signal.new()

	return (setmetatable(self, ShortcutService) :: any) :: ShortcutService
end

function ShortcutService:registerShortcut(shortcut: Types.ShortcutRegisterProps)
	if self._shortcuts[shortcut.id] then
		warn(string.format("shortcut " .. shortcut.id .. " already registered", debug.traceback()))
	end

	local newShortcut = shortcut :: Types.ShortcutProps
	if shortcut.label then
		newShortcut.label = locales:Format(shortcut.label)
	end

	newShortcut.icon = UserInputService:GetImageForKeyCode(shortcut.keyCode)

	self._shortcuts[shortcut.id] = newShortcut
end

function ShortcutService:activateShortcut(shortcutId: ShortcutId)
	if self._shortcuts[shortcutId] then
		local shortcut = self._shortcuts[shortcutId]

		if shortcut.activated then
			return shortcut.activated()
		end
	end
	return nil
end

function ShortcutService:configureShortcutBar(shortcutBarId: ShortcutBarId, config: Types.ShortcutBarProps)
	self._shortcutBarList[shortcutBarId] = config
end

function ShortcutService:setShortcutBar(shortcutBarId: ShortcutBarId?)
	if self._currentShortcutBar ~= shortcutBarId then
		if self._currentShortcutBar and self._shortcutBarList[self._currentShortcutBar] then
			self:_unbindShortcutBar(self._currentShortcutBar)
		end

		self._currentShortcutBar = shortcutBarId
		self.onShortcutBarChanged:fire(shortcutBarId)

		if shortcutBarId and self._shortcutBarList[shortcutBarId] then
			self:_bindShortcutBar(shortcutBarId)
		end
	end
end

function ShortcutService:getShortcut(shortcutId: ShortcutId)
	return self._shortcuts[shortcutId]
end

function ShortcutService:getShortcutsFromBar(shortcutBarId: ShortcutBarId?, integrationList: Types.IntegrationList)
	if not shortcutBarId then
		return {}
	end
	local activeShortcuts: Types.ShortcutBarItems = {}

	for k, shortcutId in self._shortcutBarList[shortcutBarId] do
		if not self._shortcuts[shortcutId] then
			warn(string.format("shortcut " .. shortcutId .. " not found", debug.traceback()))
			continue
		end

		local shortcut = self._shortcuts[shortcutId]

		if shortcut.integration then
			if
				integrationList[shortcut.integration].availability:get()
				== ChromeUtils.AvailabilitySignalState.Unavailable
			then
				continue
			end
		end
		table.insert(activeShortcuts, shortcut)
	end

	return activeShortcuts
end

function ShortcutService:getCurrentShortcutBar()
	return self._currentShortcutBar
end

function ShortcutService:_bindShortcutBar(shortcutBarId: ShortcutBarId)
	for k, shortcutId in self._shortcutBarList[shortcutBarId] do
		local shortcut = self._shortcuts[shortcutId]
		if shortcut and shortcut.actionName then
			ContextActionService:UnbindCoreAction(shortcut.actionName)
			ContextActionService:BindCoreAction(
				shortcut.actionName,
				_handleShortcutEvent(self),
				false,
				shortcut.keyCode
			)
		end
	end
end

function ShortcutService:_unbindShortcutBar(shortcutBarId: ShortcutBarId)
	if shortcutBarId then
		for k, shortcutId in self._shortcutBarList[shortcutBarId] do
			local shortcut = self._shortcuts[shortcutId]
			if shortcut and shortcut.actionName then
				ContextActionService:UnbindCoreAction(shortcut.actionName)
			end
		end
	end
end

return ShortcutService
