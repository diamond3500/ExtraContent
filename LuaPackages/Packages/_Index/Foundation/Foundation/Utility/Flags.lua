--!nolint ImportUnused
local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local SafeFlags = require(Packages.SafeFlags)

-- Define all flags within this Flags table
-- Example:
-- 	MyFastFlag = SafeFlags.createGetFFlag("MyFastFlag")(), <-- Make sure to call the function to get the value
return {
	FoundationStylingPolyfill = SafeFlags.createGetFFlag("FoundationStylingPolyfill")(),
	FoundationDisableBadgeTruncation = SafeFlags.createGetFFlag("FoundationDisableBadgeTruncation")(),
	FoundationMigrateStylingV2 = SafeFlags.createGetFFlag("FoundationMigrateStylingV2")(),
	FoundationTextStateLayer = SafeFlags.createGetFFlag("FoundationTextStateLayer")(),
	FoundationFixChipEmphasisHoverState = SafeFlags.createGetFFlag("FoundationFixChipEmphasisHoverState")(),
	FoundationFixDisablingForIconButtons = SafeFlags.createGetFFlag("FoundationFixDisablingForIconButtons")(),
	FoundationFixUseFloatingContentSize = SafeFlags.createGetFFlag("FoundationFixUseFloatingContentSize")(),
	FoundationAdjustButtonIconSizes = SafeFlags.createGetFFlag("FoundationAdjustButtonIconSizes2")(),
	FoundationFixBackgroundForStylingV2 = SafeFlags.createGetFFlag("FoundationFixBackgroundForStylingV2")(),
	FoundationRefactorInputs = SafeFlags.createGetFFlag("FoundationRefactorInputs")(),
}
