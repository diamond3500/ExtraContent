return function()
	local CoreGui = game:GetService("CoreGui")
	local CorePackages = game:GetService("CorePackages")

	local ReactRoblox = require(CorePackages.Packages.ReactRoblox)
	local Roact = require(CorePackages.Roact)
	local Rodux = require(CorePackages.Rodux)
	local RoactRodux = require(CorePackages.RoactRodux)
	local UIBlox = require(CorePackages.UIBlox)
	local JestGlobals = require(CorePackages.JestGlobals)
	local expect = JestGlobals.expect

	local ApolloClientModule = require(CorePackages.Packages.ApolloClient)
	local ApolloProvider = ApolloClientModule.ApolloProvider

	local GraphQLServer = require(CorePackages.Workspace.Packages.GraphQLServer)
	local ApolloClientTestUtils = GraphQLServer.ApolloClientTestUtils
	local mockApolloClient = ApolloClientTestUtils.mockApolloClient

	local UserProfiles = require(CorePackages.Workspace.Packages.UserProfiles)

	local RobloxGui = CoreGui:WaitForChild("RobloxGui")

	local ContactList = RobloxGui.Modules.ContactList

	local Reducer = require(ContactList.Reducer)
	local FriendListContainer = require(ContactList.Components.FriendList.FriendListContainer)

	local dependencies = require(ContactList.dependencies)
	local EnumPresenceType = dependencies.RoduxCall.Enums.PresenceType
	local NetworkingFriends = dependencies.NetworkingFriends
	local NetworkingCall = dependencies.NetworkingCall
	local PresenceModel = dependencies.RoduxPresence.Models.Presence

	beforeAll(function(c: any)
		c.mockFindFriendsFromUserId = function(nextPageCursor)
			return {
				PageItems = {
					[1] = {
						id = "00000000",
					},
					[2] = {
						id = "11111111",
					},
				},
				NextPage = nextPageCursor,
				PreviousPage = nil,
			}
		end

		c.mockGetSuggestedCallees = function()
			return {
				suggestedCallees = {
					{
						userId = "00000000",
						userPresenceType = EnumPresenceType.Online,
						lastLocation = "Roblox Connect",
					},
					{
						userId = "11111111",
						userPresenceType = EnumPresenceType.Offline,
						lastLocation = "Iris (Staging)",
					},
				},
			}
		end

		c.mockApolloClient = mockApolloClient({})
		UserProfiles.TestUtils.writeProfileDataToCache(c.mockApolloClient, {
			["00000000"] = {
				combinedName = "display name 0",
				username = "user name 0",
			},
			["11111111"] = {
				combinedName = "display name 1",
				username = "user name 1",
			},
		})
	end)

	it("should mount and unmount without errors", function(c: any)
		local store = Rodux.Store.new(Reducer, {
			NetworkStatus = {
				["https://friends.roblox.com/v1/users/12345678/friends"] = "Done",
			},
			Presence = {
				byUserId = {
					["00000000"] = PresenceModel.format(PresenceModel.mock()),
					["11111111"] = PresenceModel.format(PresenceModel.mock()),
				},
			},
			Users = {
				byUserId = {
					["00000000"] = {
						id = "00000000",
						username = "user name 0",
						displayName = "display name 0",
						hasVerifiedBadge = false,
					},
					["11111111"] = {
						id = "11111111",
						username = "user name 1",
						displayName = "display name 1",
						hasVerifiedBadge = false,
					},
				},
			},
			Friends = {
				byUserId = {
					["12345678"] = {
						"00000000",
						"11111111",
					},
				},
			},
			Call = {
				suggestedCallees = c.mockGetSuggestedCallees(),
			},
		}, {
			Rodux.thunkMiddleware,
		})

		NetworkingFriends.FindFriendsFromUserId.Mock.clear()
		NetworkingFriends.FindFriendsFromUserId.Mock.reply(function()
			return {
				responseBody = c.mockFindFriendsFromUserId(nil),
			}
		end)

		NetworkingCall.GetSuggestedCallees.Mock.clear()
		NetworkingCall.GetSuggestedCallees.Mock.reply(function()
			return {
				responseBody = c.mockGetSuggestedCallees(),
			}
		end)

		local element = Roact.createElement(RoactRodux.StoreProvider, {
			store = store,
		}, {
			StyleProvider = Roact.createElement(UIBlox.Core.Style.Provider, {}, {
				ApolloProvider = Roact.createElement(ApolloProvider, {
					client = c.mockApolloClient,
				}, {
					FriendListContainer = Roact.createElement(FriendListContainer, {
						isSmallScreen = false,
						dismissCallback = function() end,
						scrollingEnabled = true,
						searchText = "",
					}),
				}),
			}),
		})

		local folder = Instance.new("Folder")
		local instance = Roact.mount(element, folder)
		local containerElement = folder:FindFirstChildOfClass("ScrollingFrame") :: ScrollingFrame
		-- 1 UIListLayout + 1 friend section header + 2 friend items + 1 suggested callees section header + 2 suggested callees
		expect(#containerElement:GetChildren()).toBe(7)
		Roact.unmount(instance)
	end)

	it("should still show friends if friends fetch succeeds but suggested callees fetch fails", function(c: any)
		local store = Rodux.Store.new(Reducer, {
			NetworkStatus = {
				["https://friends.roblox.com/v1/users/12345678/friends"] = "Done",
			},
			Presence = {
				byUserId = {
					["00000000"] = PresenceModel.format(PresenceModel.mock()),
					["11111111"] = PresenceModel.format(PresenceModel.mock()),
				},
			},
			Users = {
				byUserId = {
					["00000000"] = {
						id = "00000000",
						username = "user name 0",
						displayName = "display name 0",
						hasVerifiedBadge = false,
					},
					["11111111"] = {
						id = "11111111",
						username = "user name 1",
						displayName = "display name 1",
						hasVerifiedBadge = false,
					},
				},
			},
			Friends = {
				byUserId = {
					["12345678"] = {
						"00000000",
						"11111111",
					},
				},
			},
			Call = {
				suggestedCallees = {},
			},
		}, {
			Rodux.thunkMiddleware,
		})

		NetworkingFriends.FindFriendsFromUserId.Mock.clear()
		NetworkingFriends.FindFriendsFromUserId.Mock.reply(function()
			return {
				responseBody = c.mockFindFriendsFromUserId(nil),
			}
		end)

		NetworkingCall.GetSuggestedCallees.Mock.clear()
		NetworkingCall.GetSuggestedCallees.Mock.replyWithError(function()
			return "error"
		end)

		local element = Roact.createElement(RoactRodux.StoreProvider, {
			store = store,
		}, {
			StyleProvider = Roact.createElement(UIBlox.Core.Style.Provider, {}, {
				ApolloProvider = Roact.createElement(ApolloProvider, {
					client = c.mockApolloClient,
				}, {
					FriendListContainer = Roact.createElement(FriendListContainer, {
						isSmallScreen = false,
						dismissCallback = function() end,
						scrollingEnabled = true,
						searchText = "",
					}),
				}),
			}),
		})

		local folder = Instance.new("Folder")
		local instance = Roact.mount(element, folder)
		local containerElement = folder:FindFirstChildOfClass("ScrollingFrame") :: ScrollingFrame
		-- 1 UIListLayout + 1 friend section header + 2 friend items
		expect(#containerElement:GetChildren()).toBe(4)
		Roact.unmount(instance)
	end)

	it("should show spinner on first load", function(c: any)
		local store = Rodux.Store.new(Reducer, {}, {
			Rodux.thunkMiddleware,
		})

		NetworkingFriends.FindFriendsFromUserId.Mock.clear()

		local element = Roact.createElement(RoactRodux.StoreProvider, {
			store = store,
		}, {
			StyleProvider = Roact.createElement(UIBlox.Core.Style.Provider, {}, {
				ApolloProvider = Roact.createElement(ApolloProvider, {
					client = c.mockApolloClient,
				}, {
					FriendListContainer = Roact.createElement(FriendListContainer, {
						isSmallScreen = false,
						dismissCallback = function() end,
						scrollingEnabled = true,
						searchText = "",
					}),
				}),
			}),
		})

		local folder = Instance.new("Folder")
		local root = ReactRoblox.createRoot(folder)

		Roact.act(function()
			root:render(element)
		end)

		local containerElement = folder:FindFirstChild("ScrollingFrame", true) :: ScrollingFrame
		expect(containerElement).toBeNull()
		local spinnerElement = folder:FindFirstChild("LoadingSpinner", true)
		expect(spinnerElement).never.toBeNull()

		ReactRoblox.act(function()
			root:unmount()
		end)
	end)

	it("should not show spinner if no more pages", function(c: any)
		local store = Rodux.Store.new(Reducer, {}, {
			Rodux.thunkMiddleware,
		})

		NetworkingFriends.FindFriendsFromUserId.Mock.clear()
		NetworkingFriends.FindFriendsFromUserId.Mock.reply(function()
			return {
				responseBody = c.mockFindFriendsFromUserId(nil),
			}
		end)

		local element = Roact.createElement(RoactRodux.StoreProvider, {
			store = store,
		}, {
			StyleProvider = Roact.createElement(UIBlox.Core.Style.Provider, {}, {
				ApolloProvider = Roact.createElement(ApolloProvider, {
					client = c.mockApolloClient,
				}, {
					FriendListContainer = Roact.createElement(FriendListContainer, {
						isSmallScreen = false,
						dismissCallback = function() end,
						scrollingEnabled = true,
						searchText = "",
					}),
				}),
			}),
		})

		local folder = Instance.new("Folder")
		local root = ReactRoblox.createRoot(folder)

		Roact.act(function()
			root:render(element)
		end)

		local containerElement = folder:FindFirstChildOfClass("ScrollingFrame") :: ScrollingFrame
		expect(containerElement).never.toBeNull()
		local spinnerElement = containerElement:FindFirstChild("LoadingSpinner", true)
		expect(spinnerElement).toBeNull()

		ReactRoblox.act(function()
			root:unmount()
		end)
	end)

	it("should show error state if friends fetch fails", function(c: any)
		local store = Rodux.Store.new(Reducer, {}, {
			Rodux.thunkMiddleware,
		})

		NetworkingFriends.FindFriendsFromUserId.Mock.clear()
		NetworkingFriends.FindFriendsFromUserId.Mock.replyWithError(function()
			return "error"
		end)

		local element = Roact.createElement(RoactRodux.StoreProvider, {
			store = store,
		}, {
			StyleProvider = Roact.createElement(UIBlox.Core.Style.Provider, {}, {
				ApolloProvider = Roact.createElement(ApolloProvider, {
					client = c.mockApolloClient,
				}, {
					FriendListContainer = Roact.createElement(FriendListContainer, {
						isSmallScreen = false,
						dismissCallback = function() end,
						scrollingEnabled = true,
						searchText = "",
					}),
				}),
			}),
		})

		local folder = Instance.new("Folder")
		local root = ReactRoblox.createRoot(folder)

		Roact.act(function()
			root:render(element)
		end)

		local containerElement = folder:FindFirstChild("ScrollingFrame", true) :: ScrollingFrame
		expect(containerElement).toBeNull()
		local failedButtonElement = folder:FindFirstChild("FailedButton", true)
		expect(failedButtonElement).never.toBeNull()

		ReactRoblox.act(function()
			root:unmount()
		end)
	end)
end
