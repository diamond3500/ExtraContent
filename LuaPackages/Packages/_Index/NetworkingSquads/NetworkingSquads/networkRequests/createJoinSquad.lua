--!strict
local SQUAD_URL = require(script.Parent.Parent.SQUAD_URL)
local networkingSquadTypes = require(script.Parent.Parent.networkingSquadTypes)

return function(config: networkingSquadTypes.Config)
	local roduxNetworking: any = config.roduxNetworking

	local mockResponse
	local JoinSquad = roduxNetworking.POST(
		{ Name = "JoinSquad" },
		function(requestBuilder, request: networkingSquadTypes.JoinSquadRequest)
			if config.useMockedResponse then
				mockResponse = {
					responseBody = {
						squad = {
							squadId = request.squadId,
							initiatorId = 3447631062,
							createdUtc = os.clock() * 1000,
							channelId = request.channelId,
							members = {
								{
									userId = 3447631062,
									rank = 0,
								},
								{
									userId = 2591622000,
									rank = 1,
								},
								{
									userId = 3447649029,
									rank = 2,
								},
								{
									userId = 3447641701,
									rank = 3,
								},
								{
									userId = 3447635964,
									rank = 4,
								},
								{
									userId = 3447642362,
									rank = 5,
								},
							},
						},
					},
				}
			end

			return requestBuilder(SQUAD_URL):path("v1"):path("squad"):body({
				squadId = request.squadId,
			})
		end
	)

	if config.useMockedResponse then
		JoinSquad.Mock.clear()
		JoinSquad.Mock.reply(function()
			return mockResponse
		end)
	end

	return JoinSquad
end
