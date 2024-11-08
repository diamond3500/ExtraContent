local CorePackages = game:GetService("CorePackages")
local useCurvedPanel = game:GetEngineFeature("CurvedSurfaceGuisEnabled")
local CoreGui = game:GetService("CoreGui")
local UIManagerRoot = script.Parent
local Constants = require(UIManagerRoot.Constants)
local SpatialUIType = Constants.SpatialUIType
local LuauPolyfill = require(CorePackages.Packages.LuauPolyfill)
local Object = LuauPolyfill.Object

local DEFAULT_VR_PANEL_SIZE_X = 10
local DEFAULT_VR_PANEL_SIZE_Y = 10

local defaultPanelCompatProps: Constants.PanelCompatProps = {
	spatialPanelProps = nil,
	screenGuiProps = nil,
	type = SpatialUIType.ScreenUI,
}

local defaultScreenGuiProps: Constants.ScreenGuiProps = {
	Name = "ScreenGui",
	ResetOnSpawn = false,
	DisplayOrder = 0,
	ZIndexBehavior = nil,
}

local defaultSpatialPanelProps: Constants.SpatialUIProps = {
	name = "",
	partSize = Vector2.new(DEFAULT_VR_PANEL_SIZE_X, DEFAULT_VR_PANEL_SIZE_Y),
	virtualScreenSize = Vector2.new(DEFAULT_VR_PANEL_SIZE_X, DEFAULT_VR_PANEL_SIZE_Y),
	cframe = CFrame.new(0, 0, 0),
	alwaysOnTop = true,
	parent = workspace,
	hidden = false,
	curvature = 1, -- On by default to obtain anti-aliasing, disable with 0
	transparency = 1,
}

local function createPanelPart(spatialPanelProps: Constants.SpatialUIProps)
	local part = Instance.new("Part")
	part.Parent = if spatialPanelProps.parent then spatialPanelProps.parent else workspace
	part.Name = spatialPanelProps.name .. "_Part"
	part.CFrame = spatialPanelProps.cframe
	part.Size = Vector3.new(spatialPanelProps.partSize.X, spatialPanelProps.partSize.Y, 0.05)
	part.Transparency = spatialPanelProps.transparency
	part.Color = Color3.new(1, 1, 1)
	part.CanCollide = false
	part.CanTouch = false
	part.Anchored = true
	return part
end

-- Util function for creating SpatialUI compatible panels to be used by UIManager
return function(props: Constants.PanelCompatProps): Constants.CompatPanel?
	local props: Constants.PanelCompatProps = Object.assign({}, defaultPanelCompatProps, props)
	if props.type == SpatialUIType.SpatialUIPartOnly then
		local spatialPanelProps = Object.assign({}, defaultSpatialPanelProps, props.spatialPanelProps)
		local panelPart = createPanelPart(spatialPanelProps)
		return {
			type = props.type,
			panelObject = panelPart,
		} :: Constants.CompatPanel
	elseif props.type == SpatialUIType.SpatialUI then
		local spatialPanelProps = Object.assign({}, defaultSpatialPanelProps, props.spatialPanelProps)
		local panelPart = createPanelPart(spatialPanelProps)
		local surfaceGui = Instance.new("SurfaceGui", CoreGui)
		surfaceGui.Name = spatialPanelProps.Name .. "_SurfaceGui"
		surfaceGui.Enabled = not spatialPanelProps.hidden
		surfaceGui.CanvasSize = spatialPanelProps.virtualScreenSize
		surfaceGui.AlwaysOnTop = spatialPanelProps.alwaysOnTop
		surfaceGui.Shape = if useCurvedPanel and (spatialPanelProps.curvature :: number) ~= 0
			then Enum.SurfaceGuiShape.CurvedHorizontally
			else Enum.SurfaceGuiShape.Flat
		surfaceGui.HorizontalCurvature = if useCurvedPanel then spatialPanelProps.curvature else 0
		surfaceGui.Active = true
		surfaceGui.Adornee = panelPart
		surfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		surfaceGui.LightInfluence = 0
		surfaceGui.ZOffset = 0
		surfaceGui.Face = Enum.NormalId.Back
		return {
			type = props.type,
			panelObject = surfaceGui,
		} :: Constants.CompatPanel
	elseif props.type == SpatialUIType.ScreenUI then
		local screenGuiProps: Constants.ScreenGuiProps = Object.assign({}, defaultScreenGuiProps, props.screenGuiProps)
		local screenGui = Instance.new("ScreenGui", CoreGui)
		screenGui.Name = screenGuiProps.Name
		screenGui.ResetOnSpawn = screenGuiProps.ResetOnSpawn
		screenGui.DisplayOrder = screenGuiProps.DisplayOrder
		if screenGuiProps.ZIndexBehavior then
			screenGui.ZIndexBehavior = screenGuiProps.ZIndexBehavior
		end
		return {
			type = props.type,
			panelObject = screenGui,
		} :: Constants.CompatPanel
	else
		print("Invalid panel type: " .. tostring(props.type))
		return nil
	end
end
