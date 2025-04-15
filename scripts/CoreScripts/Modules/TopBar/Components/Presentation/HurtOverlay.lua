local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local Roact = require(CorePackages.Packages.Roact)
local RoactRodux = require(CorePackages.Packages.RoactRodux)
local t = require(CorePackages.Packages.t)
local Otter = require(CorePackages.Packages.Otter)

local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local CachedPolicyService = require(CorePackages.Workspace.Packages.CachedPolicyService)

local Components = script.Parent.Parent
local TopBar = Components.Parent
local Constants = require(TopBar.Constants)

local FFlagMountCoreGuiHealthBar = require(TopBar.Flags.FFlagMountCoreGuiHealthBar)

local MOTOR_OPTIONS = {
	frequency = 0.75,
	dampingRatio = 1,
}

local RED_OVERLAY_COLOR = Color3.fromRGB(187, 0, 4)
local WHITE_OVERLAY_COLOR = Color3.new(1, 1, 1)

local HurtOverlay = Roact.PureComponent:extend("HurtOverlay")

HurtOverlay.validateProps = t.strictInterface({
	healthEnabled = if FFlagMountCoreGuiHealthBar then nil else t.boolean,
	health = t.number,
	maxHealth = t.number,
	isDead = t.boolean,
})

function HurtOverlay:init()
	self.state = {
		isAnimating = false,
	}

	self.animationBinding, self.animationBindingUpdate = Roact.createBinding(0)

	self.positionBinding = self.animationBinding:map(function(animation)
		return UDim2.new(-10 * animation, 0, -10 * animation, 0)
	end)
	self.sizeBinding = self.animationBinding:map(function(animation)
		return UDim2.new(1 + 19 * animation, 0, 1 + 19 * animation, 0)
	end)

	self.motor = Otter.createSingleMotor(0)
	self.motor:onStep(function(value)
		self.animationBindingUpdate(value)
	end)
	self.motor:onComplete(function()
		self:setState({
			isAnimating = false,
		})
	end)

	if FFlagMountCoreGuiHealthBar then
		local function getHealthEnabled()
			return StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health)
		end

		local coreGuiChangedSignalConn = StarterGui.CoreGuiChangedSignal:Connect(
			function(coreGuiType: Enum.CoreGuiType, enabled: boolean)
				if coreGuiType == Enum.CoreGuiType.Health or coreGuiType == Enum.CoreGuiType.All then
					self:setState({
						mount = enabled,
					})
				end
			end
		)
		self:setState({
			mount = getHealthEnabled(),
			coreGuiChangedSignalConn = coreGuiChangedSignalConn,
		})
	end
end

function HurtOverlay:renderOverlay()
	local overlayVisible = nil
	if FFlagMountCoreGuiHealthBar then
		overlayVisible = self.state.isAnimating
	else
		overlayVisible = self.props.healthEnabled and self.state.isAnimating
	end

	local hurtOverlayImage = "rbxasset://textures/ui/TopBar/WhiteOverlayAsset.png"
	local hurtOverlayColor = RED_OVERLAY_COLOR
	if CachedPolicyService:IsSubjectToChinaPolicies() then
		hurtOverlayColor = WHITE_OVERLAY_COLOR
	end

	return Roact.createElement("ImageLabel", {
		Visible = overlayVisible,
		BackgroundTransparency = 1,
		Image = hurtOverlayImage,
		ImageColor3 = hurtOverlayColor,
		Size = self.sizeBinding,
		Position = self.positionBinding,
	})
end

function HurtOverlay:render()
	if FFlagMountCoreGuiHealthBar then
		return if self.state.mount then self:renderOverlay() else nil
	else
		return self:renderOverlay()
	end
end

function HurtOverlay:didUpdate(prevProps, prevState)
	if self.props.health < prevProps.health then
		if not (self.props.isDead and prevProps.isDead) then
			local healthChange = prevProps.health - self.props.health
			if healthChange / self.props.maxHealth >= Constants.HealthPercentForOverlay then
				self.motor:setGoal(Otter.instant(0))
				self.motor:step(0)
				self.motor:setGoal(Otter.spring(1, MOTOR_OPTIONS))
				self.motor:start()
				self:setState({
					isAnimating = true,
				})
			end
		end
	end
end

if FFlagMountCoreGuiHealthBar then
	function HurtOverlay:onUnmount()
		self.state.coreGuiChangedSignalConn:Disconnect()
	end
end

local function mapStateToProps(state)
	if FFlagMountCoreGuiHealthBar then
		return {
			health = state.health.currentHealth,
			maxHealth = state.health.maxHealth,
			isDead = state.health.isDead,
		}
	else
		return {
			health = state.health.currentHealth,
			maxHealth = state.health.maxHealth,
			isDead = state.health.isDead,
			healthEnabled = state.coreGuiEnabled[Enum.CoreGuiType.Health],
		}
	end
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, nil)(HurtOverlay)
