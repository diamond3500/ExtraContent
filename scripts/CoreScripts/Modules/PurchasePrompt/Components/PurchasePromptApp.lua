local Root = script.Parent.Parent

local CoreGui = game:GetService("CoreGui")
local LocalizationService = game:GetService("LocalizationService")
local CorePackages = game:GetService("CorePackages")
local PurchasePromptDeps = require(CorePackages.Workspace.Packages.PurchasePromptDeps)
local Roact = PurchasePromptDeps.Roact
local Rodux = PurchasePromptDeps.Rodux
local RoactRodux = PurchasePromptDeps.RoactRodux
local UIBlox = PurchasePromptDeps.UIBlox
local StyleProvider = UIBlox.Style.Provider
local IAPExperience = require(CorePackages.Workspace.Packages.IAPExperience)
local LocaleProvider = IAPExperience.Locale.LocaleProvider
local ToastLite = require(CorePackages.Workspace.Packages.ToastLite)
local Toast = ToastLite.Components.Toast

local RobloxGui = CoreGui:WaitForChild("RobloxGui")

local Reducer = require(Root.Reducers.Reducer)
local ABTest = require(Root.Services.ABTest)
local Network = require(Root.Services.Network)
local Analytics = require(Root.Services.Analytics)
local PlatformInterface = require(Root.Services.PlatformInterface)
local ExternalSettings = require(Root.Services.ExternalSettings)
local Thunk = require(Root.Thunk)

local EventConnections = require(script.Parent.Connection.EventConnections)
local LayoutValuesProvider = require(script.Parent.Connection.LayoutValuesProvider)
local provideRobloxLocale = require(script.Parent.Connection.provideRobloxLocale)
local PurchasePromptPolicy = require(Root.Components.Connection.PurchasePromptPolicy)

local ProductPurchaseContainer = require(script.Parent.ProductPurchase.ProductPurchaseContainer)
local RobuxUpsellContainer = require(script.Parent.RobuxUpsell.RobuxUpsellContainer)
local PremiumUpsellContainer = require(script.Parent.PremiumUpsell.PremiumUpsellContainer)
local SubscriptionPurchaseContainer = require(script.Parent.SubscriptionPurchase.SubscriptionPurchaseContainer)
local renderWithCoreScriptsStyleProvider =
	require(script.Parent.Parent.Parent.Common.renderWithCoreScriptsStyleProvider)

local SelectionCursorProvider = require(CorePackages.Packages.UIBlox).App.SelectionImage.SelectionCursorProvider
local ReactFocusNavigation = require(CorePackages.Packages.ReactFocusNavigation)
local focusNavigationService =
	ReactFocusNavigation.FocusNavigationService.new(ReactFocusNavigation.EngineInterface.CoreGui)
local FocusNavigationUtils = require(CorePackages.Workspace.Packages.FocusNavigationUtils)
local FocusNavigableSurfaceRegistry = FocusNavigationUtils.FocusNavigableSurfaceRegistry
local FocusNavigationRegistryProvider = FocusNavigableSurfaceRegistry.Provider
local FocusNavigationCoreScriptsWrapper = FocusNavigationUtils.FocusNavigationCoreScriptsWrapper
local FocusRoot = FocusNavigationUtils.FocusRoot
local FocusNavigableSurfaceIdentifierEnum = FocusNavigationUtils.FocusNavigableSurfaceIdentifierEnum

local GetFFlagEnableToastLiteRender = require(Root.Flags.GetFFlagEnableToastLiteRender)
local FFlagUIBloxFoundationProvider =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagUIBloxFoundationProvider()
local FFlagAddCursorProviderToPurchasePromptApp = require(Root.Flags.FFlagAddCursorProviderToPurchasePromptApp)
local FFlagCSFocusWrapperRefactor = require(CorePackages.Workspace.Packages.SharedFlags).FFlagCSFocusWrapperRefactor

local PurchasePromptApp = Roact.Component:extend("PurchasePromptApp")

local SELECTION_GROUP_NAME = "PurchasePromptApp"

function PurchasePromptApp:init()
	local externalSettings = ExternalSettings.new()

	self.state = {
		isTenFootInterface = externalSettings.isTenFootInterface(),
	}
end

function PurchasePromptApp:renderWithStyle(children)
	return renderWithCoreScriptsStyleProvider(children)
end

function PurchasePromptApp:render()
	return provideRobloxLocale(function()
		local children = {
			LocaleProvider = Roact.createElement(LocaleProvider, {
				locale = LocalizationService.RobloxLocaleId,
			}, {
				ProductPurchaseContainer = Roact.createElement(ProductPurchaseContainer),
				RobuxUpsellContainer = Roact.createElement(RobuxUpsellContainer),
				PremiumUpsellContainer = Roact.createElement(PremiumUpsellContainer),
				SubscriptionPurchaseContainer = Roact.createElement(SubscriptionPurchaseContainer),
			}),
			EventConnections = Roact.createElement(EventConnections),
			Toast = if GetFFlagEnableToastLiteRender() then Roact.createElement(Toast) else nil,
		} :: any

		if FFlagAddCursorProviderToPurchasePromptApp then
			children = {
				CursorProvider = Roact.createElement(SelectionCursorProvider, {}, {
					FocusNavigationProvider = Roact.createElement(
						ReactFocusNavigation.FocusNavigationContext.Provider,
						{
							value = focusNavigationService,
						},
						{
							FocusNavigationRegistryProvider = Roact.createElement(
								FocusNavigationRegistryProvider,
								nil,
								{
									FocusNavigationCoreScriptsWrapper = Roact.createElement(
										if FFlagCSFocusWrapperRefactor
											then FocusRoot
											else FocusNavigationCoreScriptsWrapper,
										if FFlagCSFocusWrapperRefactor
											then {
												surfaceIdentifier = FocusNavigableSurfaceIdentifierEnum.CentralOverlay,
												isIsolated = true,
												isAutoFocusRoot = true,
											}
											else {
												selectionGroupName = SELECTION_GROUP_NAME,
												focusNavigableSurfaceIdentifier = FocusNavigableSurfaceIdentifierEnum.CentralOverlay,
											},
										children
									),
								}
							),
						}
					),
				}),
			} :: any
		end

		if FFlagUIBloxFoundationProvider then
			return Roact.createElement("ScreenGui", {
				AutoLocalize = false,
				IgnoreGuiInset = true,
			}, {
				StoreProvider = Roact.createElement(RoactRodux.StoreProvider, {
					store = self.props.store,
				}, {
					StyleProvider = self:renderWithStyle({
						LayoutValuesProvider = Roact.createElement(LayoutValuesProvider, {
							isTenFootInterface = self.state.isTenFootInterface,
						}, {
							PolicyProvider = Roact.createElement(PurchasePromptPolicy.Provider, {
								policy = { PurchasePromptPolicy.Mapper },
							}, children),
						}),
					}),
				}),
			})
		else
			return Roact.createElement(RoactRodux.StoreProvider, {
				store = self.props.store,
			}, {
				StyleProvider = self:renderWithStyle({
					LayoutValuesProvider = Roact.createElement(LayoutValuesProvider, {
						isTenFootInterface = self.state.isTenFootInterface,
					}, {
						PolicyProvider = Roact.createElement(PurchasePromptPolicy.Provider, {
							policy = { PurchasePromptPolicy.Mapper },
						}, {
							PurchasePrompt = Roact.createElement("ScreenGui", {
								AutoLocalize = false,
								IgnoreGuiInset = true,
							}, children),
						}),
					}),
				}),
			})
		end
	end)
end

return PurchasePromptApp
