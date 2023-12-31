local Loading = script.Parent
local App = Loading.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)
local t = require(Packages.t)

local Images = require(UIBlox.App.ImageSet.Images)

local SpinningImage = require(UIBlox.Core.Animation.SpinningImage)

local LoadingSpinner = Roact.PureComponent:extend("LoadingSpinner")

LoadingSpinner.validateProps = t.strictInterface({
	size = t.optional(t.UDim2),
	-- The position of the spinner
	position = t.optional(t.union(t.UDim2, t.table)),
	-- The anchor point of the spinner
	anchorPoint = t.optional(t.Vector2),
	-- The rotation rate of the spinner, in degrees	per second.
	-- Positive numbers are clockwise, negative numbers are counterclockwise.
	rotationRate = t.optional(t.number),
})

function LoadingSpinner:render()
	return Roact.createElement(SpinningImage, {
		image = Images["icons/graphic/loadingspinner"],
		size = self.props.size,
		position = self.props.position,
		anchorPoint = self.props.anchorPoint,
		rotationRate = self.props.rotationRate,
	})
end

return LoadingSpinner
