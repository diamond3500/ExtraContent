-- Define an enum type for spatial UIs
export type SpatialUITypeValue = "ScreenUI" | "SpatialUI" | "SpatialUIPartOnly" | "SpatialUIRoact"
export type SpatialUIGroupValue = "MainUIGroup" | "WristUIGroup"
export type PanelTypeValue = "Chat" | "RobloxGui" | "BottomBar"

export type SpatialUIProps = {
	name: string,
	-- Size of the "virtual screen" the GUI thinks it is rendered on
	virtualScreenSize: Vector2,
	-- Size of the screen in the 3D space
	partSize: Vector2,
	-- Is the panel static in the world, following the wrist, following the head?
	cframe: CFrame, -- cframe of the panel
	alwaysOnTop: boolean, -- should the panel render on top of geometry
	parent: Instance, -- parent object, e.g. folder of parts
	hidden: boolean, -- whether to hide the panel
	curvature: number,
	transparency: number,
}

export type ScreenGuiProps = {
	Name: string,
	ResetOnSpawn: boolean,
	DisplayOrder: number,
	ZIndexBehavior: Enum.ZIndexBehavior?,
}

export type PanelCompatProps = {
	spatialPanelProps: SpatialUIProps?,
	screenGuiProps: ScreenGuiProps?,
	type: SpatialUITypeValue,
}

export type CompatPanel = {
	type: SpatialUITypeValue,
	panelObject: Instance,
}

local SpatialUIType = {
	ScreenUI = "ScreenUI" :: SpatialUITypeValue,
	SpatialUI = "SpatialUI" :: SpatialUITypeValue,
	SpatialUIPartOnly = "SpatialUIPartOnly" :: SpatialUITypeValue,
	SpatialUIRoact = "SpatialUIRoact" :: SpatialUITypeValue,
}

-- Define an enum type for panel types
local PanelType = {
	Chat = "Chat" :: PanelTypeValue,
	RobloxGui = "RobloxGui" :: PanelTypeValue,
	BottomBar = "BottomBar" :: PanelTypeValue,
}

return {
	SpatialUIType = SpatialUIType,
	PanelType = PanelType,
}
