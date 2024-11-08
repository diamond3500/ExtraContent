local AnalyticsService = game:GetService("RbxAnalyticsService")

local Analytics = {
	Section = {
		BuyCreationPage = "buy_creation_page",
		BuyItemModal = "buy_item_modal",
		ProcessCompleteModal = "process_complete_modal",
	},

	Action = {
		FieldTouched = "field_touched",
		ButtonClicked = "button_clicked",
		PageLoad = "page_load",
	},

	Element = {
		Name = "name",
		Description = "description",
		X = "x",
		Expand = "expand",
		Buy = "buy",
		Cancel = "cancel",
	},
}

local function sendEvent(section: string, action: string, element: string?)
	AnalyticsService:SendEventDeferred("client", "publish_avatar_prompt", "iec_funnel_user_creation", {
		section = section,
		action = action,
		element = element,
	})
end

function Analytics.sendPageLoad(section)
	sendEvent(section, Analytics.Action.PageLoad)
end

function Analytics.sendFieldTouched(section, element)
	sendEvent(section, Analytics.Action.FieldTouched, element)
end

function Analytics.sendButtonClicked(section, element)
	sendEvent(section, Analytics.Action.ButtonClicked, element)
end

return Analytics
