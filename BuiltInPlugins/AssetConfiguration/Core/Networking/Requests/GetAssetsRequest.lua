local FFlagToolboxLegacyFetchGroupModelsAndPackages = game:GetFastFlag("ToolboxLegacyFetchGroupModelsAndPackages")

local Plugin = script.Parent.Parent.Parent.Parent

local Actions = Plugin.Core.Actions
local GetAssets = require(Actions.GetAssets)
local NetworkError = require(Actions.NetworkError)
local SetLoading = require(Actions.SetLoading)
local SetCachedCreatorInfo = require(Actions.SetCachedCreatorInfo)
local SetCurrentPage = require(Actions.SetCurrentPage)

local Category = require(Plugin.Core.Types.Category)

local Util = Plugin.Core.Util
local CreatorInfoHelper = require(Util.CreatorInfoHelper)
local PageInfoHelper = require(Util.PageInfoHelper)
local PagedRequestCursor = require(Util.PagedRequestCursor)
local DebugFlags = require(Util.DebugFlags)
local AssetAnalytics = require(Util.Analytics.AssetAnalytics)

local AssetInfo = require(Plugin.Core.Models.AssetInfo)

local function extractAssetIdsFromGetAssetsResponse(data)
	local result = {}
	if data then
		for _,value in pairs(data) do
			result[#result + 1] = value.assetId
		end
	end
	return result
end

local function convertCreationsDetailsToResultsFormat(data, assetType, creatorName, creatorType)
	local result = {}
	if data then
		for _,value in pairs(data) do
			local assetResultTable
			assetResultTable = AssetInfo.fromCreationsDetails(value, assetType, creatorName, creatorType)

			result[#result + 1] = assetResultTable
		end
	end
	return result
end

local function extractCreatorInfo(responseBodyResults)
	if responseBodyResults and #responseBodyResults > 0 then
		local firstResult = responseBodyResults[1]
		return firstResult.Creator.Id, firstResult.Creator.Name, CreatorInfoHelper.backendToClient(firstResult.Creator.Type)
	end
end

local function dispatchCreatorInfo(store, id, name, type)
	store:dispatch(SetCachedCreatorInfo({Id=id, Name=name, Type=type}))
end

local function dispatchGetAssets(store, pageInfo, creationDetailsTable, creatorName, nextCursor, creatorType)
	if PageInfoHelper.isPageInfoStale(pageInfo, store) then
		return
	end
	local assetType = PageInfoHelper.getEngineAssetTypeForPageInfoCategory(pageInfo)
	local assetResults = convertCreationsDetailsToResultsFormat(creationDetailsTable, assetType, creatorName, creatorType)

	AssetAnalytics.addContextToAssetResults(assetResults, pageInfo)

	store:dispatch(GetAssets(assetResults, nil, nextCursor))
	store:dispatch(SetCurrentPage(0))
	store:dispatch(SetLoading(false))
end

local function dispatchGetAssetsWarning(store, errorText, nextCursor)
	if DebugFlags.shouldDebugWarnings() and errorText then
		warn(errorText)
	end
	store:dispatch(GetAssets({}, nil, nextCursor))
	store:dispatch(SetLoading(false))
end

return function(networkInterface, pageInfoOnStart)
	return function(store)
		store:dispatch(SetLoading(true))
		local isCreatorSearchEmpty = pageInfoOnStart.creator and pageInfoOnStart.creator.Id == -1
		local isCreationSearch = Category.getTabForCategoryName(pageInfoOnStart.categoryName) == Category.CREATIONS
		if FFlagToolboxLegacyFetchGroupModelsAndPackages then
			-- special case : temporarily pull Group Creations Models and Packages from the develop API
			local categoryName = pageInfoOnStart.categoryName
			
			if categoryName == Category.CREATIONS_GROUP_MODELS.name or
				categoryName == Category.CREATIONS_GROUP_PACKAGES.name then
				isCreationSearch = false
			end
		end

		local errorFunc = function(result)
			if PageInfoHelper.isPageInfoStale(pageInfoOnStart, store) then
				return
			end
			store:dispatch(NetworkError(result))
			store:dispatch(SetLoading(false))
		end

		local generalGetAssetHandleFunc = function(result)
			-- Base on pageInfoOnStart and current pageInfo, we can decide what to do after the asset is loaded
			local data = result.responseBody
			local pageInfo = store:getState().pageInfo
			local categoryOnStart = pageInfoOnStart.categoryName
			local categoryOnRequestFinish = pageInfo.categoryName
			
			local isResponseFresh = not PageInfoHelper.isPageInfoStale(pageInfoOnStart, store)

			if isResponseFresh then
				if data then
					dispatchCreatorInfo(store, extractCreatorInfo(data.Results))
					local assetResults = data.Results or {}

					AssetAnalytics.addContextToAssetResults(assetResults, pageInfoOnStart)

					store:dispatch(GetAssets(assetResults, data.TotalResults))
					-- If success get asset, update currentPage.
					store:dispatch(SetCurrentPage(pageInfoOnStart.targetPage))
				end
				store:dispatch(SetLoading(false))
			end
		end

		-- Search Creator
		if isCreatorSearchEmpty then
			local data = {
				Results = {},
				TotalResults = 0,
			}
			store:dispatch(GetAssets(data.Results, data.TotalResults))
			store:dispatch(SetCurrentPage(0))
			store:dispatch(SetLoading(false))
		elseif isCreationSearch then -- General Category Search
			-- Creations search
			local currentCursor = store:getState().assets.currentCursor
			if PagedRequestCursor.isNextPageAvailable(currentCursor) then
				return networkInterface:getAssetCreations(pageInfoOnStart, PagedRequestCursor.getNextPageCursor(currentCursor)):andThen(function(creationsResult)
					local nextCursor = PagedRequestCursor.createCursor(creationsResult.responseBody)
					local assetIds = extractAssetIdsFromGetAssetsResponse(creationsResult.responseBody and creationsResult.responseBody.data)
					if assetIds and #assetIds > 0 then
						networkInterface:getAssetCreationDetails(assetIds):andThen(function(creationDetailsResult)
							local creationDetailsTable = creationDetailsResult.responseBody
							if creationDetailsTable and #creationDetailsTable > 0 then
								local isCreatorInfoFetchRequired = false
								local newCreatorId = creationDetailsTable[1].creatorTargetId

								local newCreatorType = CreatorInfoHelper.getCreatorTypeValueFromName(creationDetailsTable[1].creatorType)
								isCreatorInfoFetchRequired = not CreatorInfoHelper.isCached(store, newCreatorId, newCreatorType)

								if isCreatorInfoFetchRequired then
									networkInterface:getCreatorInfo(newCreatorId, newCreatorType):andThen(function(creatorInfoResult)
										local creatorName = CreatorInfoHelper.getNameFromResult(creatorInfoResult, newCreatorType)
										dispatchCreatorInfo(store, newCreatorId, creatorName, newCreatorType)
										dispatchGetAssets(store, pageInfoOnStart, creationDetailsTable, creatorName, nextCursor, newCreatorType)
									end, errorFunc)
								end

								if not isCreatorInfoFetchRequired then
									local creatorName = store:getState().assets.cachedCreatorInfo.Name
									dispatchGetAssets(store, pageInfoOnStart, creationDetailsTable, creatorName, nextCursor, newCreatorType)
								end
							else
								dispatchGetAssetsWarning(store, "getAssetCreationDetails() did not return any asset details", nextCursor)
							end
						end, errorFunc)
					else
						-- The endpoint can return empty pages with a valid cursor for a next page, because
						-- it filters out packages from the list AFTER applying pagination. So this should not be a warning
						-- See MKTPL-1416 for more information. This is planned to be fixed on the backend, so just nil out
						-- the warning for now.
						dispatchGetAssetsWarning(store, nil, nextCursor)
					end
				end, errorFunc)
			end
		else -- Everything else, change category, tabs, and getAsset
			-- We check if we are trying to access
			local useDevelopAssetAPI = false

			local isAudio = Category.categoryIsAudio(pageInfoOnStart.categoryName)
			local isVideo = Category.categoryIsVideo(pageInfoOnStart.categoryName)
			local isSpecialCase = false

			if FFlagToolboxLegacyFetchGroupModelsAndPackages then
				-- special case : temporarily pull Group Creations Models and Packages from the develop API
				local categoryName = pageInfoOnStart.categoryName
				if categoryName == Category.CREATIONS_GROUP_MODELS.name or
					categoryName == Category.CREATIONS_GROUP_PACKAGES.name then
					isSpecialCase = true
				end
			end

			if PageInfoHelper.isDeveloperCategory(pageInfoOnStart)
				or PageInfoHelper.isPackagesCategory(pageInfoOnStart)
				or isAudio
				or isVideo
				or isSpecialCase
			then
				useDevelopAssetAPI = true
			end

			if useDevelopAssetAPI then
				return networkInterface:getDevelopAsset(pageInfoOnStart):andThen(generalGetAssetHandleFunc, errorFunc)
			else
				return networkInterface:getAssets(pageInfoOnStart):andThen(generalGetAssetHandleFunc, errorFunc)
			end
		end
	end
end
