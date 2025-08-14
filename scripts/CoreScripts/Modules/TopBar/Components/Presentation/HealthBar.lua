--!nonstrict
local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local Workspace = game:GetService("Workspace")

local Roact = require(CorePackages.Packages.Roact)
local RoactRodux = require(CorePackages.Packages.RoactRodux)
local t = require(CorePackages.Packages.t)
local Signals = require(CorePackages.Packages.Signals)
local Display = require(CorePackages.Workspace.Packages.Display)

local Components = script.Parent.Parent
local TopBar = Components.Parent
local Constants = require(TopBar.Constants)

local CoreGuiCommon = require(CorePackages.Workspace.Packages.CoreGuiCommon)
local CoreGuiModules = RobloxGui:FindFirstChild("Modules")
local CommonModules = CoreGuiModules:FindFirstChild("Common")
local HumanoidReadyUtil = require(CommonModules:FindFirstChild("HumanoidReadyUtil"))

local TenFootInterface = require(RobloxGui.Modules.TenFootInterface)

local FFlagEnableChromeBackwardsSignalAPI = require(TopBar.Flags.GetFFlagEnableChromeBackwardsSignalAPI)()
local SetKeepOutArea = require(TopBar.Actions.SetKeepOutArea)
local RemoveKeepOutArea = require(TopBar.Actions.RemoveKeepOutArea)

local SharedFlags = require(CorePackages.Workspace.Packages.SharedFlags)
local GetFFlagFixChromeReferences = SharedFlags.GetFFlagFixChromeReferences
local FFlagTopBarSignalizeHealthBar = require(TopBar.Flags.FFlagTopBarSignalizeHealthBar)
local FFlagTopBarSignalizeKeepOutAreas = CoreGuiCommon.Flags.FFlagTopBarSignalizeKeepOutAreas
local FFlagTopBarSignalizeScreenSize = CoreGuiCommon.Flags.FFlagTopBarSignalizeScreenSize

local Chrome = TopBar.Parent.Chrome
local ChromeEnabled = require(Chrome.Enabled)
local ChromeService = if GetFFlagFixChromeReferences()
	then if ChromeEnabled() then require(Chrome.Service) else nil
	else if ChromeEnabled then require(Chrome.Service) else nil

local UseUpdatedHealthBar = ChromeEnabled()

local HEALTHBAR_SIZE = UDim2.new(0, 80, 0, 6)
if UseUpdatedHealthBar then
	HEALTHBAR_SIZE = UDim2.new(0, 125, 0, 20)
end
local HEALTHBAR_SIZE_XSMALL = UDim2.new(0, 50, 0, 16)
local HEALTHBAR_SIZE_SMALL = UDim2.new(0, 80, 0, 20)
local HEALTHBAR_SIZE_TENFOOT = UDim2.new(0, 220, 0, 16)

local HEALTHBAR_SIZE_BREAKPOINT_XSMALL = 320
local HEALTHBAR_SIZE_BREAKPOINT_SMALL = 393

local HEALTHBAR_OFFSET = 4
local HEALTHBAR_OFFSET_TENFOOT = 0

local HealthBar = Roact.PureComponent:extend("HealthBar")

HealthBar.validateProps = t.strictInterface({
	layoutOrder = t.optional(t.integer),

	screenSize = if FFlagTopBarSignalizeScreenSize then nil else t.Vector2,
	healthEnabled = if FFlagTopBarSignalizeHealthBar then nil else t.boolean,
	health = if FFlagTopBarSignalizeHealthBar then nil else t.number,
	maxHealth = if FFlagTopBarSignalizeHealthBar then nil else t.number,

	setKeepOutArea = if FFlagTopBarSignalizeKeepOutAreas then nil else t.callback,
	removeKeepOutArea = if FFlagTopBarSignalizeKeepOutAreas then nil else t.callback,
})

local function color3ToVector3(color3)
	return Vector3.new(color3.r, color3.g, color3.b)
end

