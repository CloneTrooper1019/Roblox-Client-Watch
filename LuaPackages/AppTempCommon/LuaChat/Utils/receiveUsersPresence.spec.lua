return function()
	local CorePackages = game:GetService("CorePackages")
	local Rodux = require(CorePackages.Rodux)
	local User = require(CorePackages.AppTempCommon.LuaApp.Models.User)
	local receiveUsersPresence = require(script.Parent.receiveUsersPresence)

	local function createUser(id, name, isFriend)
		return User.fromDataTable({
			id = id,
			name = name,
			isFriend = isFriend,
		})
	end

	it("should update users with presence", function()
		local UserPresenceReducer = Rodux.combineReducers({
			Users = require(CorePackages.AppTempCommon.LuaApp.Reducers.Users),
			FriendPresenceCounts = require(CorePackages.AppTempCommon.LuaChat.Reducers.FriendPresenceCounts),
		})

		local userId1 = "12"
		local userId2 = "23"
		local userId3 = "64"
		local userId4 = "75"
		local userId5 = "98"

		local initialState = {
			Users = {
				[userId1] = createUser(userId1, "Alpha", true),
				[userId2] = createUser(userId2, "Beta", true),
				[userId3] = createUser(userId3, "Charlie", nil),
				[userId4] = createUser(userId4, "Delta", true),
				[userId5] = createUser(userId5, "Epsilon", true),
			}
		}

		local presenceModels = {
			{
				userId = userId1,
				universeId = "383310974",
				userPresenceType = 2,
				placeId = "920587237",
				rootPlaceId = "920587237",
			}, {
				userId = userId2,
				userPresenceType = 1,
			}, {
				userId = userId3,
				universeId = "383310974",
				userPresenceType = 2,
				placeId = "920587237",
				rootPlaceId = "920587237",
			}, {
				userId = userId4,
				userPresenceType = 0,
			}, {
				userId = userId5,
				universeId = "383310974",
				userPresenceType = 2,
				placeId = "920587237",
				rootPlaceId = "920587237",
			},
		}

		local store = Rodux.Store.new(UserPresenceReducer, initialState, { Rodux.thunkMiddleware })
		receiveUsersPresence(presenceModels, store)

		local presenceCounts = store:getState().FriendPresenceCounts

		expect(presenceCounts["OFFLINE"]).to.equal(1)
		expect(presenceCounts["ONLINE"]).to.equal(1)
		expect(presenceCounts["IN_GAME"]).to.equal(2)
		expect(presenceCounts["IN_STUDIO"]).to.never.be.ok()
	end)
end