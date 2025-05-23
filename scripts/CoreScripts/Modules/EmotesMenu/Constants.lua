--!nonstrict
local CorePackages = game:GetService("CorePackages")

local enumerate = require(CorePackages.Packages.enumerate)

local EmotesMenu = script.Parent
local Layouts = EmotesMenu.Layouts

local SmallLayout = require(Layouts.Small)
local LargeLayout = require(Layouts.Large)
local TenFootLayout = require(Layouts.TenFoot)

local Constants = {
	EmotesPerPage = 8,
	ErrorDisplayTimeSeconds = 5,

	FallbackLocale = "en-us",

	LocalizationKeys = {
		SelectAnEmote = "InGame.EmotesMenu.SelectAnEmote",
		NoEmotesEquipped = "InGame.EmotesMenu.NoEmotesEquipped",
		EmotesDisabled = "InGame.EmotesMenu.EmotesDisabled",
		VisitShopToGetEmotes = "InGame.EmotesMenu.VisitShopToGetEmotes",

		ErrorMessages = {
			NotSupported = "InGame.EmotesMenu.ErrorMessageNotSupported",
			R15Only = "InGame.EmotesMenu.ErrorMessageR15Only",
			SwitchToR15 = "InGame.EmotesMenu.ErrorMessageSwitchToR15",
			NoMatchingEmote = "InGame.EmotesMenu.ErrorMessageNoMatchingEmote",
			TemporarilyUnavailable = "InGame.EmotesMenu.ErrorMessageTemporarilyUnavailable",
			AnimationPlaying = "InGame.EmotesMenu.ErrorMessageAnimationPlaying",
		},
	},

	ErrorTypes = {
		NotSupported = "NotSupported",
		R15Only = "R15Only",
		SwitchToR15 = "SwitchToR15",
		NoMatchingEmote = "NoMatchingEmote",
		TemporarilyUnavailable = "TemporarilyUnavailable",
		AnimationPlaying = "AnimationPlaying",
	},

	EmotesImage = "rbxthumb://type=Asset&id=%d&w=420&h=420",
	EmotesMenuZIndex = 50,

	ErrorFrameBorderSize = 0,
	ErrorFrameBackgroundTransparency = 0.3,

	WheelBackgroundTransparency = 0.4,

	TextPadding = 10,

	SegmentsStartRotation = -90,

	-- Ratio of diameter of inner circle to emote wheel image width
	InnerCircleSizeRatio = 0.45,

	-- Size of slot numbers relative to emote wheel size
	SlotNumberSize = 0.1,
	ImageOutsidePadding = 0.025,

	GradientTransparency = 0.5,

	CursorOverrideName = "EmotesMenuCursorOverride",

	GamepadInputTypes = {
		[Enum.UserInputType.Gamepad1] = true,
		[Enum.UserInputType.Gamepad2] = true,
		[Enum.UserInputType.Gamepad3] = true,
		[Enum.UserInputType.Gamepad4] = true,
		[Enum.UserInputType.Gamepad5] = true,
		[Enum.UserInputType.Gamepad6] = true,
		[Enum.UserInputType.Gamepad7] = true,
		[Enum.UserInputType.Gamepad8] = true,
	},

	-- User will leave the menu if it's open with any of these inputs but the input won't be sunk
	LeaveMenuNoSinkInputs = {
		Enum.KeyCode.W,
		Enum.KeyCode.A,
		Enum.KeyCode.S,
		Enum.KeyCode.D,

		Enum.KeyCode.Up,
		Enum.KeyCode.Left,
		Enum.KeyCode.Down,
		Enum.KeyCode.Right,

		Enum.KeyCode.Space,

		Enum.KeyCode.Tab,
		Enum.KeyCode.Slash,
		Enum.KeyCode.Backquote,
	},

	EmoteSlotKeys = {
		Enum.KeyCode.One,
		Enum.KeyCode.Two,
		Enum.KeyCode.Three,
		Enum.KeyCode.Four,
		Enum.KeyCode.Five,
		Enum.KeyCode.Six,
		Enum.KeyCode.Seven,
		Enum.KeyCode.Eight,
	},

	EmoteMenuOpenKey = Enum.KeyCode.Period,
	EmoteMenuOpenButton = Enum.KeyCode.DPadDown,

	EmoteMenuCloseKey = Enum.KeyCode.Escape,
	EmoteMenuCloseButton = Enum.KeyCode.ButtonB,
	EmoteMenuCloseButtonSecondary = Enum.KeyCode.ButtonStart,

	EmoteMenuNavUpButton = Enum.KeyCode.DPadUp,
	EmoteMenuNavDownButton = Enum.KeyCode.DPadDown,
	EmoteMenuPlayEmoteButton = Enum.KeyCode.DPadRight,

	SelectionThumbstick = Enum.KeyCode.Thumbstick1,
	ThumbstickThreshold = 0.8,

	PlayEmoteButton = Enum.KeyCode.ButtonA,

	ToggleMenuAction = "EmotesMenuToggleAction",
	CloseMenuAction = "EmotesMenuCloseAction",
	OpenMenuAction = "EmotesMenuOpenAction",
	EmoteSelectionAction = "EmotesMenuSelectionAction",
	ActivateEmoteSlotAction = "EmotesMenuActivateEmoteSlotAction",
	PlaySelectedAction = "EmotesMenuPlaySelectedAction",
	LeaveMenuDontSinkInputAction = "EmotesMenuLeaveMenuDontSinkInputAction",
	ShiftFocusUpAction = "EmotesMenuShiftFocusUpAction",
	ShiftFocusDownAction = "EmotesMenuShiftFocusDownAction",
	VirtualCursorSinkAction = "EmotesMenuVirtualCursorSinkAction",

	-- Emotes Menu can use up to 90% of the screen horizontally and 75% vertically
	ScreenAvailable = UDim2.new(0.9, 0, 0.75, 0),

	-- Use the Large layout if the screen is larger than this size
	-- Values taken from isSmallTouchScreen in Utility module
	-- 500x500 to be consistant with what is considered large/small by the touch jump button (for proper ui positioning)
	SmallScreenMaxSize = Vector2.new(700, 500),

	Layout = {
		Small = 0,
		Large = 1,
		TenFoot = 2,
	},

	Colors = {
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},

	OffScreen = enumerate("OffScreen", {
		"Top",
		"Bottom",
	}),
}

