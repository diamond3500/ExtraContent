local PublicBindables = {}

export type Bindables = {
	windowStateChangedBindable: BindableEvent,
}

function PublicBindables.new(bindables: Bindables)
	local service = {}

	setmetatable(service, {
		__tostring = function()
			return "Service(PublicBindables)"
		end,
	})

	function service.getWindowStateChangedBindable()
		return bindables.windowStateChangedBindable
	end

	return service
end

return PublicBindables
