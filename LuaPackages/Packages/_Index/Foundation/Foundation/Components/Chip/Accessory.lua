local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local useTokens = require(Foundation.Providers.Style.useTokens)
local Image = require(Foundation.Components.Image)
local View = require(Foundation.Components.View)
local StateLayerAffordance = require(Foundation.Enums.StateLayerAffordance)

local useAccessoryVariants = require(script.Parent.useAccessoryVariants)

local ChipSize = require(Foundation.Enums.ChipSize)
type ChipSize = ChipSize.ChipSize

type AccessoryProps = {
	isLeading: boolean,
	config: string | Accessory,
	size: ChipSize,
	contentStyle: any,
}

export type Accessory = {
	iconName: string,
	isCircular: boolean?,
	onActivated: (() -> ())?,
}

local function Accessory(accessoryProps: AccessoryProps)
	local tokens = useTokens()
	local fullConfig: Accessory = React.useMemo(function()
		if type(accessoryProps.config) == "string" then
			return {
				iconName = accessoryProps.config,
				isCircular = false :: boolean?,
			}
		else
			return accessoryProps.config
		end
	end, { accessoryProps.config })

	local variants =
		useAccessoryVariants(tokens, accessoryProps.size, accessoryProps.isLeading, fullConfig.isCircular or false)

	return React.createElement(
		View,
		{
			tag = "auto-xy",
			padding = variants.accessory.padding,
			onActivated = fullConfig.onActivated,
			LayoutOrder = if accessoryProps.isLeading then 1 else 3,
		},
		React.createElement(Image, {
			Image = fullConfig.iconName,
			Size = variants.accessory.Size,
			imageStyle = accessoryProps.contentStyle,
			stateLayer = { affordance = StateLayerAffordance.None },
		})
	)
end

return React.memo(Accessory)
