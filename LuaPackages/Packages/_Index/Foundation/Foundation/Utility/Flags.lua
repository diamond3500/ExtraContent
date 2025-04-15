--!nolint ImportUnused
local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local SafeFlags = require(Packages.SafeFlags)

-- Define all flags within this Flags table
-- Example:
-- 	MyFastFlag = SafeFlags.createGetFFlag("MyFastFlag")(), <-- Make sure to call the function to get the value
return {
	FoundationInteractableUseGuiState = SafeFlags.createGetFFlag("FoundationInteractableUseGuiState")(),
	FoundationStylingPolyfill = SafeFlags.createGetFFlag("FoundationStylingPolyfill")(),
	FoundationFixSupportImageBinding = SafeFlags.createGetFFlag("FoundationFixSupportImageBinding")(),
	FoundationDisableBadgeTruncation = SafeFlags.createGetFFlag("FoundationDisableBadgeTruncation")(),
	FoundationButtonEnableLoadingState = SafeFlags.createGetFFlag("FoundationButtonEnableLoadingState")(),
	FoundationEnableNewButtonSizes = SafeFlags.createGetFFlag("FoundationEnableNewButtonSizes")(),
	FoundationStyleSheetContext = SafeFlags.createGetFFlag("FoundationStyleSheetContext")(),
	FoundationMigrateStylingV2 = SafeFlags.createGetFFlag("FoundationMigrateStylingV2")(),
	FoundationTextStateLayer = SafeFlags.createGetFFlag("FoundationTextStateLayer")(),
	FoundationFixChipEmphasisHoverState = SafeFlags.createGetFFlag("FoundationFixChipEmphasisHoverState")(),
	FoundationFixDisablingForIconButtons = SafeFlags.createGetFFlag("FoundationFixDisablingForIconButtons")(),
	FoundationIconButtonCanBeCircular = SafeFlags.createGetFFlag("FoundationIconButtonCanBeCircular")(),
}
