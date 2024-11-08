local Chrome = script:FindFirstAncestor("Chrome")

local ViewportUtil = require(Chrome.Service.ViewportUtil)

local function shouldUseSmallPeek()
	local isSmallTouchScreen = ViewportUtil.isSmallTouchScreen()
	local isMobileDevice = ViewportUtil.mobileDevice:get()
	local shouldShowSmallPeek = isMobileDevice and isSmallTouchScreen

	return shouldShowSmallPeek
end

return shouldUseSmallPeek
