local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local function renderFade(rotation: number, transparency: number)
	return React.createElement("UIGradient", {
		Rotation = rotation,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1 - transparency),
			NumberSequenceKeypoint.new(0.5, transparency),
			NumberSequenceKeypoint.new(1, transparency),
		}),
	})
end

return renderFade
