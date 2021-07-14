local CorePackages = game:GetService("CorePackages")

local ShareGame = game:GetService("CoreGui").RobloxGui.Modules.Settings.Pages.ShareGame
local Requests = CorePackages.AppTempCommon.LuaApp.Http.Requests

local Promise = require(CorePackages.AppTempCommon.LuaApp.Promise)
local ApiFetchUsersPresences = require(CorePackages.AppTempCommon.LuaApp.Thunks.ApiFetchUsersPresences)
local ApiFetchUsersThumbnail = require(ShareGame.Thunks.ApiFetchUsersThumbnail)
local UsersGetFriends = require(Requests.UsersGetFriends)

local FetchUserFriendsStarted = require(CorePackages.AppTempCommon.LuaApp.Actions.FetchUserFriendsStarted)
local FetchUserFriendsFailed = require(CorePackages.AppTempCommon.LuaApp.Actions.FetchUserFriendsFailed)
local FetchUserFriendsCompleted = require(CorePackages.AppTempCommon.LuaApp.Actions.FetchUserFriendsCompleted)
local UserModel = require(CorePackages.AppTempCommon.LuaApp.Models.User)
local UpdateUsers = require(CorePackages.AppTempCommon.LuaApp.Thunks.UpdateUsers)

return function(requestImpl, userId, thumbnailRequest, checkPoints)
	return function(store)
		store:dispatch(FetchUserFriendsStarted(userId))

		if checkPoints ~= nil and checkPoints.startFetchUserFriends ~= nil then
			checkPoints:startFetchUserFriends()
		end

		return UsersGetFriends(requestImpl, userId):andThen(function(response)
			local responseBody = response.responseBody

			local userIds = {}
			local newUsers = {}
			for _, userData in pairs(responseBody.data) do
				local id = tostring(userData.id)
				userData.isFriend = true
				local newUser = UserModel.fromDataTable(userData)

				table.insert(userIds, id)
				newUsers[newUser.id] = newUser
			end
			store:dispatch(UpdateUsers(newUsers))

			if checkPoints ~= nil and checkPoints.finishFetchUserFriends ~= nil then
				checkPoints:finishFetchUserFriends()
			end

			return userIds
		end):andThen(function(userIds)
			if checkPoints ~= nil and checkPoints.startFetchUsersPresences ~= nil then
				checkPoints:startFetchUsersPresences()
			end
			-- Asynchronously fetch friend thumbnails so we don't block display of UI
			store:dispatch(ApiFetchUsersThumbnail(requestImpl, userIds, thumbnailRequest))

			return store:dispatch(ApiFetchUsersPresences(requestImpl, userIds))
		end):andThen(
			function(result)
				store:dispatch(FetchUserFriendsCompleted(userId))

				if checkPoints ~= nil and checkPoints.finishFetchUsersPresences ~= nil then
					checkPoints:finishFetchUsersPresences()
				end

				return Promise.resolve(result)
			end,
			function(response)
				store:dispatch(FetchUserFriendsFailed(userId, response))
				return Promise.reject(response)
			end
		)
	end
end
