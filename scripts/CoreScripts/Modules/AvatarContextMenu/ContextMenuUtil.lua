--!nonstrict
--[[
	// FileName: ContextMenuUtil.lua
	// Written by: TheGamer101
	// Description: Module for utility funcitons of the avatar context menu.
]]

--[[
	// FileName: ContextMenuGui.lua
	// Written by: TheGamer101
	// Description: Module for creating the context GUI.
]]

--- CONSTANTS

local STOP_MOVEMENT_ACTION_NAME = "AvatarContextMenuStopInput"

--- SERVICES
local CoreGuiService = game:GetService("CoreGui")
local PlayersService = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local RobloxReplicatedStorage = game:GetService("RobloxReplicatedStorage")
local CorePackages = game:GetService("CorePackages")

--- VARIABLES
local RobloxGui = CoreGuiService:WaitForChild("RobloxGui")
local CoreGuiModules = RobloxGui:WaitForChild("Modules")
local AvatarMenuModules = CoreGuiModules:WaitForChild("AvatarContextMenu")
local ThemeHandler = require(AvatarMenuModules.ThemeHandler)
local BlockingUtility = require(CorePackages.Workspace.Packages.BlockingUtility)

type Theme = ThemeHandler.Theme

local LocalPlayer = PlayersService.LocalPlayer
while not LocalPlayer do
	PlayersService.PlayerAdded:Wait()
	LocalPlayer = PlayersService.LocalPlayer
end

local ContextMenuUtil = {}
ContextMenuUtil.__index = ContextMenuUtil

-- PUBLIC METHODS

function ContextMenuUtil:GetHeadshotForPlayer(player)
	return "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
end

function ContextMenuUtil:HasOrGettingHeadShot(player)
	return self.HeadShotUrlCache[player] ~= nil
end

function ContextMenuUtil:FindPlayerFromPart(part)
	if part and part.Parent then
		local possibleCharacter = part
		while possibleCharacter and not possibleCharacter:IsA("Model") do
			possibleCharacter = possibleCharacter.Parent
		end
		if possibleCharacter then
			return PlayersService:GetPlayerFromCharacter(possibleCharacter)
		end
	end
	return nil
end

function ContextMenuUtil:GetPlayerPosition(player)
	if player.Character then
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			return hrp.Position
		end
	end
	return nil
end

local playerMovementEnabled = true

function ContextMenuUtil:DisablePlayerMovement()
	if not playerMovementEnabled then return end
	playerMovementEnabled = false

    local noOpFunc = function(actionName, actionState)
        if actionState == Enum.UserInputState.End then
            return Enum.ContextActionResult.Pass
        end
        return Enum.ContextActionResult.Sink
    end

	ContextActionService:BindCoreActionAtPriority(STOP_MOVEMENT_ACTION_NAME, noOpFunc, false, Enum.ContextActionPriority.Low.Value,
		Enum.PlayerActions.CharacterForward,
		Enum.PlayerActions.CharacterBackward,
		Enum.PlayerActions.CharacterLeft,
		Enum.PlayerActions.CharacterRight,
		Enum.PlayerActions.CharacterJump,
		Enum.UserInputType.Gamepad1, Enum.UserInputType.Gamepad2, Enum.UserInputType.Gamepad3, Enum.UserInputType.Gamepad4
	)
end

function ContextMenuUtil:EnablePlayerMovement()
	if playerMovementEnabled then return end
	playerMovementEnabled = true

	ContextActionService:UnbindCoreAction(STOP_MOVEMENT_ACTION_NAME)
end

function ContextMenuUtil:GetFriendStatus(player)
	local success, result = pcall(function()
		-- NOTE: Core script only
		return LocalPlayer:GetFriendStatus(player)
	end)
	if success then
		return result
	else
		return Enum.FriendStatus.NotFriend
	end
end

local CanChatWithMap = {}
coroutine.wrap(function()
	local RemoteEvent_CanChatWith = RobloxReplicatedStorage:WaitForChild("CanChatWith", math.huge)

	RemoteEvent_CanChatWith.OnClientEvent:Connect(function(...)
		local remoteArguments = {...}

		if #remoteArguments == 1 then --Only one parameter, so it should be the data dictionary
			local canChatData = remoteArguments[1]

			for userId, canChat in pairs(canChatData) do
				CanChatWithMap[userId] = canChat
			end
		elseif #remoteArguments == 2 then --More arguments, server flag isn't enabled yet
			local userId = remoteArguments[1]
			local canChat = remoteArguments[2]
			CanChatWithMap[userId] = canChat
		end
	end)
end)()
function ContextMenuUtil:GetCanChatWith(otherPlayer)
	if BlockingUtility:IsPlayerBlockedByUserId(otherPlayer.UserId) then
		-- This can be removed when Chat:CanUsersChatAsync() correctly respects blocked status.
		return false
	end
	if CanChatWithMap[otherPlayer.UserId] ~= nil then
		return CanChatWithMap[otherPlayer.UserId]
	end
	-- Assume we can chat if we have not received information from the server yet.
	return true
