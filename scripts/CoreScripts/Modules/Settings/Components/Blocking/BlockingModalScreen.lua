--!nonstrict
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Packages.Roact)
local t = require(CorePackages.Packages.t)

local BlockingModalContainer = require(script.Parent.BlockingModalContainer)

local renderWithCoreScriptsStyleProvider = require(RobloxGui.Modules.Common.renderWithCoreScriptsStyleProvider)
local FocusNavigationUtils = require(CorePackages.Workspace.Packages.FocusNavigationUtils)
local FocusNavigationCoreScriptsWrapper = FocusNavigationUtils.FocusNavigationCoreScriptsWrapper
local FocusRoot = FocusNavigationUtils.FocusRoot
local FocusNavigableSurfaceIdentifierEnum = FocusNavigationUtils.FocusNavigableSurfaceIdentifierEnum

local GetFFlagWrapBlockModalScreenInProvider = require(RobloxGui.Modules.Flags.GetFFlagWrapBlockModalScreenInProvider)
local FFlagCSFocusWrapperRefactor = require(CorePackages.Workspace.Packages.SharedFlags).FFlagCSFocusWrapperRefactor

local BlockingModalScreen = Roact.PureComponent:extend("BlockingModalScreen")

local SELECTION_GROUP_NAME = "BlockingModalScreen"

BlockingModalScreen.validateProps = t.interface({
	closeModal = t.callback,
	player = t.interface({
		DisplayName = t.string,
		Name = t.string,
		UserId = t.number,
	}),
	translator = t.optional(t.table),
	source = t.optional(t.string),
})

function BlockingModalScreen:render()
	local blockingModalContainer = Roact.createElement(BlockingModalContainer, self.props)
	if GetFFlagWrapBlockModalScreenInProvider() then
		blockingModalContainer = Roact.createElement(
			if FFlagCSFocusWrapperRefactor then FocusRoot else FocusNavigationCoreScriptsWrapper,
			if FFlagCSFocusWrapperRefactor
				then {
					surfaceIdentifier = FocusNavigableSurfaceIdentifierEnum.CentralOverlay,
					isIsolated = true,
					isAutoFocusRoot = true,
				}
				else {
					selectionGroupName = SELECTION_GROUP_NAME .. tostring(self.props.player.UserId),
					focusNavigableSurfaceIdentifier = FocusNavigableSurfaceIdentifierEnum.CentralOverlay,
				},
			{
				BlockingModalContainerWrapper = blockingModalContainer,
			}
		)
	end
	local children = {
		Roact.createElement(Roact.Portal, {
			target = CoreGui,
		}, {
			BlockingModalScreen = Roact.createElement("ScreenGui", {
				IgnoreGuiInset = true,
				AutoLocalize = false,
				DisplayOrder = 6,
			}, {
				BlockingModalContainer = blockingModalContainer,
			}),
		}),
	}
	return renderWithCoreScriptsStyleProvider(children)
end

return BlockingModalScreen
