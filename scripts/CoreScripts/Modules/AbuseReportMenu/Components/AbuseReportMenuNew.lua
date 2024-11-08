--!nonstrict
local root = script:FindFirstAncestor("AbuseReportMenu")
local CorePackages = game:GetService("CorePackages")

local LocalizationService = game:GetService("LocalizationService")
local PlayersService = game:GetService("Players")
local React = require(CorePackages.Packages.React)
local Style = require(CorePackages.Workspace.Packages.Style)

local ReportTypeSelector = require(root.Components.ReportTypeSelector)
local Constants = require(root.Components.Constants)
local ReportModes = Constants.ReportModes
local ReportTypes = Constants.ReportTypes
local SelectInSceneReportMenu = require(root.Components.SelectInSceneReportMenu)
local ReportPersonMenuItemsContainer = require(root.Components.Containers.ReportPersonMenuItemsContainer)
local ReportExperienceMenuItemsContainer = require(root.Components.Containers.ReportExperienceMenuItemsContainer)
local ReportAnythingAnalytics = require(root.ReportAnything.Utility.ReportAnythingAnalytics)
local ReportAbuseAnalytics = require(root.Analytics.ReportAbuseAnalytics)
local AnnotationModal = require(root.ReportAnything.Components.AnnotationModal)
local ModalBasedSelectorDialogController = require(root.Components.ModalBasedSelectorDialogController)
local Localization = require(CorePackages.Workspace.Packages.InExperienceLocales).Localization
local LocalizationProvider = require(CorePackages.Workspace.Packages.Localization).LocalizationProvider
local useLocalization = require(CorePackages.Workspace.Packages.Localization).Hooks.useLocalization
local useReportAnythingWithScreenshot = require(root.Hooks.useReportAnythingWithScreenshot)
local getMenuItemSizings = require(root.Utility.getMenuItemSizings)
local analyticsReducer = require(root.Reducers.analyticsReducer)
local createCleanup = require(root.Components.createCleanup)

local DSAReportingPackage = require(CorePackages.Workspace.Packages.DsaIllegalContentReporting)
local isShowEUDSAIllegalContentReportingLink = DSAReportingPackage.isShowEUDSAIllegalContentReportingLink
local DSAReportLink = DSAReportingPackage.DSAReportLink
local StyleProviderWithDefaultTheme = Style.StyleProviderWithDefaultTheme

local ReactFocusNavigation = require(CorePackages.Packages.ReactFocusNavigation)
local FocusNavigationUtils = require(CorePackages.Workspace.Packages.FocusNavigationUtils)
local FocusNavigationCoreScriptsWrapper = FocusNavigationUtils.FocusNavigationCoreScriptsWrapper
local FocusNavigableSurfaceIdentifierEnum = FocusNavigationUtils.FocusNavigableSurfaceIdentifierEnum
local focusNavigationService =
	ReactFocusNavigation.FocusNavigationService.new(ReactFocusNavigation.EngineInterface.CoreGui)

local GetFFlagSelectInSceneReportMenu =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagSelectInSceneReportMenu

local isShowSelectInSceneReportMenu = require(root.Utility.isShowSelectInSceneReportMenu)

local UIBlox = require(CorePackages.Packages.UIBlox)
local SegmentedControl = UIBlox.App.Control.SegmentedControl

local REPORT_MODES = { ReportModes.Classic, ReportModes.SelectInScene }
local REPORT_TYPES = { ReportTypes.Person, ReportTypes.Experience }

export type Props = {
	hideReportTab: () -> (),
	showReportTab: () -> (),
	showReportSentPage: (reportedPlayer: any) -> (),
	registerOnReportTabHidden: (() -> ()) -> (),
	registerOnReportTabDisplayed: (() -> ()) -> (),
	registerOnSettingsHidden: (() -> ()) -> (),
	registerSetNextPlayerToReport: ((player: Player) -> ()) -> (),
	registerOnMenuWidthChange: ((width: number) -> ()) -> (),
	onReportComplete: (text: string) -> (),
}

