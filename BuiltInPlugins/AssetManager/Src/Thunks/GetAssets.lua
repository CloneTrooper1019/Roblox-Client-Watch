local Plugin = script.Parent.Parent.Parent

local SetAssets = require(Plugin.Src.Actions.SetAssets)

return function(apiImpl, assetType, pageCursor, pageNumber)
    return function(store)
        local state = store:getState()
        local requestPromise
        local newAssets = {}
        newAssets.assets = {}
        -- fetching next page of assets
        if pageCursor or (pageNumber and pageNumber ~= 1) then
            newAssets = state.AssetManagerReducer.assetsTable
        end
        if assetType == Enum.AssetType.Place then
            requestPromise = apiImpl.Develop.V2.Universes.getPlaces(game.GameId, pageCursor):makeRequest()
            :andThen(function(response)
                return response
            end, function()
                error("Failed to load places")
            end)
        elseif assetType == Enum.AssetType.Package then
            requestPromise = apiImpl.Develop.V2.Universes.getPackages(game.GameId, pageCursor):makeRequest()
            :andThen(function(response)
                return response
            end, function()
                error("Failed to load packges")
            end)
        elseif assetType == Enum.AssetType.Image
        or assetType == Enum.AssetType.MeshPart
        or assetType == Enum.AssetType.Lua then
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
                if not body.FinalPage then
                    newAssets.pageNumber = page + 1
                end
                for _, alias in pairs(body.Aliases) do
                    if (assetType == Enum.AssetType.Image and string.find(alias.Name, "Images/"))
                    or (assetType == Enum.AssetType.MeshPart and string.find(alias.Name, "Meshes/"))
                    or (assetType == Enum.AssetType.Lua and string.find(alias.Name, "Scripts/")) then
                        -- creating new table so keys across all assets are consistent
                        local assetAlias = {}
                        assetAlias.assetType = assetType
                        assetAlias.asset = alias.Asset
                        assetAlias.id = alias.TargetId
                        if assetType == Enum.AssetType.Image and string.find(alias.Name, "Images/") then
                            assetAlias.name = string.gsub(alias.Name, "Images/", "")
                        elseif assetType == Enum.AssetType.MeshPart and string.find(alias.Name, "Meshes/") then
                            assetAlias.name = string.gsub(alias.Name, "Meshes/", "")
                        elseif assetType == Enum.AssetType.Lua and string.find(alias.Name, "Scripts/") then
                            assetAlias.name = string.gsub(alias.Name, "Scripts/", "")
                        end
                        table.insert(newAssets.assets, assetAlias)
                    end
                end
                store:dispatch(SetAssets(newAssets))
            end, function()
                error("Failed to load aliases")
            end)
        end
        if assetType == Enum.AssetType.Place or assetType == Enum.AssetType.Package then
            requestPromise:andThen(function(response)
                local body = response.responseBody
                if not body then
                    return
                end
                if body.previousPageCursor then
                    newAssets.previousPageCursor = response.previousPageCursor
                end
                if body.nextPageCursor then
                    newAssets.nextPageCursor = response.nextPageCursor
                end
                for _, asset in pairs(body.data) do
                    asset.assetType = assetType
                    table.insert(newAssets.assets, asset)
                end
                store:dispatch(SetAssets(newAssets))
            end)
        end
    end
end