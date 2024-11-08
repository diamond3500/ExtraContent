--!nonstrict
do
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Packages.Roact)
	local UIBlox = require(CorePackages.Packages.UIBlox)
	local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
	local it = JestGlobals.it
	local describe = JestGlobals.describe

	local ScreenshotDialog = require(script.Parent.ScreenshotDialog)
	local ReportAnythingAnalytics = require(script.Parent.Parent.Utility.ReportAnythingAnalytics)

	local fn = JestGlobals.jest.fn

	describe("mount & unmount", function()
		it("should create and destroy without errors", function()
			local element = Roact.createElement(UIBlox.Core.Style.Provider, {}, {
				ScreenshotDialog = Roact.createElement(ScreenshotDialog, {
					screenshot = "",
					finishAnnotationAction = fn(),
					dismissAction = fn(),
					backAction = fn(),
					setAnnotationAreaDimensions = fn(),
					setAnnotationCircleRadius = fn(),
					reportAnythingAnalytics = ReportAnythingAnalytics,
				}),
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)
	end)
end
