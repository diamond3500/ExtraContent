--[[
		Filename: Home.lua
		Written by: jeditkacheff
		Version 1.0
		Description: Takes care of the home page in Settings Menu
--]]

local BUTTON_OFFSET = 20
local BUTTON_SPACING = 10

-------------- SERVICES --------------
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local GuiService = game:GetService("GuiService")
local AnalyticsService = game:GetService("RbxAnalyticsService")

----------- UTILITIES --------------
local utility = require(RobloxGui.Modules.Settings.Utility)
local Theme = require(RobloxGui.Modules.Settings.Theme)

------------ Variables -------------------
local PageInstance = nil

local success, result = pcall(function() return settings():GetFFlag('UseNotificationsLocalization') end)
local Constants = require(RobloxGui.Modules:WaitForChild("InGameMenu"):WaitForChild("Resources"):WaitForChild("Constants"))
local FFlagUseNotificationsLocalization = success and result

----------- CLASS DECLARATION --------------

local function Initialize()
	local settingsPageFactory = require(RobloxGui.Modules.Settings.SettingsPageFactory)
	local this = settingsPageFactory:CreateNewPage()

	------ TAB CUSTOMIZATION -------
	this.TabHeader.Name = "HomeTab"

	if Theme.UIBloxThemeEnabled then
		this.TabHeader.TabLabel.Icon.Image = "rbxasset://textures/ui/Settings/MenuBarIcons/HomeTab.png"
		this.TabHeader.TabLabel.Title.Text = "Home"
	else
		this.TabHeader.Icon.Image = "rbxasset://textures/ui/Settings/MenuBarIcons/HomeTab.png"
		this.TabHeader.Icon.Size = UDim2.new(0,32,0,30)
		this.TabHeader.Icon.Position = UDim2.new(0,5,0.5,-15)

		if FFlagUseNotificationsLocalization then
			this.TabHeader.Title.Text = "Home"
		else
			this.TabHeader.Icon.Title.Text = "Home"
		end
	end


	this.TabHeader.Size = UDim2.new(0,100,1,0)

	------ PAGE CUSTOMIZATION -------
	this.Page.Name = "Home"
	local resumeGameFunc = function()
		this.HubRef:SetVisibility(false)
		AnalyticsService:SetRBXEventStream(
			Constants.AnalyticsTargetName,
			Constants.AnalyticsResumeGameName,
			Constants.AnalyticsMenuActionName,
			{ source = Constants.AnalyticsResumeButtonSource }
		)
	end

	local resumeGameText = "Resume"

	this.ResumeButton = utility:MakeStyledButton("ResumeButton", resumeGameText, UDim2.new(0, 200, 0, 50), resumeGameFunc)
	this.ResumeButton.Position = UDim2.new(0.5,-100,0,BUTTON_OFFSET)
	this.ResumeButton.Parent = this.Page

	local resetFunc = function()
		this.HubRef:SwitchToPage(this.HubRef.ResetCharacterPage, false, 1)
	end

	local resetButton = utility:MakeStyledButton("ResetButton", "Reset Character", UDim2.new(0, 200, 0, 50), resetFunc)
	resetButton.Position = UDim2.new(0.5,-100,0,this.ResumeButton.AbsolutePosition.Y + this.ResumeButton.AbsoluteSize.Y + BUTTON_SPACING)
	resetButton.Parent = this.Page

	local leaveGameFunc = function()
		this.HubRef:SwitchToPage(this.HubRef.LeaveGamePage, false, 1)
	end

	local leaveGameText = "Leave"

	local leaveButton = utility:MakeStyledButton("LeaveButton", leaveGameText, UDim2.new(0, 200, 0, 50), leaveGameFunc)
	leaveButton.Position = UDim2.new(0.5,-100,0,resetButton.AbsolutePosition.Y + resetButton.AbsoluteSize.Y + BUTTON_SPACING)
	leaveButton.Parent = this.Page

	this.Page.Size = UDim2.new(1,0,0,leaveButton.AbsolutePosition.Y + leaveButton.AbsoluteSize.Y)

	return this
end


----------- Public Facing API Additions --------------
do
	PageInstance = Initialize()

	PageInstance.Displayed.Event:connect(function()
		if not utility:UsesSelectedObject() then return end

		GuiService.SelectedCoreObject = PageInstance.ResumeButton
	end)
end


return PageInstance
