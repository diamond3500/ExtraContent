local Root = script:FindFirstAncestor("ChromeShared")

local CorePackages = game:GetService("CorePackages")

local React = require(CorePackages.Packages.React)
local ReactOtter = require(CorePackages.Packages.ReactOtter)
local ReactUtils = require(CorePackages.Packages.ReactUtils)
local Songbird = require(CorePackages.Workspace.Packages.Songbird)
local UIBlox = require(CorePackages.Packages.UIBlox)
local Foundation = require(CorePackages.Packages.Foundation)

local ChromeService = require(Root.Service)
local IntegrationRow = require(Root.Peek.IntegrationRow)
local useChromePeekId = require(Root.Hooks.useChromePeekId)
local useChromePeekItems = require(Root.Hooks.useChromePeekItems)
local Types = require(Root.Service.Types)
local ViewportUtil = require(Root.Service.ViewportUtil)
-- APPEXP-2053 TODO: Remove all use of RobloxGui from ChromeShared
local shouldUseSmallPeek = require(Root.Parent.Integrations.MusicUtility.shouldUseSmallPeek)

local useMusicPeek = Songbird.useMusicPeek
local usePrevious = ReactUtils.usePrevious
local useEffect = React.useEffect
local useRef = React.useRef
local useCallback = React.useCallback

local GetFFlagDecoupleChromePeekFromCoreScripts =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagDecoupleChromePeekFromCoreScripts

local useStyle = UIBlox.Core.Style.useStyle
local ControlState = Foundation.Enums.ControlState
local StateLayerAffordance = Foundation.Enums.StateLayerAffordance

local SPRING_CONFIG: ReactOtter.SpringOptions = {
	damping = 20,
	mass = 1,
	stiffness = 100,
}

local function lerp(a: number, b: number, t: number)
	return a + (b - a) * t
end

if GetFFlagDecoupleChromePeekFromCoreScripts() then
	-- FFlagDecoupleChromePeekFromCoreScripts cleanup: Prepend `local` to the function
	function shouldUseSmallPeek()
		local isSmallTouchScreen = ViewportUtil.isSmallTouchScreen()
		local isMobileDevice = ViewportUtil.mobileDevice:get()
		local shouldShowSmallPeek = isMobileDevice and isSmallTouchScreen

		return shouldShowSmallPeek
	end
end

export type Props = {
	layoutOrder: number,
}

local function Peek(props: Props): React.Node?
	local style = useStyle()
	local peekItemsRef = useRef(nil :: Types.PeekList?)
	local peekItems = useChromePeekItems()
	local peekId = useChromePeekId()
	local prevPeekId = usePrevious(peekId)

	local onComplete = useCallback(function(alpha)
		if alpha == 0 then
			peekItemsRef.current = nil
		end
	end, {})

	local binding, setGoal = ReactOtter.useAnimatedBinding(0, onComplete)

	local onStateChanged = useCallback(function(state)
		if state == ControlState.Pressed or state == ControlState.Hover then
			ChromeService:lockCurrentPeek()
		else
			ChromeService:unlockCurrentPeek()
		end
	end, {})

	useEffect(function()
		if peekId ~= prevPeekId then
			if peekItems and #peekItems > 0 and not peekItemsRef.current then
				peekItemsRef.current = peekItems
				setGoal(ReactOtter.spring(1, SPRING_CONFIG))
			else
				setGoal(ReactOtter.spring(0, SPRING_CONFIG))
			end
		end
	end, { peekId, prevPeekId, peekItems } :: { unknown })

	useMusicPeek(ChromeService, shouldUseSmallPeek())

	if peekItemsRef.current then
		return React.createElement(Foundation.View, {
			Size = UDim2.fromScale(1, 1),
			LayoutOrder = props.layoutOrder,
			stateLayer = {
				affordance = StateLayerAffordance.None,
			},
			onStateChanged = onStateChanged,
		}, {
			PeekContainer = React.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				Position = binding:map(function(alpha)
					return UDim2.fromScale(0, lerp(-2, 0, alpha))
				end),
				BackgroundTransparency = 1,
				SelectionGroup = true,
				SelectionBehaviorUp = Enum.SelectionBehavior.Stop,
				SelectionBehaviorLeft = Enum.SelectionBehavior.Stop,
				SelectionBehaviorRight = Enum.SelectionBehavior.Stop,
			}, {
				Layout = React.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),

				PeekPill = React.createElement("Frame", {
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.fromScale(0, 1),
					BorderSizePixel = 0,
					BackgroundColor3 = style.Theme.BackgroundUIContrast.Color,
					BackgroundTransparency = style.Theme.BackgroundUIContrast.Transparency
						* style.Settings.PreferredTransparency,
				}, {
					UICorner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, style.Tokens.Global.Size_100),
					}),

					IntegrationRow = React.createElement(IntegrationRow, {
						integrations = peekItemsRef.current,
					}),
				}),
			}),
		})
	else
		return nil
	end
end

return Peek