Constants.Layouts = {
	[Constants.Layout.Small] = SmallLayout,

	[Constants.Layout.Large] = LargeLayout,

	[Constants.Layout.TenFoot] = TenFootLayout,
}

local function makeTableConstant(name, tbl)
	setmetatable(tbl, {
		__newindex = function() end,

		__index = function(t, index)
			error(name .. " table has no index: " .. tostring(index), 2)
		end,
	})
end

local constantTables = {
	["Constants"] = Constants,

	["Constants.Colors"] = Constants.Colors,
	["Constants.Layout"] = Constants.Layout,
	["Constants.LeaveMenuNoSinkInputs"] = Constants.LeaveMenuNoSinkInputs,

	["Constants.LocalizationKeys"] = Constants.LocalizationKeys,
	["Constants.LocalizationKeys.ErrorMessages"] = Constants.LocalizationKeys.ErrorMessages,

	["Constants.Layouts"] = Constants.Layouts,
	["Constants.Layouts.Small"] = Constants.Layouts[Constants.Layout.Small],
	["Constants.Layouts.Large"] = Constants.Layouts[Constants.Layout.Large],
	["Constants.Layouts.TenFoot"] = Constants.Layouts[Constants.Layout.TenFoot],
}

for name, tbl in pairs(constantTables) do
	makeTableConstant(name, tbl)
end

return Constants
