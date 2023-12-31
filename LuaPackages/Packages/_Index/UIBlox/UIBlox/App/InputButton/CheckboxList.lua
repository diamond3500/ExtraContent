--!nonstrict
local Packages = script.Parent.Parent.Parent.Parent

local Roact = require(Packages.Roact)
local t = require(Packages.t)
local Cryo = require(Packages.Cryo)
local Checkbox = require(script.Parent.Checkbox)

local CheckboxList = Roact.PureComponent:extend("CheckboxList")

local validateButton = t.strictInterface({
	label = t.string,
	isSelected = t.optional(t.boolean),
	isDisabled = t.optional(t.boolean),
})

CheckboxList.validateProps = t.strictInterface({
	-- The options to the checkbox menu. Each string corresponds to one `checkbox`.
	-- You can either pass in a string value which defaults the checkbox to unchecked and clickable, or pass in `isSelected` and `isDisabled` to modify the checkbox accordingly.
	checkboxes = t.array(t.union(t.string, validateButton)),
	-- This function is called when a `checkbox` is clicked. The value passed in is the selection state of the button.
	onActivated = t.callback,
	-- This is the size of an individual `checkbox` component
	elementSize = t.UDim2,
	-- The maximum number of `checkbox`s that can be selected at any given time
	atMost = t.optional(t.number),
	-- The `layoutOrder` of this component, to be used in `UIListLayout`.
	layoutOrder = t.optional(t.number),
})

local function numTrue(truthTable)
	local num = 0
	for _, value in pairs(truthTable) do
		if value then
			num = num + 1
		end
	end

	return num
end

function CheckboxList:init()
	local atMost = self.props.atMost or #self.props.checkboxes

	local selectedIndices = {}
	local disabledIndices = {}

	for i, v in ipairs(self.props.checkboxes) do
		if type(v) == "table" then
			selectedIndices[i] = v.isSelected or false
			disabledIndices[i] = v.isDisabled or false
		end
	end

	assert(numTrue(selectedIndices) < atMost, "number of 'isSelected' must be less than atMost!")

	self.state = {
		selectedIndices = selectedIndices,
		disabledIndices = disabledIndices,
	}

	self.doLogic = function(key)
		self:setState({
			selectedIndices = Cryo.Dictionary.join(
				self.state.selectedIndices,
				{ [key] = not self.state.selectedIndices[key] and numTrue(self.state.selectedIndices) < atMost }
			),
		})
		self.props.onActivated(self.state.selectedIndices)
	end
end

function CheckboxList:render()
	local checkboxes = {}
	checkboxes.layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	for i, value in ipairs(self.props.checkboxes) do
		checkboxes["Checkbox" .. i] = Roact.createElement(Checkbox, {
			text = type(value) == "table" and value.label or value,
			isSelected = self.state.selectedIndices[i],
			isDisabled = self.state.disabledIndices[i],
			onActivated = function()
				self.doLogic(i)
			end,
			size = self.props.elementSize,
			layoutOrder = i,
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		LayoutOrder = self.props.layoutOrder,
	}, checkboxes)
end

return CheckboxList
