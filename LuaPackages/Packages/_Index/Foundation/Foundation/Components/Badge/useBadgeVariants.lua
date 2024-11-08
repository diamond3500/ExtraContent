local Foundation = script:FindFirstAncestor("Foundation")

local BadgeVariant = require(Foundation.Enums.BadgeVariant)
type BadgeVariant = BadgeVariant.BadgeVariant
local BadgeSize = require(Foundation.Enums.BadgeSize)
type BadgeSize = BadgeSize.BadgeSize

local useTokens = require(Foundation.Providers.Style.useTokens)

local Types = require(Foundation.Components.Types)
type ColorStyleValue = Types.ColorStyleValue
type SizeConstraint = Types.SizeConstraint

type BadgeStyle = {
	backgroundStyle: ColorStyleValue,
	contentStyle: ColorStyleValue,
}

local function containerPadding(size, hasText, hasIcon): (string, string)
	local horizontalPadding = ""
	local verticalPadding = ""

	if hasIcon then
		verticalPadding = "padding-y-xxsmall"
		horizontalPadding ..= " padding-left-xxsmall"

		if not hasText then
			horizontalPadding ..= " padding-right-xxsmall"
		end
	end

	return horizontalPadding, verticalPadding
end

local textStyle = {
	[BadgeSize.Small] = "text-caption-small",
	[BadgeSize.Medium] = "text-label-small",
}

return function(
	variant: BadgeVariant,
	size: BadgeSize,
	hasIcon: boolean,
	hasText: boolean
): (BadgeStyle, SizeConstraint, SizeConstraint, string, string)
	local tokens = useTokens()

	local badgeVariants: { [BadgeVariant]: BadgeStyle } = {
		[BadgeVariant.Primary] = {
			backgroundStyle = tokens.Color.System.Contrast,
			contentStyle = tokens.Inverse.Content.Emphasis,
		},
		[BadgeVariant.Secondary] = {
			backgroundStyle = tokens.Color.Shift.Shift_200,
			contentStyle = tokens.Color.Content.Emphasis,
		},
		[BadgeVariant.Alert] = {
			backgroundStyle = tokens.Color.System.Alert,
			contentStyle = tokens.DarkMode.Content.Emphasis,
		},
	}

	local minSize = {
		[BadgeSize.Small] = tokens.Typography.CaptionSmall.FontSize,
		[BadgeSize.Medium] = tokens.Typography.LabelSmall.FontSize,
	}

	local horizontalPadding, verticalPadding = containerPadding(size, hasText, hasIcon)

	local textPadding = "padding-x-xsmall"
	local fontStyle = textStyle[size]

	-- Necessary to ensure that the ... fits inside badge
	local maxSize = if hasIcon
		then Vector2.new(
			tokens.Size.Size_1600
				- tokens.Semantic.Icon.Size.Small -- TODO(tokens): replace with non-semantic value
				- tokens.Padding.XXSmall,
			math.huge
		)
		else nil

	local textSizeConstraint = {
		MaxSize = maxSize,
	}

	local containerMinSize = if hasText then minSize[size] else tokens.Size.Size_200

	local containerSizeConstraint = {
		MinSize = Vector2.new(containerMinSize, containerMinSize),
		MaxSize = Vector2.new(tokens.Size.Size_1600, math.huge),
	}

	local containerTags =
		`auto-xy radius-circle row align-y-center align-x-center stroke-thick {horizontalPadding} {verticalPadding}`
	local textTags = `auto-xy text-truncate-end {textPadding} {fontStyle}`

	return badgeVariants[variant], containerSizeConstraint, textSizeConstraint, containerTags, textTags
end
