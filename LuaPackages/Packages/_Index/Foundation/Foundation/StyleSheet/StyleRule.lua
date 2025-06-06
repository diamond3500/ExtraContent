local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local React = require(Packages.React)
local Flags = require(Foundation.Utility.Flags)

type StyleRuleProps = {
	Priority: number?,
	Selector: string,
	properties: {
		[string]: any,
	},
}

local function StyleRule(props: StyleRuleProps)
	local rule = React.useCallback(function(node)
		if node ~= nil then
			node:SetProperties(props.properties)
		end
	end, { props.properties })

	return React.createElement("StyleRule", {
		Priority = if Flags.FoundationMigrateStylingV2 then props.Priority or 1 else nil, -- 0 reserved for default styles
		Selector = props.Selector,
		ref = rule,
	})
end

return React.memo(StyleRule)
