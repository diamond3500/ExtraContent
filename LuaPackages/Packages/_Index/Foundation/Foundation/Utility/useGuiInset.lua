local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local Wrappers = require(Foundation.Utility.Wrappers)
local Instance = Wrappers.Instance
local GuiService = Wrappers.Services.GuiService
local UserInputService = Wrappers.Services.UserInputService

local React = require(Packages.React)
local ReactUtils = require(Packages.ReactUtils)

local useCallback = React.useCallback
local useExternalEvent = ReactUtils.useEventConnection

local function getGuiInset()
	local topLeftInset, bottomRightInset = GuiService:GetGuiInset()

	return Rect.new(topLeftInset, bottomRightInset)
end

local function useGuiInset()
	local guiInset, setGuiInset = React.useState(function()
		return getGuiInset()
	end)

	local updateGuiInset = useCallback(function()
		setGuiInset(getGuiInset())
	end, {})

	useExternalEvent(GuiService.SafeZoneOffsetsChanged, updateGuiInset)
	useExternalEvent(Instance.GetPropertyChangedSignal(UserInputService, "BottomBarSize"), updateGuiInset)
	useExternalEvent(Instance.GetPropertyChangedSignal(UserInputService, "RightBarSize"), updateGuiInset)

	return guiInset
end

return useGuiInset
