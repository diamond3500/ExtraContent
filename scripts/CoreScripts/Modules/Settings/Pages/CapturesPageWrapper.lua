--[[
	Wrapper page for Captures page in the SettingsHub

	The Captures page is implemented in Roact, so this page acts as a container for the Roact portal.

	Captures is the tab in the in-game menu that contains screenshots (and potentially video captures) taken in game.
--]]

local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local Modules = RobloxGui.Modules 

local RobloxTranslator = require(CorePackages.Workspace.Packages.RobloxTranslator)
local SettingsPageFactory = require(Modules.Settings.SettingsPageFactory)
local Theme = require(Modules.Settings.Theme)
local ChromeEnabled = require(RobloxGui.Modules.Chrome.Enabled)()

local GetFFlagFixIGMTabTransitions = require(script.Parent.Parent.Flags.GetFFlagFixIGMTabTransitions)

-- Initialize page
local this = SettingsPageFactory:CreateNewPage()

-- Tab Header customization
this.TabHeader.Name = "CapturesTab"

local icon = if ChromeEnabled then Theme.Images["icons/controls/cameraOff"] else Theme.Images["icons/controls/screenshot"]
this.TabHeader.TabLabel.Icon.Image = icon.Image
this.TabHeader.TabLabel.Icon.ImageRectOffset = icon.ImageRectOffset
this.TabHeader.TabLabel.Icon.ImageRectSize = icon.ImageRectSize

this.TabHeader.TabLabel.Title.AutoLocalize = false
this.TabHeader.TabLabel.Title.Text = RobloxTranslator:FormatByKey("Feature.SettingsHub.Label.Captures")

this.PageListLayout.Parent = nil
this.ShouldShowBottomBar = true
this.ShouldShowHubBar = true

this.Page.Name = "Captures"
this.Page.Size = UDim2.fromScale(1, 0)

local paddingInstance = this.Page:FindFirstChildWhichIsA("UIPadding")
if paddingInstance then
	paddingInstance:Destroy()
end

local SETTINGS_HUB_PADDING = 20

function this:ConnectHubToApp(settingsHub, pageViewClipper, capturesApp)
	this:SetHub(settingsHub)

	local availableSizeY = pageViewClipper.AbsoluteSize.Y - SETTINGS_HUB_PADDING
	this.Page.Size = UDim2.new(1, 0, 0, availableSizeY)
	pageViewClipper:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		availableSizeY = pageViewClipper.AbsoluteSize.Y - SETTINGS_HUB_PADDING
		this.Page.Size = UDim2.new(1, 0, 0, availableSizeY)
	end)

	local display = this.Display
	function this:Display(...)
		capturesApp.openMenu()
		display(this, ...)
	end

	this.Hidden.Event:Connect(function()
		-- On flag cleanup, remove the entire this.Hidden.Event:Connect function
		if not GetFFlagFixIGMTabTransitions() then
			capturesApp.closeMenu()
		end
	end)


	local hide = this.Hide
	function this:Hide(...)
		if GetFFlagFixIGMTabTransitions() then
			capturesApp.closeMenu()
		end
		hide(this, ...)
	end
end

return this
