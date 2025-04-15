local React = require(script.Parent.Parent.React)
local Signals = require(script.Parent.Parent.Signals)

local function useSignalState<T>(getter: Signals.getter<T>): T
	local value, setValue = React.useState(getter(false))

	React.useLayoutEffect(function()
		setValue(getter(false))
		return Signals.createEffect(function(scope)
			setValue(getter(scope))
		end)
	end, { getter })

	return value
end

local function useSignalBinding<T>(getter: Signals.getter<T>): React.Binding<T>
	local binding, setBinding = React.useBinding(getter(false))

	React.useLayoutEffect(function()
		setBinding(getter(false))
		return Signals.createEffect(function(scope)
			setBinding(getter(scope))
		end)
	end, { getter })

	return binding
end

return {
	useSignalState = useSignalState,
	useSignalBinding = useSignalBinding,
}
