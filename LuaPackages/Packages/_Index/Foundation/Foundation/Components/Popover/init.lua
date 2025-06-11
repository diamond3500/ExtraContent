local Anchor = require(script.Anchor)

export type PopoverAnchorProps = Anchor.PopoverAnchorProps

return {
	Root = require(script.Popover),
	Anchor = Anchor,
	Content = require(script.Content),
}
