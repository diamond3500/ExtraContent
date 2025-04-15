local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local React = require(Packages.React)
local Dash = require(Packages.Dash)

local View = require(Foundation.Components.View)
local Button = require(Foundation.Components.Button)
local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize
local ButtonVariant = require(Foundation.Enums.ButtonVariant)
local FillBehavior = require(Foundation.Enums.FillBehavior)
type FillBehavior = FillBehavior.FillBehavior

local Flags = require(Foundation.Utility.Flags)

return {
	summary = "Button",
	stories = Dash.map(ButtonVariant, function(variant)
		return {
			name = variant,
			story = function(props)
				local controls = props.controls
				Flags.FoundationButtonEnableLoadingState = controls.enableLoadingState
				Flags.FoundationEnableNewButtonSizes = controls.enableNewButtonSizes

				return React.createElement(
					View,
					{
						tag = "row gap-medium auto-y size-full-0 align-y-center",
					},
					Dash.map(
						{ InputSize.Large, InputSize.Medium, InputSize.Small, InputSize.XSmall } :: { InputSize },
						function(size)
							return React.createElement(Button, {
								icon = if controls.icon == "" then nil else props.controls.icon,
								text = controls.text,
								variant = variant,
								isLoading = controls.isLoading,
								onActivated = function()
									print(`{variant}Button activated`)
								end,
								isDisabled = controls.isDisabled,
								size = size,
								fillBehavior = if controls.fillBehavior == React.None
									then nil
									else controls.fillBehavior,
								inputDelay = controls.inputDelay,
							})
						end
					)
				)
			end,
		}
	end),
	controls = {
		icon = {
			"icons/placeholder/placeholderOn",
			"icons/common/robux",
			"icons/common/play",
			"",
		},
		text = "Lorem ipsum",
		isDisabled = false,
		isLoading = false,
		fillBehavior = {
			React.None,
			FillBehavior.Fit,
			FillBehavior.Fill,
		} :: { FillBehavior },
		inputDelay = 0,
		enableLoadingState = Flags.FoundationButtonEnableLoadingState,
		enableNewButtonSizes = Flags.FoundationEnableNewButtonSizes,
	},
}
