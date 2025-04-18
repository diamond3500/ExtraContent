local Root = script.Parent.Parent.Parent

local CorePackages = game:GetService("CorePackages")

local PurchasePromptDeps = require(CorePackages.Workspace.Packages.PurchasePromptDeps)
local Roact = PurchasePromptDeps.Roact
local t = PurchasePromptDeps.t

local LocalizationService = require(Root.Localization.LocalizationService)

local LocalizationContextConsumer = require(script.Parent.LocalizationContextConsumer)

local validateProps = t.strictInterface({
	locKeys = t.table,
	render = t.callback,
})

local validateItem = t.strictInterface({
	key = t.string,
	params = t.optional(t.table),
})

local function MultiTextLocalizer(props)
	assert(validateProps(props))
	for _, item in pairs(props.locKeys) do
		assert(validateItem(item))
	end

	local render = props.render

	return Roact.createElement(LocalizationContextConsumer, {
		render = function(localizationContext)
			local textMap = {}
			for key, item in pairs(props.locKeys) do
				textMap[key] = LocalizationService.getString(localizationContext, item.key, item.params)
			end
			return render(textMap)
		end,
	})
end

return MultiTextLocalizer
