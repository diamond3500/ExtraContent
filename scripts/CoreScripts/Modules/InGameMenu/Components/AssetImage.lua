--[[
	Displays an image from the asset dictionary, slicing it if the asset
	requires that.
]]

local CorePackages = game:GetService("CorePackages")

local InGameMenuDependencies = require(CorePackages.Packages.InGameMenuDependencies)
local Roact = InGameMenuDependencies.Roact
local Cryo = InGameMenuDependencies.Cryo
local UIBlox = InGameMenuDependencies.UIBlox

local InGameMenu = script.Parent.Parent

local ImageSetLabel = UIBlox.Core.ImageSet.ImageSetLabel
local ImageSetButton = UIBlox.Core.ImageSet.ImageSetButton

local Assets = require(InGameMenu.Resources.Assets)

local function makeAssetImageComponent(component)
	return Roact.forwardRef(function(props, ref)
		local imageKey = props.imageKey
		local imageData = Assets.Images[imageKey]

		local imageProps
		if typeof(imageData) == "string" then
			imageProps = {
				Image = imageData,
			}
		else
			imageProps = imageData
		end

		local mergedProps = Cryo.Dictionary.join(
			props,
			{
				imageKey = Cryo.None,
			},
			imageProps,
			{
				BackgroundTransparency = 1,
			}
		)

		return Roact.createElement(
			component,
			Cryo.Dictionary.join(mergedProps, {
				[Roact.Ref] = ref,
			})
		)
	end)
end

return {
	Label = makeAssetImageComponent(ImageSetLabel),
	Button = makeAssetImageComponent(ImageSetButton),
}
