local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local Cryo = require(Packages.Cryo)
local React = require(Packages.React)

local Components = Foundation.Components
local InputLabel = require(Components.InputLabel)
local View = require(Components.View)
local Types = require(Components.Types)
local StateLayerAffordance = require(Foundation.Enums.StateLayerAffordance)

local useTokens = require(Foundation.Providers.Style.useTokens)
local useCursor = require(Foundation.Providers.Cursor.useCursor)
local withCommonProps = require(Foundation.Utility.withCommonProps)
local withDefaults = require(Foundation.Utility.withDefaults)
local getInputTextSize = require(Foundation.Utility.getInputTextSize)

local useRadioGroupItemVariants = require(script.Parent.useRadioGroupItemVariants_DEPRECATED)
type RadioItemState = useRadioGroupItemVariants.RadioItemState

local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize
local InputLabelSize = require(Foundation.Enums.InputLabelSize)
type InputLabelSize = InputLabelSize.InputLabelSize

local ControlState = require(Foundation.Enums.ControlState)
type ControlState = ControlState.ControlState

local CursorType = require(Foundation.Enums.CursorType)
type CursorType = CursorType.CursorType

local DISABLED_TRANSPARENCY = 0.5

local useCheckedValue = require(script.Parent.Parent.useCheckedValue)

type Props = {
	-- A unique value for the radio item.
	value: string,
	-- Whether the radio item is disabled. When `true`, the `setValue` method
	-- will not be invoked, even if the user interacts with the radio item.
	isDisabled: boolean?,
	-- A label for the radio item. To omit, set it to an empty string.
	-- When nil, defaults to `value`.
	label: string | React.ReactNode?,
	-- Size of the radio item
	size: InputSize?,
} & Types.CommonProps

local defaultProps = {
	size = InputSize.Medium,
	isDisabled = false,
}

local function RadioGroupItem(radioGroupItemProps: Props, ref: React.Ref<GuiObject>?)
	local props = withDefaults(radioGroupItemProps, defaultProps)
	local isDisabled = props.isDisabled
	local isHovering, setIsHovering = React.useState(false)
	local value, setValue = useCheckedValue()

	local isChecked = value == props.value
	local label = props.label or props.value
	local hasLabel = label ~= ""

	local tokens = useTokens()
	local cursorConfig = React.useMemo(function()
		local radius = if hasLabel then UDim.new(0, tokens.Radius.Small) else UDim.new(0, tokens.Radius.Circle)
		return {
			radius = radius,
			offset = tokens.Size.Size_200,
			borderWidth = tokens.Stroke.Thicker,
		}
	end, { tokens :: any, hasLabel })
	local cursor = useCursor(cursorConfig)

	local onActivated = React.useCallback(function()
		if not isDisabled then
			setValue(props.value)
		end
	end, { isDisabled :: any, props.value, setValue })

	local onInputStateChanged = React.useCallback(function(newState: ControlState)
		setIsHovering(newState == ControlState.Hover)
	end, {})

	local itemState: RadioItemState = React.useMemo(function()
		if isChecked then
			return "Checked"
		elseif isHovering and not isDisabled then
			return ControlState.Hover
		else
			return ControlState.Default
		end
	end, { isChecked, isHovering, isDisabled }) :: RadioItemState

	local variantProps = useRadioGroupItemVariants(tokens, props.size, itemState)

	local interactionProps = {
		Active = not isDisabled,
		GroupTransparency = if isDisabled then DISABLED_TRANSPARENCY else 0,
		onActivated = onActivated,
		onStateChanged = onInputStateChanged,
		stateLayer = { affordance = StateLayerAffordance.None },
		selection = {
			Selectable = not props.isDisabled,
			SelectionImageObject = cursor,
		},
		isDisabled = isDisabled,
		ref = ref,
	}

	local radioContainerProps = {
		Size = variantProps.radioItem.size,
		stroke = {
			Color = variantProps.radioItem.stroke.Color3,
			Transparency = if props.isDisabled and not hasLabel
				then DISABLED_TRANSPARENCY
				else variantProps.radioItem.stroke.Transparency,
		},
		tag = variantProps.radioItem.tag,
	}

	local radio = React.createElement(
		View,
		if hasLabel
			then radioContainerProps
			else withCommonProps(props, Cryo.Dictionary.union(radioContainerProps, interactionProps)),
		{
			Center = if isChecked
				then React.createElement(View, {
					tag = variantProps.checkmark.tag,
				})
				else nil,
		}
	)

	if not hasLabel then
		return radio
	end

	--[[
		Labels for radio buttons and radio items should be positioned after the field.
		Source: https://www.w3.org/TR/WCAG20-TECHS/G162.html
	]]
	return React.createElement(
		View,
		withCommonProps(
			props,
			Cryo.Dictionary.union({
				-- Add padding around radio item to ensure it's not cut off
				-- by the bounds of the canvas group
				padding = variantProps.container.padding,
				tag = variantProps.container.tag,
			}, interactionProps)
		),
		{
			Radio = radio,
			Label = if type(label) == "string"
				then React.createElement(InputLabel, {
					Text = label,
					textStyle = variantProps.label.style,
					size = getInputTextSize(props.size, true),
					LayoutOrder = 2,
				})
				else label,
		}
	)
end

return React.memo(React.forwardRef(RadioGroupItem))