local healthColorToPosition = {
	[color3ToVector3(Constants.HealthRedColor)] = 0.1,
	[color3ToVector3(Constants.HealthYellowColor)] = 0.5,
	[color3ToVector3(Constants.HealthGreenColor)] = 0.8,
}
local redHealthFraction = 0.1
local redHealthColor = Constants.HealthRedColor
local greenHealthFraction = 0.8
local greenHealthColor = Constants.HealthGreenColor

local function getHealthBarColor(healthPercent)
	if healthPercent <= redHealthFraction then
		return redHealthColor
	elseif healthPercent >= greenHealthFraction then
		return greenHealthColor
	end

	-- Shepard's Interpolation
	local numeratorSum = Vector3.new(0, 0, 0)
	local denominatorSum = 0
	for colorSampleValue, samplePoint in pairs(healthColorToPosition) do
		local distance = healthPercent - samplePoint
		if distance == 0 then
			-- If we are exactly on an existing sample value then we don't need to interpolate
			return Color3.new(colorSampleValue.x, colorSampleValue.y, colorSampleValue.z)
		else
			local wi = 1 / (distance * distance)
			numeratorSum = numeratorSum + wi * colorSampleValue
			denominatorSum = denominatorSum + wi
		end
	end
	local result = numeratorSum / denominatorSum
	return Color3.new(result.x, result.y, result.z)
end

function HealthBar:init()
	self.rootRef = Roact.createRef()
	if FFlagTopBarSignalizeHealthBar then
		self.health, self.setHealth = Roact.createBinding(Constants.InitialHealth)
		self.maxHealth, self.setMaxHealth = Roact.createBinding(Constants.InitialHealth)	
		self.isDead, self.setIsDead = Roact.createBinding(false)
		self.healthPercent = Roact.joinBindings({ self.health, self.maxHealth, self.isDead }):map(function(values) 
			local health = values[1]
			local maxHealth = values[2]
			local isDead = values[3]

			local healthPercent = 1
			if isDead then
				healthPercent = 0
			elseif maxHealth > 0 then
				healthPercent = health / maxHealth
			end

			return healthPercent
		end)
		self.healthVisible = Roact.joinBindings({ self.health, self.maxHealth }):map(function(values) 
			return values[1] < values[2]
		end)

		local function getHealthEnabled()
			return StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health)
		end

		self.coreGuiChangedSignalConn = StarterGui.CoreGuiChangedSignal:Connect(
			function(coreGuiType: Enum.CoreGuiType, enabled: boolean)
				if coreGuiType == Enum.CoreGuiType.Health or coreGuiType == Enum.CoreGuiType.All then
					if self.state.mountHealthBar ~= enabled then
						self:setState({
							mountHealthBar = enabled,
						})
					end
				end
			end
		)
		self:setState({
			mountHealthBar = getHealthEnabled(),
		})
		HumanoidReadyUtil.registerHumanoidReady(function(player, character, humanoid)
			local healthChangedConn
			local characterRemovingConn
			local diedConn
			local function disconnect()
				healthChangedConn:Disconnect()
				characterRemovingConn:Disconnect()
				diedConn:Disconnect()
			end
			
			self.setHealth(humanoid.Health)
			self.setMaxHealth(humanoid.MaxHealth)
			self.setIsDead(false)

			healthChangedConn = humanoid.HealthChanged:Connect(function()
				self.setHealth(humanoid.Health)
				self.setMaxHealth(humanoid.MaxHealth)
			end)

			diedConn = humanoid.Died:Connect(function()
				disconnect()
				self.setIsDead(true)
			end)

			characterRemovingConn = player.CharacterRemoving:Connect(function(removedCharacter)
				if removedCharacter == character then
					disconnect()
				end
			end)
		end)
	end
	if FFlagTopBarSignalizeKeepOutAreas and CoreGuiCommon.Stores.GetKeepOutAreasStore then 
		self.keepOutAreasStore = CoreGuiCommon.Stores.GetKeepOutAreasStore(false)
	end

	if FFlagTopBarSignalizeScreenSize then 
		local getViewportSize = Display.GetDisplayStore(false).getViewportSize
		self.screenSizeBinding, self.setScreenSizeBinding = Roact.createBinding(getViewportSize(false))

		self.disposeScreenSize = Signals.createEffect(function(scope) 
			self.setScreenSizeBinding(getViewportSize(scope))
		end)

		self.healthbarSizeBinding = self.screenSizeBinding:map(function(screenSize) 
			if TenFootInterface:IsEnabled() then
				return HEALTHBAR_SIZE_TENFOOT
			elseif UseUpdatedHealthBar and screenSize.X <= HEALTHBAR_SIZE_BREAKPOINT_XSMALL then
				return HEALTHBAR_SIZE_XSMALL
			elseif UseUpdatedHealthBar and screenSize.X <= HEALTHBAR_SIZE_BREAKPOINT_SMALL then
				return HEALTHBAR_SIZE_SMALL
			else
				return HEALTHBAR_SIZE
			end
		end)
	end
