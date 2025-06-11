local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local Otter = require(Packages.Otter)
local React = require(Packages.React)
local Cryo = require(Packages.Cryo)

local Components = Foundation.Components
local InputLabel = require(Components.InputLabel)
local View = require(Components.View)
local Types = require(Components.Types)
local Knob = require(Components.Knob)

local useCursor = require(Foundation.Providers.Cursor.useCursor)
local useTokens = require(Foundation.Providers.Style.useTokens)
local withCommonProps = require(Foundation.Utility.withCommonProps)
local withDefaults = require(Foundation.Utility.withDefaults)
local getInputTextSize = require(Foundation.Utility.getInputTextSize)

local lerp = require(Foundation.Utility.lerp)
local StateLayerAffordance = require(Foundation.Enums.StateLayerAffordance)
local ControlState = require(Foundation.Enums.ControlState)
type ControlState = ControlState.ControlState

local useToggleVariants = require(script.Parent.useToggleVariants_DEPRECATED)

local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

local InputLabelSize = require(Foundation.Enums.InputLabelSize)
type InputLabelSize = InputLabelSize.InputLabelSize

local DISABLED_TRANSPARENCY = 0.5
local SPRING_PARAMETERS = {
	frequency = 4,
}

type Props = {
	-- Whether the toggle is currently checked (i.e. on). If it is left `nil`,
	-- the toggle will be considered uncontrolled.
	isChecked: boolean?,
	-- Whether the toggle is disabled. When `true`, the `onActivated` callback
	-- will not be invoked, even if the user interacts with the toggle.
	isDisabled: boolean?,
	-- A function that will be called whenever the toggle is activated.
	-- Returns the new value of the toggle when uncontrolled.
	onActivated: (boolean) -> (),
	-- A label for the toggle. To omit, set it to an empty string.
	label: string,
	size: InputSize?,
} & Types.CommonProps

local defaultProps = {
	size = InputSize.Medium,
}

local function Toggle(toggleProps: Props, ref: React.Ref<GuiObject>?)
	local props = withDefaults(toggleProps, defaultProps)
	local tokens = useTokens()
	local variantProps = useToggleVariants(tokens, props.size)

	local isChecked, setIsChecked = React.useState(props.isChecked or false)
	React.useEffect(function()
		if props.isChecked ~= nil then
			setIsChecked(props.isChecked)
		end
	end, { props.isChecked })

	local hasLabel = #props.label > 0
	local cursorConfig = React.useMemo(function()
		local radius = if hasLabel then UDim.new(0, tokens.Radius.Small) else UDim.new(0.5, 0)
		return {
			radius = radius,
			offset = tokens.Size.Size_200,
			borderWidth = tokens.Stroke.Thicker,
		}
	end, { tokens :: any, hasLabel })
	local cursor = useCursor(cursorConfig)

	local initialProgress = isChecked and 1 or 0
	local isHovering, setIsHovering = React.useBinding(false)
	local progress, setProgress = React.useBinding(initialProgress)
	local progressMotorRef = React.useRef(nil :: Otter.SingleMotor?)

	local knobTheme = tokens.Color.ActionEmphasis.Background

	local getLabelStyle = React.useCallback(function(isHovering)
		if isHovering and not props.isDisabled then
			return tokens.Color.Content.Emphasis
		end
		return tokens.Color.Content.Default
	end, { tokens :: any, props.isDisabled })

	-- We need to fade the track outline out when the toggle is checked, because
	-- otherwise it creates a visually jarring border around the filled track.
	local trackColor = isHovering:map(function(value)
		local trackTheme = if isChecked then knobTheme else getLabelStyle(value)
		return {
			Color3 = trackTheme.Color3,
			Transparency = trackTheme.Transparency,
		}
	end)

	local fillColor = progress:map(function(value)
		return {
			Color3 = knobTheme.Color3,
			Transparency = lerp(1, knobTheme.Transparency, value),
		}
	end)

	local knobPosition = progress:map(function(value)
		return variantProps.knob.offPosition:Lerp(variantProps.knob.onPosition, value)
	end)

	React.useEffect(function()
		local progressMotor = Otter.createSingleMotor(initialProgress)
		progressMotorRef.current = progressMotor
		progressMotor:start()

		progressMotor:onStep(function(newValue)
			setProgress(newValue)
		end)

		return function()
			progressMotor:destroy()
		end
	end, {})

	local onInputStateChanged = React.useCallback(function(newState: ControlState)
		setIsHovering(newState == ControlState.Hover)
	end, {})

	React.useEffect(function()
		local newProgress = if isChecked then 1 else 0
		if progressMotorRef.current then
			progressMotorRef.current:setGoal(Otter.spring(newProgress, SPRING_PARAMETERS))
		end
	end, { isChecked })

	local onActivated = React.useCallback(function()
		if not props.isDisabled then
			if props.isChecked == nil then
				setIsChecked(not isChecked)
			end
			props.onActivated(not isChecked)
		end
	end, { props.onActivated :: any, props.isChecked, isChecked, props.isDisabled, setIsChecked })

	local interactionProps = {
		Active = not props.isDisabled,
		GroupTransparency = if props.isDisabled then DISABLED_TRANSPARENCY else 0,
		onActivated = onActivated,
		onStateChanged = onInputStateChanged,
		stateLayer = { affordance = StateLayerAffordance.None },
		selection = {
			Selectable = not props.isDisabled,
			SelectionImageObject = cursor,
		},
		isDisabled = props.isDisabled,
		ref = ref,
	}

	local toggleContainerProps = {
		Size = variantProps.toggle.size,
		stroke = {
			Color = trackColor:map(function(value)
				return value.Color3
			end),
			Transparency = trackColor:map(function(value)
				return if props.isDisabled and not hasLabel then DISABLED_TRANSPARENCY else value.Transparency
			end),
			Thickness = tokens.Stroke.Standard,
		},
		cornerRadius = variantProps.toggle.cornerRadius,
		backgroundStyle = fillColor,
	}

	local toggle = React.createElement(
		View,
		if hasLabel
			then toggleContainerProps
			else withCommonProps(props, Cryo.Dictionary.union(toggleContainerProps, interactionProps)),
		{
			Knob = React.createElement(Knob, {
				size = props.size,
				isDisabled = props.isDisabled,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = knobPosition,
			}),
		}
	)

	if not hasLabel then
		return toggle
	end

	return React.createElement(
		View,
		withCommonProps(
			props,
			Cryo.Dictionary.union({
				-- Add padding around toggle container to ensure it's not cut off
				-- by the bounds of the canvas group
				padding = {
					top = UDim.new(0, tokens.Stroke.Standard),
					bottom = UDim.new(0, tokens.Stroke.Standard),
					right = UDim.new(0, tokens.Stroke.Standard),
				},
				tag = "row gap-small auto-xy align-x-left align-y-center",
			}, interactionProps)
		),
		{
			InputLabel = React.createElement(InputLabel, {
				Text = props.label,
				textStyle = isHovering:map(getLabelStyle),
				size = getInputTextSize(props.size, true),
				LayoutOrder = 0,
			}),
			Toggle = toggle,
		}
	)
end

return React.memo(React.forwardRef(Toggle))
