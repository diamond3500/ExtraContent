local Chrome = script:FindFirstAncestor("Chrome")

local CorePackages = game:GetService("CorePackages")

local ChromeService = require(Chrome.Service)
local CommonIcon = require(Chrome.Integrations.CommonIcon)

local GetFFlagEnableChromeMusicIntegration =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFFlagEnableChromeMusicIntegration
local GetFStringChromeMusicIntegrationLabel =
	require(CorePackages.Workspace.Packages.SharedFlags).GetFStringChromeMusicIntegrationLabel

-- MUS-1215 TODO: Allow the whole Songbird integration to be disabled by creators
return if GetFFlagEnableChromeMusicIntegration()
	then ChromeService:register({
		initialAvailability = ChromeService.AvailabilitySignal.Available,
		id = "music_entrypoint",
		label = GetFStringChromeMusicIntegrationLabel(),
		activated = function(self)
			ChromeService:toggleCompactUtility("music_utility")
		end,
		components = {
			Icon = function(props)
				-- MUS-1201 TODO: Add final icon
				return CommonIcon("icons/controls/emoteOff")
			end,
		},
	})
	else nil