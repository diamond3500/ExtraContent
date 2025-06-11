local Root = script.Parent.Parent

local PurchaseError = require(Root.Enums.PurchaseError)

local KeyMappings = {}

KeyMappings.AssetTypeById = {
	--[[
		This key is a special case; developer products only exist
		within the context of a game, so they're localized with the
		rest of the purchase prompt strings.
	]]
	["0"] = "CoreScripts.PurchasePrompt.ProductType.Product",

	--[[
		The rest of these are asset types associated with Roblox
		assets that exist outside of games, mostly related to
		avatar customization
	]]
	["2"] = "Common.AssetTypes.Label.TShirt",
	["3"] = "Common.AssetTypes.Label.Audio",
	["4"] = "Common.AssetTypes.Label.Mesh",
	["8"] = "Common.AssetTypes.Label.Hat",
	["9"] = "Common.AssetTypes.Label.Place",
	["10"] = "Common.AssetTypes.Label.Model",
	["11"] = "Common.AssetTypes.Label.Shirt",
	["12"] = "Common.AssetTypes.Label.Pants",
	["13"] = "Common.AssetTypes.Label.Decal",
	["17"] = "Common.AssetTypes.Label.Head",
	["18"] = "Common.AssetTypes.Label.Face",
	["19"] = "Common.AssetTypes.Label.Gear",
	["21"] = "Common.AssetTypes.Label.Badge",
	["24"] = "Common.AssetTypes.Label.Animation",
	["27"] = "Common.AssetTypes.Label.Torso",
	["28"] = "Common.AssetTypes.Label.RightArm",
	["29"] = "Common.AssetTypes.Label.LeftArm",
	["30"] = "Common.AssetTypes.Label.LeftLeg",
	["31"] = "Common.AssetTypes.Label.RightLeg",
	["32"] = "Common.AssetTypes.Label.Package",
	["34"] = "Common.AssetTypes.Label.GamePass",
	["38"] = "Common.AssetTypes.Label.Plugin",
	["40"] = "Common.AssetTypes.Label.MeshPart",
	["41"] = "Common.AssetTypes.Label.Hair",
	["42"] = "Common.AssetTypes.Label.Face",
	["43"] = "Common.AssetTypes.Label.Neck",
	["44"] = "Common.AssetTypes.Label.Shoulder",
	["45"] = "Common.AssetTypes.Label.Front",
	["46"] = "Common.AssetTypes.Label.Back",
	["47"] = "Common.AssetTypes.Label.Waist",
	["48"] = "Common.AssetTypes.Label.Climb",
	["49"] = "Common.AssetTypes.Label.Death",
	["50"] = "Common.AssetTypes.Label.Fall",
	["51"] = "Common.AssetTypes.Label.Idle",
	["52"] = "Common.AssetTypes.Label.Jump",
	["53"] = "Common.AssetTypes.Label.Run",
	["54"] = "Common.AssetTypes.Label.Swim",
	["55"] = "Common.AssetTypes.Label.Walk",
	["56"] = "Common.AssetTypes.Label.Pose",
	["61"] = "Common.AssetTypes.Label.Emote",
}

KeyMappings.PurchaseErrorKey = {
	[PurchaseError.CannotGetBalance] = "CoreScripts.PurchasePrompt.PurchaseFailed.CannotGetBalance",
	[PurchaseError.CannotGetItemPrice] = "CoreScripts.PurchasePrompt.PurchaseFailed.CannotGetItemPrice",
	[PurchaseError.NotForSale] = "CoreScripts.PurchasePrompt.PurchaseFailed.NotForSale",
	[PurchaseError.NotForSaleHere] = "CoreScripts.PurchasePrompt.PurchaseFailed.NotForSaleHere",
	[PurchaseError.AlreadyOwn] = "CoreScripts.PurchasePrompt.PurchaseFailed.AlreadyOwn",
	[PurchaseError.Under13] = "CoreScripts.PurchasePrompt.PurchaseFailed.Under13",
	[PurchaseError.Limited] = "CoreScripts.PurchasePrompt.PurchaseFailed.Limited",
	[PurchaseError.Guest] = "CoreScripts.PurchasePrompt.PurchaseFailed.PromptPurchaseOnGuest",
	[PurchaseError.ThirdPartyDisabled] = "CoreScripts.PurchasePrompt.PurchaseFailed.ThirdPartyDisabled",
	[PurchaseError.NotEnoughRobux] = "CoreScripts.PurchasePrompt.PurchaseFailed.NotEnoughRobux",
	[PurchaseError.NotEnoughRobuxXbox] = "CoreScripts.PurchasePrompt.PurchaseFailed.NotEnoughRobuxXbox",
	[PurchaseError.NotEnoughRobuxNoUpsell] = "CoreScripts.PurchasePrompt.PurchaseFailed.NotEnoughRobuxNoUpsell",
	[PurchaseError.TwoFactorNeeded] = "CoreScripts.PurchasePrompt.PurchaseFailed.Enable2SV",
	[PurchaseError.TwoFactorNeededSettings] = "CoreScripts.PurchasePrompt.PurchaseFailed.Enable2SV",
	[PurchaseError.UnknownFailure] = "CoreScripts.PurchasePrompt.PurchaseFailed.UnknownFailure",
	[PurchaseError.UnknownFailureNoItemName] = "CoreScripts.PurchasePrompt.PurchaseFailed.UnknownFailureNoItemName",
	[PurchaseError.PurchaseDisabled] = "CoreScripts.PurchasePrompt.PurchaseFailed.PurchaseDisabled",
	[PurchaseError.InvalidFunds] = "CoreScripts.PurchasePrompt.PurchaseFailed.InvalidFunds",
	[PurchaseError.InvalidFundsUnknown] = "CoreScripts.PurchasePrompt.PurchaseFailed.InvalidFunds",
	[PurchaseError.PremiumOnly] = "CoreScripts.PurchasePrompt.PurchaseFailed.PremiumOnly",
}

return KeyMappings