local AbuseReportMenuNew = function(props: Props)
	local isReportTabVisible, setIsReportTabVisible = React.useState(false)
	local reportModeIndex, setReportModeIndex = React.useState(1)
	local reportTypeIndex, setReportTypeIndex = React.useState(1)
	local preselectedPlayer: Player?, setPreselectedPlayer = React.useState(nil :: Player?)
	local menuWidth, setMenuWidth = React.useState(0)
	local isOnlyPlayerInGame, setIsOnlyPlayerInGame = React.useState(false)
	local shouldSelectorRender, setShouldSelectorRender = React.useState(false)

	local viewportDimension, setViewportDimension = React.useState({ width = 0, height = 0 })
	local isSmallPortraitViewport = viewportDimension.width < viewportDimension.height and viewportDimension.width < 700

	local analyticsState, analyticsDispatch = React.useReducer(analyticsReducer, Constants.AnalyticsInitialState)
	local reportMode = REPORT_MODES[reportModeIndex]
	local reportType = REPORT_TYPES[reportTypeIndex]
	local cleanup = React.useCallback(
		createCleanup(analyticsState, analyticsDispatch, setPreselectedPlayer, reportType),
		{ analyticsState, reportTypeIndex } :: { any }
	)

	local reportAnythingState, reportAnythingDispatch =
		useReportAnythingWithScreenshot(isReportTabVisible, props.hideReportTab, props.showReportTab, cleanup)

	local sizings = getMenuItemSizings()

	local localizedText = useLocalization(Constants.localizationKeys)

	React.useEffect(function()
		props.registerOnReportTabDisplayed(function()
			setIsReportTabVisible(true)
		end)
		props.registerOnReportTabHidden(function()
			setIsReportTabVisible(false)
			AnnotationModal.unmountAnnotationPage()
			ModalBasedSelectorDialogController.unmountModalSelector() -- added so that modal selector doesnt stay after closing menu
		end)
		props.registerSetNextPlayerToReport(function(player: Player)
			setPreselectedPlayer(player)
		end)
		props.registerOnMenuWidthChange(function(width)
			setMenuWidth(width)
		end)
		props.registerOnSettingsHidden(function()
			if ReportAbuseAnalytics:getAbuseReportSessionEntryPoint() == "" then
				reportAnythingDispatch({
					type = Constants.ReportAnythingActions.ClearAll,
				})
			end
		end)
	end, {})

	React.useEffect(function()
		if not isReportTabVisible then
			-- unmount sub menu containers when not on report tab
			setReportTypeIndex(0)

			if GetFFlagSelectInSceneReportMenu() then
				-- set report menu type selector back to default report mode when not on report tab
				setReportModeIndex(1)
				-- set selector render condition to false so we can do the check on open again
				setShouldSelectorRender(false)
			end
		else
			local playerObjects = PlayersService:GetPlayers()
			if #playerObjects <= 1 then
				setIsOnlyPlayerInGame(true)
				setReportTypeIndex(2)
			else
				setReportTypeIndex(1)
				setIsOnlyPlayerInGame(false)
			end
		end
	end, { isReportTabVisible })

	React.useEffect(function()
		if isReportTabVisible then
			analyticsDispatch({
				type = Constants.AnalyticsActions.SetMenuOpenedTimestamp,
				timestamp = math.floor(workspace:GetServerTimeNow() * 1000),
			})
			-- This is the only start... call if the user opens the report page by
			-- going to it directly.
			-- For a prepopulated player report, start... is called inside
			-- `PageInstance:ReportPlayer` before this. In that case, this call will leave
			-- the session and recorded entryPoint alone.
			ReportAbuseAnalytics:startAbuseReportSession("ReportPage")
			if isShowSelectInSceneReportMenu() then
				-- check if we should show selector once every time we open the report tab
				-- this is so the selector doesn't render while the report has already been open for a bit
				setShouldSelectorRender(true)
			end
		end

		local camera = game.Workspace.CurrentCamera
		if camera ~= nil then
			local viewportSize = camera.ViewportSize
			setViewportDimension({ width = viewportSize.X, height = viewportSize.Y })
			analyticsDispatch({
				type = Constants.AnalyticsActions.SetViewportInformation,
				viewportSizeX = viewportSize.X,
				viewportSizeY = viewportSize.Y,
			})
		end
	end, { isReportTabVisible, menuWidth } :: { any })

	local menuItems = nil

	local utilityProps = {
		onReportComplete = props.onReportComplete,
		reportAnythingAnalytics = ReportAnythingAnalytics,
		reportAnythingState = reportAnythingState,
		reportAnythingDispatch = reportAnythingDispatch,
		hideReportTab = props.hideReportTab,
		isReportTabVisible = isReportTabVisible,
		showReportSentPage = props.showReportSentPage,
		analyticsState = analyticsState,
		analyticsDispatch = analyticsDispatch,
		preselectedPlayer = preselectedPlayer,
		setPreselectedPlayer = setPreselectedPlayer,
		menuWidth = menuWidth,
		viewportDimension = viewportDimension,
	}

	if reportType == ReportTypes.Person then
		menuItems = React.createElement(ReportPersonMenuItemsContainer, {
			utilityProps = utilityProps,
			isSmallPortraitViewport = isSmallPortraitViewport,
		})
	elseif reportType == ReportTypes.Experience then
		menuItems = React.createElement(ReportExperienceMenuItemsContainer, {
			utilityProps = utilityProps,
			isSmallPortraitViewport = isSmallPortraitViewport,
		})
	end

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, sizings.TopPadding),
	}, {
		MenuLayoutFrame = React.createElement("Frame", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
		}, {
			Layout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = 0,
				Padding = UDim.new(0, 12),
			}),
			SelectInSceneToggleFrame = if shouldSelectorRender
				then React.createElement("Frame", {
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.XY,
					Position = UDim2.new(0.5, 0, 0, 0),
					AnchorPoint = Vector2.new(0.5, 0),
					LayoutOrder = 0,
				}, {
					SelectInSceneToggle = React.createElement(SegmentedControl, {
						onTabActivated = function(tabIndex)
							setReportModeIndex(tabIndex)
						end,
						selectedTabIndex = reportModeIndex,
						tabs = {
							{
								tabName = localizedText.BuildAReport,
							},
							{
								tabName = localizedText.SelectInScene,
							},
						},
						width = UDim.new(0, menuWidth),
					}),
				})
				else nil,
			Menu = if reportMode == ReportModes.SelectInScene
				then React.createElement(SelectInSceneReportMenu, { hideReportTab = props.hideReportTab })
				elseif reportMode == ReportModes.Classic then React.createElement("Frame", {
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1, 0, 0, 0),
					LayoutOrder = 1,
				}, {
					Layout = React.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, sizings.ItemPadding),
					}),
					ReportTypeSelector = React.createElement(ReportTypeSelector, {
						label = localizedText.ReportType,
						abuseType = localizedText[REPORT_TYPES[reportTypeIndex]],
						layoutOrder = 0,
						utilityProps = utilityProps,
						isSelectionDisabled = isOnlyPlayerInGame,
						menuWidth = menuWidth,
						isSmallPortraitViewport = isSmallPortraitViewport,
						onClickLeft = function()
							reportAnythingDispatch({
								type = Constants.ReportAnythingActions.ClearAnnotationFlowProperties,
							})
							analyticsDispatch({ type = Constants.AnalyticsActions.IncrementExperiencePersonChanged })
							-- lua table index starts at 1 so we have to make some adjustents to the mod operations here
							setReportTypeIndex((reportTypeIndex - 1 - 1) % #REPORT_TYPES + 1)
						end,
						onClickRight = function()
							reportAnythingDispatch({
								type = Constants.ReportAnythingActions.ClearAnnotationFlowProperties,
							})
							analyticsDispatch({ type = Constants.AnalyticsActions.IncrementExperiencePersonChanged })
							-- lua table index starts at 1 so we have to make some adjustents to the mod operations here
							setReportTypeIndex((reportTypeIndex - 1 + 1) % #REPORT_TYPES + 1)
						end,
					}),
					MenuItemsContainer = React.createElement("Frame", {
						BackgroundTransparency = 1,
						LayoutOrder = 1,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.new(1, 0, 0, 0),
					}, {
						MenuItems = menuItems,
					}),
					DSALinkFrame = if isShowEUDSAIllegalContentReportingLink()
						then React.createElement("Frame", {
							BackgroundTransparency = 1,
							LayoutOrder = 2,
							AutomaticSize = Enum.AutomaticSize.Y,
							Size = UDim2.new(1, 0, 0, 0),
						}, {
							DSALink = React.createElement(DSAReportLink),
						})
						else nil,
				})
				else nil,
		}),
	})
end

local MenuContainer = function(props: Props)
	local localization = Localization.new(LocalizationService.RobloxLocaleId)

	return React.createElement(StyleProviderWithDefaultTheme, {
		withDarkTheme = true,
	}, {
		LocalizationProvider = React.createElement(LocalizationProvider, {
			localization = localization,
		}, {
			FocusNavigationProvider = React.createElement(ReactFocusNavigation.FocusNavigationContext.Provider, {
				value = focusNavigationService,
			}, {
				FocusNavigationCoreScriptsWrapper = React.createElement(FocusNavigationCoreScriptsWrapper, {
					selectionGroupName = Constants.AbuseReportMenuRootName,
					focusNavigableSurfaceIdentifier = FocusNavigableSurfaceIdentifierEnum.RouterView,
					automaticSize = Enum.AutomaticSize.Y,
					size = UDim2.new(1, 0, 0, 0),
				}, {
					[Constants.AbuseReportMenuRootName] = React.createElement(AbuseReportMenuNew, props),
				}),
			}),
		}),
	})
end

return MenuContainer
