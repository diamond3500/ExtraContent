local Container = script.Parent
local App = Container.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)
local t = require(Packages.t)

local RetrievalStatus = require(UIBlox.App.Loading.Enum.RetrievalStatus)
local LoadingStatePage = require(UIBlox.App.Container.LoadingStatePage)
local FailedStatePage = require(UIBlox.App.Container.FailedStatePage)

local LoadingStateContainer = Roact.PureComponent:extend("LoadingStateContainer")

LoadingStateContainer.validateProps = t.strictInterface({
	-- dataStatus determines the loading state
	dataStatus = RetrievalStatus.isEnumValue,
	-- renderOnLoaded is what is loaded when loading state is loaded
	renderOnLoaded = t.callback,
	-- renderOnFailed is rendered if dataStatus is RetrievalStatus.Failed
	renderOnFailed = t.optional(t.callback),
	-- onRetry renders a button callback for the default reload button failed state
	onRetry = t.optional(t.callback),
	-- renderOnLoading is called to overwrite the default loading page
	renderOnLoading = t.optional(t.callback),
	-- renderOnEmpty is rendered if dataStatus is RetrievalStatus.NotStarted
	renderOnEmpty = t.optional(t.callback),
})

function LoadingStateContainer:init()
	self.statePages = {
		[RetrievalStatus.NotStarted] = function()
			if self.props.renderOnEmpty then
				return self.props.renderOnEmpty()
			else
				if self.props.renderOnLoading then
					return self.props.renderOnLoading()
				else
					return Roact.createElement(LoadingStatePage)
				end
			end
		end,
		[RetrievalStatus.Fetching] = function()
			if self.props.renderOnLoading then
				return self.props.renderOnLoading()
			else
				return Roact.createElement(LoadingStatePage)
			end
		end,
		[RetrievalStatus.Failed] = function()
			if self.props.renderOnFailed then
				return self.props.renderOnFailed()
			else
				return Roact.createElement(FailedStatePage, {
					onRetry = self.props.onRetry,
				})
			end
		end,
		[RetrievalStatus.Done] = function()
			return self.props.renderOnLoaded()
		end,
	}
end

function LoadingStateContainer:render()
	return self.statePages[self.props.dataStatus]()
end

return LoadingStateContainer
