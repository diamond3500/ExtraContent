local Icon = require(script.Icon)
export type Icon = Icon.Icon
local IconVariant = require(script.IconVariant)
export type IconVariant = IconVariant.IconVariant
local Font = require(script.Font)

return {
  Icon = Icon,
  IconVariant = IconVariant,
  Font = Font
}
