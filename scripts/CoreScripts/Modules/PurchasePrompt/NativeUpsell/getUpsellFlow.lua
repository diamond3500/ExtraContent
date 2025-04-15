local Root = script.Parent.Parent
local CorePackages = game:GetService("CorePackages")

local UpsellFlow = require(Root.Enums.UpsellFlow)
local UniversalAppPolicy = require(CorePackages.Workspace.Packages.UniversalAppPolicy)
local getAppFeaturePolicies = UniversalAppPolicy.getAppFeaturePolicies

local GetFFlagEnablePalisadesPaymentsPlatform = require(Root.Flags.GetFFlagEnablePalisadesPaymentsPlatform)
local FFlagUseMobileRobuxUpsellFlowForPCGDK = require(CorePackages.Workspace.Packages.SharedFlags).FFlagUseMobileRobuxUpsellFlowForPCGDK

local function getUpsellFlow(platform)
	if FFlagUseMobileRobuxUpsellFlowForPCGDK and getAppFeaturePolicies().getRobuxUpsellFlowMobile() then
		return UpsellFlow.Mobile
	end

	if platform == Enum.Platform.Windows or platform == Enum.Platform.OSX or platform == Enum.Platform.Linux then
		return UpsellFlow.Web
	elseif platform == Enum.Platform.IOS or platform == Enum.Platform.Android or platform == Enum.Platform.UWP then
		return UpsellFlow.Mobile
	elseif platform == Enum.Platform.XBoxOne then
		return UpsellFlow.Xbox
	elseif GetFFlagEnablePalisadesPaymentsPlatform() and platform == Enum.Platform.PS4 then
		return UpsellFlow.Mobile
	end

	return UpsellFlow.None
end

return getUpsellFlow
