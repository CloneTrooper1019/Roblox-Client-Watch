local Plugin = script.Parent.Parent.Parent

local Cryo = require(Plugin.Packages.Cryo)

local SetAssets = require(Plugin.Src.Actions.SetAssets)
local SetIsFetchingAssets = require(Plugin.Src.Actions.SetIsFetchingAssets)
local SetHasLinkedScripts = require(Plugin.Src.Actions.SetHasLinkedScripts)

local enableAudioImport = require(Plugin.Src.Util.AssetManagerUtilities).enableAudioImport

local sendResultToKibana = require(Plugin.Packages.Framework.Util.sendResultToKibana)
local FIntStudioAssetManagerAssetFetchNumber = game:GetFastInt("StudioAssetManagerAssetFetchNumber")

local FFlagStudioAssetManagerLoadLinkedScriptsOnInit = game:GetFastFlag("StudioAssetManagerLoadLinkedScriptsOnInit")
local FFlagNewPackageAnalyticsWithRefactor2 = game:GetFastFlag("NewPackageAnalyticsWithRefactor2")

local numberOfAssetsToFetch = FIntStudioAssetManagerAssetFetchNumber

return function(apiImpl, assetType, pageCursor, pageNumber, showLoadingIndicator)
    return function(store)
        local state = store:getState()
        local showLoading
        if showLoadingIndicator == nil then
            showLoading = true
        else
            showLoading = showLoadingIndicator
        end
        local requestPromise
        local newAssets = {
            index = 0
        }

        newAssets.assets = {}
        local index = 1
        if pageCursor or (pageNumber and pageNumber ~= 1) then
            newAssets = state.AssetManagerReducer.assetsTable
            index = newAssets.index + 1
        end
        if showLoading then
            -- fetching next page of assets
            store:dispatch(SetIsFetchingAssets(true))
        end
        if assetType == Enum.AssetType.Place then
            requestPromise = apiImpl.Develop.V2.Universes.places(game.GameId, pageCursor, numberOfAssetsToFetch):makeRequest()
            :andThen(function(response)
                return response
            end, function()
                store:dispatch(SetIsFetchingAssets(false))
                error("Failed to load places")
            end)
        elseif assetType == Enum.AssetType.Package then
            requestPromise = apiImpl.Develop.V1.Universes.packages(game.GameId, pageCursor, numberOfAssetsToFetch):makeRequest()
            :andThen(function(response)
                if FFlagNewPackageAnalyticsWithRefactor2 then
                    sendResultToKibana(response)
                end
                return response
            end, function(response)
                if FFlagNewPackageAnalyticsWithRefactor2 then
                    sendResultToKibana(response)
                end
                store:dispatch(SetIsFetchingAssets(false))
                error("Failed to load packages")
            end)
        elseif assetType == Enum.AssetType.Image
        or assetType == Enum.AssetType.MeshPart
        or assetType == Enum.AssetType.Lua
        or (enableAudioImport() and assetType == Enum.AssetType.Audio)
        then
            local page
            if not pageNumber then
                page = 1
            else
                page = pageNumber
            end

            apiImpl.API.Universes.getAliases(game.GameId, page):makeRequest()
            :andThen(function(response)
                local body = response.responseBody
                if not body then
                    return
                end

                local hasLinkedScripts = state.AssetManagerReducer.hasLinkedScripts
                if not body.FinalPage then
                    newAssets.pageNumber = page + 1
                else
                    newAssets.pageNumber = nil
                end
                for _, alias in pairs(body.Aliases) do
                    if (assetType == Enum.AssetType.Image and string.find(alias.Name, "Images/"))
                    or (assetType == Enum.AssetType.MeshPart and string.find(alias.Name, "Meshes/"))
                    or (assetType == Enum.AssetType.Lua and string.find(alias.Name, "Scripts/"))
                    or (enableAudioImport() and (assetType == Enum.AssetType.Audio and string.find(alias.Name, "Audio/")))
                    then
                        -- creating new table so keys across all assets are consistent
                        local assetAlias = {}
                        local sAssetAliasId = tostring(alias.TargetId)
                        assetAlias.assetType = assetType
                        assetAlias.asset = alias.Asset
                        assetAlias.id = alias.TargetId
                        if assetType == Enum.AssetType.Image and string.find(alias.Name, "Images/") then
                            assetAlias.name = string.gsub(alias.Name, "Images/", "")
                        elseif assetType == Enum.AssetType.MeshPart and string.find(alias.Name, "Meshes/") then
                            assetAlias.name = string.gsub(alias.Name, "Meshes/", "")
                        elseif assetType == Enum.AssetType.Lua and string.find(alias.Name, "Scripts/") then
                            hasLinkedScripts = true
                            assetAlias.name = string.gsub(alias.Name, "Scripts/", "")
                        elseif (enableAudioImport() and assetType == Enum.AssetType.Audio and string.find(alias.Name, "Audio/")) then
                            if not FFlagStudioAssetManagerLoadLinkedScriptsOnInit then
                                hasLinkedScripts = true
                            end
                            assetAlias.name = string.gsub(alias.Name, "Audio/", "")
                        end
                        assetAlias.layoutOrder = index
                        newAssets.assets = Cryo.Dictionary.join(newAssets.assets, {
                            [sAssetAliasId] = assetAlias,
                        })
                        index = index + 1
                    end
                end
                store:dispatch(SetHasLinkedScripts(hasLinkedScripts))
                store:dispatch(SetIsFetchingAssets(false))
                store:dispatch(SetAssets(newAssets, index))
            end, function()
                store:dispatch(SetIsFetchingAssets(false))
                error("Failed to load aliases")
            end)
        end
        if assetType == Enum.AssetType.Place or assetType == Enum.AssetType.Package then
            requestPromise:andThen(function(response)
                if FFlagNewPackageAnalyticsWithRefactor2 then
                    sendResultToKibana(response)
                end
                local body = response.responseBody
                if not body then
                    return
                end
                newAssets.previousPageCursor = body.previousPageCursor
                newAssets.nextPageCursor = body.nextPageCursor

                for _, asset in pairs(body.data) do
                    local newAsset = asset
                    newAsset.assetType = assetType
                    local sAssetId = tostring(newAsset.id)
                    newAsset.layoutOrder = index
                    newAssets.assets = Cryo.Dictionary.join(newAssets.assets, {
                        [sAssetId] = newAsset,
                    })
                    index = index + 1
                end

                store:dispatch(SetIsFetchingAssets(false))
                store:dispatch(SetAssets(newAssets, index))
            end)
        end
    end
end