end

function HealthBar:onUnmount()
	if FFlagTopBarSignalizeHealthBar then 
		self.coreGuiChangedSignalConn:Disconnect()
	end
	if FFlagTopBarSignalizeScreenSize then 
		self.disposeScreenSize()
	end
end
function HealthBar:renderHealth()
	local healthVisible = nil
	if not FFlagTopBarSignalizeHealthBar then 
		healthVisible = self.props.healthEnabled and self.props.health < self.props.maxHealth
	end

	local healthPercent = 1
	if not FFlagTopBarSignalizeHealthBar then 
		if self.props.isDead then
			healthPercent = 0
		elseif self.props.maxHealth > 0 then
			healthPercent = self.props.health / self.props.maxHealth
		end
	end

	local healthBarSize
	if not FFlagTopBarSignalizeScreenSize then
		if UseUpdatedHealthBar then
			if self.props.screenSize.X <= HEALTHBAR_SIZE_BREAKPOINT_XSMALL then
				healthBarSize = HEALTHBAR_SIZE_XSMALL
			elseif self.props.screenSize.X <= HEALTHBAR_SIZE_BREAKPOINT_SMALL then
				healthBarSize = HEALTHBAR_SIZE_SMALL
			else
				healthBarSize = HEALTHBAR_SIZE
			end

			if TenFootInterface:IsEnabled() then
				healthBarSize = HEALTHBAR_SIZE_TENFOOT
			end
		else
			healthBarSize = HEALTHBAR_SIZE
			if TenFootInterface:IsEnabled() then
				healthBarSize = HEALTHBAR_SIZE_TENFOOT
			end
		end
	end

	local healthBarOffset = HEALTHBAR_OFFSET
	if TenFootInterface:IsEnabled() then
		healthBarOffset = HEALTHBAR_OFFSET_TENFOOT
	end

	local healthBarBase
	local healthBar
	local sliceCenter
	if UseUpdatedHealthBar then
		healthBarBase = "rbxasset://textures/ui/TopBar/HealthBarBaseTV.png"
		healthBar = "rbxasset://textures/ui/TopBar/HealthBarTV.png"
		sliceCenter = Rect.new(8, 8, 9, 9)
	else
		healthBarBase = "rbxasset://textures/ui/TopBar/HealthBarBase.png"
		healthBar = "rbxasset://textures/ui/TopBar/HealthBar.png"
		sliceCenter = Rect.new(3, 3, 4, 4)
		if TenFootInterface:IsEnabled() then
			healthBarBase = "rbxasset://textures/ui/TopBar/HealthBarBaseTV.png"
			healthBar = "rbxasset://textures/ui/TopBar/HealthBarTV.png"
			sliceCenter = Rect.new(8, 8, 9, 9)
		end
	end

	local onAreaChanged = function(rbx)
		if not UseUpdatedHealthBar then
			if (FFlagTopBarSignalizeHealthBar and self.healthVisible or not FFlagTopBarSignalizeHealthBar and healthVisible) and rbx then
				if FFlagTopBarSignalizeKeepOutAreas then
					self.keepOutAreasStore.setKeepOutArea(Constants.HealthBarKeepOutAreaId, rbx.AbsolutePosition, rbx.AbsoluteSize)
				else
					self.props.setKeepOutArea(Constants.HealthBarKeepOutAreaId, rbx.AbsolutePosition, rbx.AbsoluteSize)
				end
			else
				if FFlagTopBarSignalizeKeepOutAreas then 
					self.keepOutAreasStore.removeKeepOutArea(Constants.HealthBarKeepOutAreaId)
				else
					self.props.removeKeepOutArea(Constants.HealthBarKeepOutAreaId)
				end
			end
		end
	end

	if FFlagEnableChromeBackwardsSignalAPI then
		if self.rootRef.current then
			onAreaChanged(self.rootRef.current)
		end
	end

	local healthBarColor = if FFlagTopBarSignalizeHealthBar then self.healthPercent:map(getHealthBarColor) else getHealthBarColor(healthPercent)
	return Roact.createElement("Frame", {
		AnchorPoint = if UseUpdatedHealthBar then Vector2.new(1, 0) else nil,
		Position = if UseUpdatedHealthBar then UDim2.new(1, 0, 0, 0) else nil,
		Visible = if FFlagTopBarSignalizeHealthBar then self.healthVisible else healthVisible,
		BackgroundTransparency = 1,
		Size = if FFlagTopBarSignalizeScreenSize 
			then self.healthbarSizeBinding:map(function(healthBarSize)
				return UDim2.new(healthBarSize.X, UDim.new(1, 0))
			end) 
			else UDim2.new(healthBarSize.X, UDim.new(1, 0)),
		LayoutOrder = self.props.layoutOrder,
		[Roact.Change.AbsoluteSize] = if FFlagEnableChromeBackwardsSignalAPI then onAreaChanged else nil,
		[Roact.Change.AbsolutePosition] = if FFlagEnableChromeBackwardsSignalAPI then onAreaChanged else nil,
		[Roact.Ref] = self.rootRef,
	}, {
		Padding = not ChromeEnabled and Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, healthBarOffset),
		}) or nil,

		HealthBar = Roact.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			Image = healthBarBase,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = sliceCenter,
			Size = if FFlagTopBarSignalizeScreenSize then self.healthbarSizeBinding else healthBarSize,
			Position = UDim2.fromScale(0, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
		}, {
			Fill = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Image = healthBar,
				ImageColor3 = healthBarColor,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = sliceCenter,
				Size = if FFlagTopBarSignalizeHealthBar then self.healthPercent:map(function(healthPercent) 
					return UDim2.fromScale(healthPercent, 1)
				end) else UDim2.fromScale(healthPercent, 1),
			}),
		}),
	})
end

function HealthBar:render()
	if FFlagTopBarSignalizeHealthBar then
		return if self.state.mountHealthBar then self:renderHealth() else nil
	else
		return self:renderHealth()
	end
end

local function mapStateToProps(state)
	return {
		screenSize = if FFlagTopBarSignalizeScreenSize then nil else state.displayOptions.screenSize,
		health = if FFlagTopBarSignalizeHealthBar then nil else state.health.currentHealth,
		maxHealth = if FFlagTopBarSignalizeHealthBar then nil else state.health.maxHealth,
		healthEnabled = if FFlagTopBarSignalizeHealthBar then nil else state.coreGuiEnabled[Enum.CoreGuiType.Health],
	}
end

local function mapDispatchToProps(dispatch)
	if FFlagTopBarSignalizeKeepOutAreas then 
		return {} 
	end
	return {
		setKeepOutArea = function(id, position, size)
			return dispatch(SetKeepOutArea(id, position, size))
		end,
		removeKeepOutArea = function(id)
			return dispatch(RemoveKeepOutArea(id))
		end,
	}
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, if FFlagTopBarSignalizeKeepOutAreas then nil else mapDispatchToProps)(HealthBar)