end

local SelectionOverrideObject = Instance.new("ImageLabel")
SelectionOverrideObject.Image = ""
SelectionOverrideObject.BackgroundTransparency = 1

local function MakeDefaultButton(name, size, clickFunc, theme: Theme)

	local button = Instance.new("ImageButton")
	button.Name = name
	button.Image = theme.ButtonImage
	button.ScaleType = theme.ButtonImageScaleType
	button.SliceCenter = theme.ButtonImageSliceCenter
	button.BackgroundColor3 = theme.ButtonColor
	button.BackgroundTransparency = theme.ButtonTransparency
	button.AutoButtonColor = false
	button.Size = size
	button.ZIndex = 2
	button.SelectionImageObject = SelectionOverrideObject
	button.BorderSizePixel = 0

		local underline = Instance.new("Frame")
		underline.Name = "Underline"
		underline.BackgroundColor3 = theme.ButtonUnderlineColor
		underline.AnchorPoint = Vector2.new(0.5,1)
		underline.BorderSizePixel = 0
		underline.Position = UDim2.new(0.5,0,1,0)
		underline.Size = UDim2.new(0.95,0,0,1)
		underline.Parent = button

	if clickFunc then
		button.MouseButton1Click:Connect(function()
			clickFunc(UserInputService:GetLastInputType())
		end)
	end

	local function isPointerInput(inputObject)
		return inputObject.UserInputType == Enum.UserInputType.MouseMovement or inputObject.UserInputType == Enum.UserInputType.Touch
	end

	local function selectButton()
		button.BackgroundColor3 = theme.ButtonHoverColor
		button.BackgroundTransparency = theme.ButtonHoverTransparency
	end

	local function deselectButton()
		button.BackgroundColor3 = theme.ButtonColor
		button.BackgroundTransparency = theme.ButtonTransparency
	end

	button.InputBegan:Connect(function(inputObject)
		if button.Selectable and isPointerInput(inputObject) then
			selectButton()
            inputObject:GetPropertyChangedSignal("UserInputState"):connect(function()
                                                                             if inputObject.UserInputState == Enum.UserInputState.End then
                                                                                deselectButton()
                                                                             end
                                                                         end)
        end
	end)
	button.InputEnded:Connect(function(inputObject)
        if button.Selectable and GuiService.SelectedCoreObject ~= button and isPointerInput(inputObject) then
			deselectButton()
		end
	end)

	button.SelectionGained:Connect(function()
		selectButton()
	end)
	button.SelectionLost:Connect(function()
		deselectButton()
	end)

	local guiServiceCon = GuiService.Changed:Connect(function(prop)
		if prop ~= "SelectedCoreObject" then return end

		if GuiService.SelectedCoreObject == nil or GuiService.SelectedCoreObject ~= button then
			deselectButton()
			return
		end

		if button.Selectable then
			selectButton()
		end
	end)

	return button
end

local function getViewportSize()
	while not workspace.CurrentCamera do
		workspace.Changed:Wait()
	end
	assert(workspace.CurrentCamera, "")

	-- ViewportSize is initally set to 1, 1 in Camera.cpp constructor.
	-- Also check against 0, 0 incase this is changed in the future.
	while (workspace.CurrentCamera :: Camera).ViewportSize == Vector2.new(0,0) or
		(workspace.CurrentCamera :: Camera).ViewportSize == Vector2.new(1,1) do
		(workspace.CurrentCamera :: Camera).Changed:Wait()
	end

	return (workspace.CurrentCamera :: Camera).ViewportSize
end

local function isSmallTouchScreen()
	local viewportSize = getViewportSize()
	return UserInputService.TouchEnabled and (viewportSize.Y < 500 or viewportSize.X < 700)
end

function ContextMenuUtil:MakeStyledButton(name, text, size, clickFunc, theme: Theme)
	local button = MakeDefaultButton(name, size, clickFunc, theme)

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name .. "TextLabel"
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.Size = UDim2.new(1, 0, 1, -8)
	textLabel.Position = UDim2.new(0,0,0,0)
	textLabel.TextColor3 = Color3.fromRGB(255,255,255)
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.Font = theme.Font
	textLabel.TextSize = 24 * theme.TextScale
	if isSmallTouchScreen() then
		textLabel.TextSize = 18 * theme.TextScale
	elseif GuiService:IsTenFootInterface() then
		textLabel.TextSize = 36 * theme.TextScale
	end
	textLabel.Text = text
	textLabel.TextScaled = true
	textLabel.TextWrapped = true
	textLabel.ZIndex = 2
	textLabel.Parent = button

	local constraint = Instance.new("UITextSizeConstraint", textLabel)
	constraint.MaxTextSize = textLabel.TextSize

	return button, textLabel
end

function ContextMenuUtil.new()
	local obj = setmetatable({}, ContextMenuUtil)
	return obj
end

return ContextMenuUtil.new()
