--[[
	SummedAreaTable.lua is an implementation of the summed area table data structure.
	It allows O(1) time calculation of the sum of elements in a rectangular region of a grid.
	Both ImageReadWrapper and SummedAreaTable expect zero indexed coordinates in functions 
	that take coordinates.
]]

local COLOR3_BYTE_STRIDE = 4

type ImageReadWrapperMembers = {
	size: Vector2,
	buffer: buffer,
}

local ImageReadWrapper = {}
ImageReadWrapper.__index = ImageReadWrapper

export type ImageReadWrapper = typeof(setmetatable({} :: ImageReadWrapperMembers, ImageReadWrapper))

-- Zero indexed
function ImageReadWrapper.ReadPixel(self, x: number, y: number): Color3
	if x >= self.size.X or y >= self.size.Y or x < 0 or y < 0 then
		return Color3.fromRGB(0.0, 0.0, 0.0)
	end

	local pixelIndex = x + y * self.size.X
	local pixelOffset = pixelIndex * COLOR3_BYTE_STRIDE
	return Color3.fromRGB(
		buffer.readu8(self.buffer, pixelOffset),
		buffer.readu8(self.buffer, pixelOffset + 1),
		buffer.readu8(self.buffer, pixelOffset + 2)
	)
end

function ImageReadWrapper.new(editableImage: EditableImage): ImageReadWrapper
	local imageReadWrapper = setmetatable({} :: ImageReadWrapperMembers, ImageReadWrapper)
	imageReadWrapper.buffer = editableImage:ReadPixelsBuffer(Vector2.new(0, 0), editableImage.Size)
	imageReadWrapper.size = editableImage.Size
	return imageReadWrapper
end

type SummedAreaTableMembers = { size: Vector2, calculateWeightFromColor3: (Color3) -> number, buffer: buffer }

local SummedAreaTable = {}
SummedAreaTable.__index = SummedAreaTable

export type SummedAreaTable = typeof(setmetatable({} :: SummedAreaTableMembers, SummedAreaTable))

--calculateWeightFromColor3 is a function that defines the value at each cell of the table
--used to build the summed area table
function SummedAreaTable.new(size: Vector2, calculateWeightFromColor3: (Color3) -> number): SummedAreaTable
	local summedAreaTable = setmetatable({} :: SummedAreaTableMembers, SummedAreaTable)
	summedAreaTable.size = size
	summedAreaTable.calculateWeightFromColor3 = calculateWeightFromColor3
	summedAreaTable.buffer = buffer.create(size.X * size.Y * COLOR3_BYTE_STRIDE)
	return summedAreaTable
end

-- Zero indexed coordinates, out of bounds access mimics an infinitely large table
function SummedAreaTable.ReadValue(self: SummedAreaTable, x: number, y: number): number
	if x < 0 or y < 0 then
		return 0
	end
	x = math.min(x, self.size.X - 1)
	y = math.min(y, self.size.Y - 1)

	local index = x + y * self.size.X
	return buffer.readu32(self.buffer, index * COLOR3_BYTE_STRIDE)
end

function SummedAreaTable.WriteValue(self: SummedAreaTable, x: number, y: number, value)
	assert(x < self.size.X and y < self.size.Y and x >= 0 and y >= 0)

	local index = x + y * self.size.X
	buffer.writeu32(self.buffer, index * COLOR3_BYTE_STRIDE, value)
end

function SummedAreaTable.BuildSummedAreaTable(self: SummedAreaTable, editableImage: EditableImage)
	local imageWrapper = ImageReadWrapper.new(editableImage)

	assert(imageWrapper.size == self.size)
	for y = 0, self.size.Y - 1 do
		for x = 0, self.size.X - 1 do
			local center = self.calculateWeightFromColor3(imageWrapper:ReadPixel(x, y))
			local left = self:ReadValue(x - 1, y)
			local up = self:ReadValue(x, y - 1)
			local upperLeft = self:ReadValue(x - 1, y - 1)
			local weight = center + left + up - upperLeft
			self:WriteValue(x, y, weight)
		end
	end
end

-- areaStart and areaSize define the rectangular block of elements you want to find the sum of
-- areaStart is zero indexed
function SummedAreaTable.GetAreaDensity(self: SummedAreaTable, areaStart: Vector2, areaSize: Vector2): number
	local upperLeftCoord = areaStart - Vector2.one
	local lowerRightCoord = areaStart + areaSize - Vector2.one
	local upperRightCoord = Vector2.new(lowerRightCoord.X, upperLeftCoord.Y)
	local lowerLeftCoord = Vector2.new(upperLeftCoord.X, lowerRightCoord.Y)

	return self:ReadValue(lowerRightCoord.X, lowerRightCoord.Y)
		- self:ReadValue(upperRightCoord.X, upperRightCoord.Y)
		- self:ReadValue(lowerLeftCoord.X, lowerLeftCoord.Y)
		+ self:ReadValue(upperLeftCoord.X, upperLeftCoord.Y)
end

return SummedAreaTable
