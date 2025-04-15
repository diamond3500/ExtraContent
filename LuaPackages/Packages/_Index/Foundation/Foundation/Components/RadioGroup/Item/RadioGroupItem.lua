local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

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

local useRadioGroupItemVariants = require(script.Parent.useRadioGroupItemVariants)
type RadioItemState = useRadioGroupItemVariants.RadioItemState

local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize
local InputLabelSize = require(Foundation.Enums.InputLabelSize)
type InputLabelSize = InputLabelSize.InputLabelSize

local ControlState = require(Foundation.Enums.ControlState)
type ControlState = ControlState.ControlState

local CursorType = require(Foundation.Enums.CursorType)
type CursorType = CursorType.CursorType

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

	local tokens = useTokens()
	local cursor = useCursor({
		radius = UDim.new(0, tokens.Radius.Small),
		offset = tokens.Size.Size_200,
		borderWidth = tokens.Stroke.Thicker,
	})

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

	local radioGroupItem = React.createElement(View, {
		Size = variantProps.radioItem.size,
		LayoutOrder = 1,
		stroke = {
			Color = variantProps.radioItem.stroke.Color3,
			Transparency = variantProps.radioItem.stroke.Transparency,
		},
		tag = variantProps.radioItem.tag,
	}, {
		Center = if isChecked
			then React.createElement(View, {
				tag = variantProps.checkmark.tag,
			})
			else nil,
	})

	--[[
		Labels for radio buttons and radio itemss should be positioned after the field.
		Source: https://www.w3.org/TR/WCAG20-TECHS/G162.html
	]]
	return React.createElement(
		View,
		withCommonProps(props, {
			Active = not isDisabled,
			GroupTransparency = if isDisabled then 0.5 else 0,
			isDisabled = isDisabled,
			onActivated = onActivated,
			onStateChanged = onInputStateChanged,
			selection = {
				Selectable = not isDisabled,
				SelectionImageObject = cursor,
			},
			stateLayer = { affordance = StateLayerAffordance.None },
			-- Add padding around radio item to ensure it's not cut off
			-- by the bounds of the canvas group
			padding = variantProps.container.padding,
			tag = variantProps.container.tag,
			ref = ref,
		}),
		{
			RadioGroupItem = radioGroupItem,
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
