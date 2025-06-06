--!nonstrict
--[[
		Filename: LeaveGame.lua
		Written by: jeditkacheff
		Version 1.0
		Description: Takes care of the leave game in Settings Menu
--]]


-------------- CONSTANTS -------------
local LEAVE_GAME_ACTION = "LeaveGameCancelAction"

-------------- SERVICES --------------
local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local ContextActionService = game:GetService("ContextActionService")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local GuiService = game:GetService("GuiService")
local AnalyticsService = game:GetService("RbxAnalyticsService")

----------- UTILITIES --------------
local utility = require(RobloxGui.Modules.Settings.Utility)
local leaveGame = require(RobloxGui.Modules.Settings.leaveGame)
local Create = require(CorePackages.Workspace.Packages.AppCommonLib).Create

local ChromeEnabled = require(RobloxGui.Modules.Chrome.Enabled)()
local ChromeService = if ChromeEnabled then require(RobloxGui.Modules.Chrome.Service) else nil
local ChromeConstants = if ChromeEnabled then require(RobloxGui.Modules.Chrome.ChromeShared.Unibar.Constants) else nil

------------ Variables -------------------
local PageInstance = nil
RobloxGui:WaitForChild("Modules"):WaitForChild("TenFootInterface")
local isTenFootInterface = require(RobloxGui.Modules.TenFootInterface):IsEnabled()

local FFlagEnableChromeShortcutBar = require(CorePackages.Workspace.Packages.SharedFlags).FFlagEnableChromeShortcutBar
local FFlagAddNextUpContainer = require(RobloxGui.Modules.Settings.Flags.FFlagAddNextUpContainer)

local Constants = require(RobloxGui.Modules:WaitForChild("InGameMenu"):WaitForChild("Resources"):WaitForChild("Constants"))

local Theme = require(RobloxGui.Modules.Settings.Theme)

----------- CLASS DECLARATION --------------

local function Initialize()
	local settingsPageFactory = require(RobloxGui.Modules.Settings.SettingsPageFactory)
	local this = settingsPageFactory:CreateNewPage()

	this.DontLeaveFunc = function(isUsingGamepad)
		if this.HubRef then
			this.HubRef:PopMenu(isUsingGamepad, true)
		end

		AnalyticsService:SetRBXEventStream(
			Constants.AnalyticsTargetName,
			Constants.AnalyticsInGameMenuName,
			Constants.AnalyticsLeaveGameName,
			{
				confirmed = Constants.AnalyticsCancelledName,
				universeid = tostring(game.GameId),
				source = Constants.AnalyticsLeaveGameSource
			}
		)
	end
	this.DontLeaveFromHotkey = function(name, state, input)
		if state == Enum.UserInputState.Begin then
			local isUsingGamepad = input.UserInputType == Enum.UserInputType.Gamepad1 or input.UserInputType == Enum.UserInputType.Gamepad2
				or input.UserInputType == Enum.UserInputType.Gamepad3 or input.UserInputType == Enum.UserInputType.Gamepad4

			this.DontLeaveFunc(isUsingGamepad)
		end
	end
	this.DontLeaveFromButton = function(isUsingGamepad)
		this.DontLeaveFunc(isUsingGamepad)
	end

	------ TAB CUSTOMIZATION -------
	this.TabHeader = nil -- no tab for this page

	------ PAGE CUSTOMIZATION -------
	this.Page.Name = "LeaveGamePage"
	this.ShouldShowBottomBar = false
	this.ShouldShowHubBar = false

	local leaveGameConfirmationText = "Are you sure you want to leave the experience?"

	local leaveGameText =  Create'TextLabel'
	{
		Name = "LeaveGameText",
		Text = leaveGameConfirmationText,
		Font = Theme.font(Enum.Font.SourceSansBold, "Confirmation"),
		FontSize = Theme.fontSize(Enum.FontSize.Size36, "Confirmation"),
		TextColor3 = Color3.new(1,1,1),
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,200),
		TextWrapped = true,
		ZIndex = 2,
		Parent = this.Page,
		Position = isTenFootInterface and UDim2.new(0,0,0,100) or UDim2.new(0,0,0,0)
	};

	local leaveButtonContainer = Create"Frame"
	{
		Name = "LeaveButtonContainer",
		Parent = leaveGameText,
		Size = UDim2.new(1,0,0,400),
		BackgroundTransparency = 1,
		Position = UDim2.new(0,0,1,0)
	};

	local _leaveButtonLayout = Create'UIGridLayout'
	{
		Name = "LeavetButtonsLayout",
		CellSize = isTenFootInterface and UDim2.new(0, 300, 0, 80) or UDim2.new(0, 200, 0, 50),
		CellPadding = UDim2.new(0,20,0,20),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Parent = leaveButtonContainer
	};

	if utility:IsSmallTouchScreen() then
		leaveGameText.FontSize = Enum.FontSize.Size24
		leaveGameText.Size = UDim2.new(1,0,0,100)
	elseif isTenFootInterface then
		leaveGameText.FontSize = Enum.FontSize.Size48
	end

	this.LeaveGameButton = utility:MakeStyledButton("LeaveGame", "Leave", nil, function() leaveGame(true) end)
	this.LeaveGameButton.NextSelectionRight = nil
	this.LeaveGameButton.Parent = leaveButtonContainer

	------------- Init ----------------------------------

	local dontleaveGameButton = utility:MakeStyledButton("DontLeaveGame", "Don't Leave", nil, this.DontLeaveFromButton)
	dontleaveGameButton.NextSelectionLeft = nil
	dontleaveGameButton.Parent = leaveButtonContainer

	this.Page.Size = UDim2.new(1,0,0,dontleaveGameButton.AbsolutePosition.Y + dontleaveGameButton.AbsoluteSize.Y)

	return this
end


----------- Public Facing API Additions --------------
PageInstance = Initialize()

PageInstance.Displayed.Event:connect(function()
	GuiService.SelectedCoreObject = PageInstance.LeaveGameButton
	if FFlagEnableChromeShortcutBar then 
		if ChromeEnabled then 
			ChromeService:setShortcutBar(ChromeConstants.TILTMENU_DIALOG_SHORTCUTBAR_ID)
		end
	else
		ContextActionService:BindCoreAction(LEAVE_GAME_ACTION, PageInstance.DontLeaveFromHotkey, false, Enum.KeyCode.ButtonB)
	end
end)

PageInstance.Hidden.Event:connect(function()
	ContextActionService:UnbindCoreAction(LEAVE_GAME_ACTION)
end)

if FFlagAddNextUpContainer then
	local LeaveGameWithNextupPage = require(script.Parent.LeaveGameWithNextUp)
	return LeaveGameWithNextupPage
else
	return PageInstance
end
