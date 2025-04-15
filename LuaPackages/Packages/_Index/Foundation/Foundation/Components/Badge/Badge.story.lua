local MarketplaceService = game:GetService("MarketplaceService")
local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local React = require(Packages.React)
local Dash = require(Packages.Dash)

local Tile = require(Foundation.Components.Tile)
local MediaType = require(Foundation.Enums.MediaType)
local Theme = require(Foundation.Enums.Theme)

local Badge = require(Foundation.Components.Badge)
local BadgeVariant = require(Foundation.Enums.BadgeVariant)
type BadgeVariant = BadgeVariant.BadgeVariant
local BadgeSize = require(Foundation.Enums.BadgeSize)

local useTokens = require(Foundation.Providers.Style.useTokens)
local Flags = require(Foundation.Utility.Flags)

local itemTileSize = UDim2.fromOffset(150, 240)
local itemId = 21070012

return {
	summary = "Badge",
	stories = Dash.map(BadgeVariant, function(variant)
		return {
			name = variant,
			story = function(props): React.Node
				Flags.FoundationDisableBadgeTruncation = props.controls.disableBadgeTruncation
				local tokens = useTokens()

				local item, setItem = React.useState({} :: { Name: string?, PriceText: string? })
				React.useEffect(function()
					setItem({})
					spawn(function()
						wait(2.0)
						local itemInfo = MarketplaceService:GetProductInfo(itemId)
						if itemInfo.IsPublicDomain then
							itemInfo.PriceInRobux = 0
							itemInfo.PriceText = "Free"
						else
							assert(itemInfo.PriceInRobux ~= nil, "Item price will not be nil")
							itemInfo.PriceText = "\u{E002}" .. tostring(itemInfo.PriceInRobux)
						end

						setItem(itemInfo)
					end)
				end, { itemId })

				if props.controls.onTile then
					return React.createElement(Tile.Root, {
						isContained = true,
						FillDirection = Enum.FillDirection.Vertical,
						Size = itemTileSize,
					}, {
						TileMedia = React.createElement(Tile.Media, {
							id = itemId,
							type = MediaType.Asset,
							aspectRatio = 1,
							background = {
								image = "component_assets/itemBG_"
									.. if tokens.Config.Theme.Name == Theme.Dark then "dark" else "light",
							},
						}, {
							UIListLayout = React.createElement("UIListLayout", {
								FillDirection = Enum.FillDirection.Vertical,
								HorizontalAlignment = Enum.HorizontalAlignment.Left,
								VerticalAlignment = Enum.VerticalAlignment.Bottom,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
							Badge = React.createElement(Badge, {
								text = props.controls.text,
								icon = if props.controls.icon ~= "" then props.controls.icon else nil,
								size = props.controls.size,
								isDisabled = props.controls.isDisabled,
								variant = variant,
							}),
						}),
						TileContent = React.createElement(Tile.Content, {}, {
							TileHeader = React.createElement(Tile.Header, {
								title = {
									text = item.Name,
									isLoading = item.Name == nil,
									fontStyle = tokens.Typography.HeadingSmall,
									numLines = 2,
								},
								subtitle = {
									text = item.PriceText,
									isLoading = item.PriceText == nil,
									fontStyle = tokens.Typography.BodyLarge,
									colorStyle = tokens.Color.Content.Muted,
								},
								spacing = tokens.Gap.Small,
							}),
						}),
					})
				end

				return React.createElement(Badge, {
					text = props.controls.text,
					icon = if props.controls.icon ~= "" then props.controls.icon else nil,
					size = props.controls.size,
					isDisabled = props.controls.isDisabled,
					variant = variant,
				})
			end,
		}
	end),
	controls = {
		text = "NEW",
		icon = {
			"icons/placeholder/placeholderOn_small",
			"icons/menu/clothing/limited_on",
			"",
		},
		size = Dash.values(BadgeSize),
		isDisabled = false,
		onTile = false,
		disableBadgeTruncation = Flags.FoundationDisableBadgeTruncation,
	},
}
