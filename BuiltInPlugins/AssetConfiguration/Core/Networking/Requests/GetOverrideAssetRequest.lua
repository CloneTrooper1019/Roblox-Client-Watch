local Plugin = script.Parent.Parent.Parent.Parent

local Util = Plugin.Core.Util
local AssetConfigConstants = require(Util.AssetConfigConstants)
local PagedRequestCursor = require(Util.PagedRequestCursor)
local DebugFlags = require(Util.DebugFlags)

local Actions = Plugin.Core.Actions
local NetworkError = require(Actions.NetworkError)
local SetOverrideAssets = require(Actions.SetOverrideAssets)
local SetLoadingPage = require(Actions.SetLoadingPage)
local UpdateOverrideAssetData = require(Actions.UpdateOverrideAssetData)
local SetCurrentPage = require(Actions.SetCurrentPage)
local SetOverrideCursor = require(Actions.SetOverrideCursor)

local function filterAssetByCreatorId(resultsArray, creatorId)
	local results = {}
	for index, asset in pairs(resultsArray) do
		if asset.Creator.Id == creatorId then
			table.insert(results, asset)
		end
	end
	return results
end

local function convertCreationsDetailsToResultsFormat(creationData)
	local result = {}
	if creationData then
		for index, value in pairs(creationData) do
			local assetResultTable =  {
				Asset = {
					Id = value.assetId,
					Name = value.name,
				},
			}
			result[#result + 1] = assetResultTable
		end
	end
	return result
end

local function getNextCursor(store)
	local currentCursor = store:getState().overrideCursor
	local targetCursor = ""
	if currentCursor.nextPageCursor then
		targetCursor = currentCursor.nextPageCursor
	end
	return targetCursor
end

-- creatorType can be "User" or "Group"
-- If creatorType is Group, creatorId is groupId
return function(networkInterface, assetTypeEnum, creatorType, creatorId, targetPage)
	return function(store)
		local loadingPage = store:getState().loadingPage or 0
		if DebugFlags.shouldDebugOverrideAssetLoading() then
			print(string.format("GetOverrideAssetRequest: curr=%s, loading=%s, target=%s", 
				tostring(store:getState().currentPage), 
				tostring(store:getState().loadingPage), 
				tostring(targetPage)))
		end

		if targetPage > 1 then
			-- If targetPage bigger than 1, then fetchedAll will decide if we should reqeust more.
			if store:getState().fetchedAll then
				if DebugFlags.shouldDebugOverrideAssetLoading() then
					print("GetOverrideAssetRequest: fetchedAll, stopping")
				end
				return
			end

			-- Make sure we only load target page once.
			if loadingPage >= targetPage then
				if DebugFlags.shouldDebugOverrideAssetLoading() then
					print("GetOverrideAssetRequest: loadingPage >= targetPage, stopping")
				end
				return
			end
		end

		if DebugFlags.shouldDebugOverrideAssetLoading() then
			print("GetOverrideAssetRequest: continuing to run request")
		end

		store:dispatch(SetLoadingPage(targetPage))

		local handleOverrideFailed = function(result)
			store:dispatch(NetworkError(result))
			store:dispatch(SetLoadingPage(0))
		end

		local handleGetCreationOverrideSuccess = function(response)
			if DebugFlags.shouldDebugOverrideAssetLoading() then
				print(string.format("handleGetCreationOverrideSuccess: curr=%s, loading=%s, target=%s", 
					tostring(store:getState().currentPage), 
					tostring(store:getState().loadingPage), 
					tostring(targetPage)))
			end
			local result = response.responseBody

			local resultsArray = convertCreationsDetailsToResultsFormat(result.data)
			if targetPage == 1 then
				store:dispatch(SetOverrideAssets(resultsArray))
				store:dispatch(SetOverrideCursor({
					nextPageCursor = result.nextPageCursor,
				}))
				store:dispatch(SetCurrentPage(1))
			else
				local currentCursor = store:getState().overrideCursor
				local isNextPageAvailable = result.nextPageCursor ~= nil
				local fetchedAll = not isNextPageAvailable
				if isNextPageAvailable then
					currentCursor = {
						nextPageCursor = result.nextPageCursor
					}
				end

				store:dispatch(UpdateOverrideAssetData(resultsArray, fetchedAll))

				store:dispatch(SetOverrideCursor(currentCursor))

				store:dispatch(SetCurrentPage(targetPage))
			end

			store:dispatch(SetLoadingPage(0))
		end

		local category = "Model"
		local groupId = nil
		if creatorType == "Group" then
			groupId = creatorId
			category = assetTypeEnum == Enum.AssetType.Plugin and "Plugin" or category
			category = assetTypeEnum == Enum.AssetType.Animation and "Animation" or category
		else
			if assetTypeEnum == Enum.AssetType.Plugin then
				category = "Plugin"
			elseif assetTypeEnum == Enum.AssetType.Animation then
				category = "Animation"
			end
		end

		if creatorType == "Group" then
			if category == "Animation" then
				local targetCursor = getNextCursor(store)
				return networkInterface:getGroupAnimations(targetCursor, groupId):andThen(
					handleGetCreationOverrideSuccess,
					handleOverrideFailed
				)
			else
				local nextCursor = getNextCursor(store)
				networkInterface:getAssetCreations(nil, nextCursor, category, groupId):andThen(
					handleGetCreationOverrideSuccess,
					handleOverrideFailed
				)
			end
		else
			local nextCursor = getNextCursor(store)
			return networkInterface:getAssetCreations(nil, nextCursor, category, groupId):andThen(
					handleGetCreationOverrideSuccess,
					handleOverrideFailed
				)
		end
	end
end
