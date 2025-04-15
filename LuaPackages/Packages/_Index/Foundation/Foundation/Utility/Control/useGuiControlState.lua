local Control = script.Parent
local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)
local ReactUtils = require(Packages.ReactUtils)
local useForwardRef = ReactUtils.useForwardRef
local ControlState = require(Foundation.Enums.ControlState)
local ControlStateEvent = require(Foundation.Enums.ControlStateEvent)
local Flags = require(Foundation.Utility.Flags)

local createGuiControlStateTable = require(Control.createGuiControlStateTable)

type ControlState = ControlState.ControlState
type ControlStateEvent = ControlStateEvent.ControlStateEvent
type StateChangedCallback = createGuiControlStateTable.onGuiControlStateChange

local guiStateMapper: { [Enum.GuiState]: ControlState } = {
	[Enum.GuiState.Idle] = ControlState.Default,
	[Enum.GuiState.Hover] = ControlState.Hover,
	[Enum.GuiState.Press] = ControlState.Pressed,
	[Enum.GuiState.NonInteractable] = ControlState.Disabled,
}

local function useGuiControlState(
	guiObjectRef: React.Ref<Instance>,
	onStateChanged: StateChangedCallback,
	userInteractionEnabled: boolean?
)
	local interactionEnabled = if Flags.FoundationInteractableUseGuiState
		then nil :: never
		else React.useRef(userInteractionEnabled)
	local isSelected = React.useRef(false)
	local currentControlState = React.useRef(ControlState.Initialize :: ControlState)

	local guiStateTable = if not Flags.FoundationInteractableUseGuiState
		then React.useMemo(function()
			return createGuiControlStateTable(onStateChanged)
		end, {})
		else nil :: never

	if not Flags.FoundationInteractableUseGuiState then
		React.useEffect(function()
			guiStateTable:onStateChange(onStateChanged)
		end, { onStateChanged })
	end

	local onControlStateChanged = if Flags.FoundationInteractableUseGuiState
		then React.useCallback(function(newState: ControlState)
			local oldState = currentControlState.current

			if isSelected.current then
				if newState == ControlState.Default then
					newState = ControlState.Selected
				elseif newState == ControlState.Hover then
					newState = ControlState.Selected
				elseif newState == ControlState.Pressed then
					newState = ControlState.SelectedPressed
				end
			end

			if oldState == newState then
				return
			end

			currentControlState.current = newState

			if onStateChanged ~= nil then
				onStateChanged(newState)
			end
		end, { onStateChanged })
		else nil :: never

	local onRefChange = React.useCallback(function(instance: GuiObject)
		local connections: { RBXScriptConnection } = {}
		if instance then
			if Flags.FoundationInteractableUseGuiState then
				onControlStateChanged(guiStateMapper[instance.GuiState])
			end

			if Flags.FoundationInteractableUseGuiState then
				table.insert(
					connections,
					instance:GetPropertyChangedSignal("GuiState"):Connect(function()
						local controlState: ControlState = guiStateMapper[instance.GuiState]
						onControlStateChanged(controlState)
					end)
				)
			end

			if not Flags.FoundationInteractableUseGuiState then
				table.insert(
					connections,
					instance.InputBegan:Connect(function(inputObject: InputObject)
						if not interactionEnabled.current then
							return nil
						end
						if
							inputObject.UserInputType == Enum.UserInputType.MouseButton1
							or inputObject.UserInputType == Enum.UserInputType.Touch
							or inputObject.KeyCode == Enum.KeyCode.ButtonA
							or inputObject.KeyCode == Enum.KeyCode.Return
						then
							guiStateTable.events.PrimaryPressed()
						end
					end)
				)
				table.insert(
					connections,
					instance.InputEnded:Connect(function(inputObject: InputObject)
						if not interactionEnabled.current then
							return nil
						end
						if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
							guiStateTable.events.PrimaryReleasedHover()
						elseif
							inputObject.UserInputType == Enum.UserInputType.Touch
							or inputObject.KeyCode == Enum.KeyCode.ButtonA
							or inputObject.KeyCode == Enum.KeyCode.Return
						then
							guiStateTable.events.PrimaryReleased()
						end
					end)
				)
			end

			-- Selected state is not part of GuiState, so we need to handle it separately with SelectionGained and SelectionLost
			table.insert(
				connections,
				instance.SelectionGained:Connect(function()
					if Flags.FoundationInteractableUseGuiState then
						isSelected.current = true
						onControlStateChanged(currentControlState.current :: ControlState)
					else
						if not interactionEnabled.current then
							return
						end
						guiStateTable.events.SelectionGained()
					end
				end)
			)
			table.insert(
				connections,
				instance.SelectionLost:Connect(function()
					if Flags.FoundationInteractableUseGuiState then
						isSelected.current = false
						onControlStateChanged(currentControlState.current :: ControlState)
					else
						if not interactionEnabled.current then
							return
						end
						guiStateTable.events.SelectionLost()
					end
				end)
			)

			if not Flags.FoundationInteractableUseGuiState then
				table.insert(
					connections,
					instance.MouseEnter:Connect(function()
						if not interactionEnabled.current then
							return
						end
						guiStateTable.events.PointerHover()
					end)
				)
				table.insert(
					connections,
					instance.MouseLeave:Connect(function()
						if not interactionEnabled.current then
							return
						end
						guiStateTable.events.PointerHoverEnd()
					end)
				)
			end
		end

		return function()
			for _, connection in connections do
				connection:Disconnect()
			end
		end
	end, { guiStateTable :: any, onControlStateChanged })

	if not Flags.FoundationInteractableUseGuiState then
		React.useEffect(function()
			interactionEnabled.current = userInteractionEnabled
		end, { userInteractionEnabled })
	end

	return useForwardRef(guiObjectRef, onRefChange),
		if Flags.FoundationInteractableUseGuiState then nil :: never else guiStateTable
end

return useGuiControlState
