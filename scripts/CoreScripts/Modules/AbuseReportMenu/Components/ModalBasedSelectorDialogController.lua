local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

local root = script:FindFirstAncestor("AbuseReportMenu")
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Packages.Roact)

local Constants = require(root.Components.Constants)
local ModalBaseSelectorDialog = require(root.Components.ModalBaseSelectorDialog)

local GetFFlagAbuseReportMenuConsoleSupportRefactor =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagAbuseReportMenuConsoleSupportRefactor

local elements: any = {
	modalSelectorHandle = nil,
	modalSelectorFrame = nil,
	modalSelectorScreenGui = nil,
}

local function unmountModalSelector()
	if elements.modalSelectorHandle ~= nil then
		Roact.unmount(elements.modalSelectorHandle)
		elements.modalSelectorHandle = nil
	end
	if elements.modalSelectorScreenGui ~= nil then
		elements.modalSelectorFrame.Parent = nil
		elements.modalSelectorFrame = nil
		elements.modalSelectorScreenGui = nil
	end
end

local function mountModalSelector(viewportHeight, viewportWidth, selections, onSelect, onClose)
	local topCornerInset, _ = GuiService:GetGuiInset()
	if not elements.modalSelectorScreenGui then
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "ModalSelectorDialogGui"
		screenGui.DisplayOrder = 7
		screenGui.Enabled = true
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.Parent = if GetFFlagAbuseReportMenuConsoleSupportRefactor()
			then CoreGui:FindFirstChild(Constants.AbuseReportMenuPlaceholderFrame, true)
			else CoreGui:FindFirstChild(Constants.AbuseReportMenuRootName, true)

		elements.modalSelectorScreenGui = screenGui

		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.Position = UDim2.new(0, 0, 0, -topCornerInset.Y)
		frame.Size = UDim2.new(1, 0, 1, topCornerInset.Y)
		frame.Parent = elements.modalSelectorScreenGui

		elements.modalSelectorFrame = frame
	end
	local dialog = Roact.createElement(ModalBaseSelectorDialog, {
		isShown = true,
		cellData = selections,
		viewportHeight = viewportHeight,
		viewportWidth = viewportWidth,
		onSelect = onSelect,
		onClose = onClose,
	})

	elements.modalSelectorHandle = Roact.mount(dialog, elements.modalSelectorFrame, "ModalSelectorDialog")
end

return {
	mountModalSelector = mountModalSelector,
	unmountModalSelector = unmountModalSelector,
}
