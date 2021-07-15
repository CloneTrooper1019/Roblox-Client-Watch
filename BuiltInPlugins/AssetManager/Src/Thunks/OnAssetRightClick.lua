local Plugin = script.Parent.Parent.Parent

local SetAssets = require(Plugin.Src.Actions.SetAssets)
local SetEditingAssets = require(Plugin.Src.Actions.SetEditingAssets)
local SetScreen = require(Plugin.Src.Actions.SetScreen)
local SetSelectedAssets = require(Plugin.Src.Actions.SetSelectedAssets)

local GetAssets = require(Plugin.Src.Thunks.GetAssets)
local LaunchBulkImport = require(Plugin.Src.Thunks.LaunchBulkImport)

local enableAudioImport = require(Plugin.Src.Util.AssetManagerUtilities).enableAudioImport

local Screens = require(Plugin.Src.Util.Screens)
local View = require(Plugin.Src.Util.View)

local AssetManagerService = game:GetService("AssetManagerService")
local HttpService = game:GetService("HttpService")
local MemStorageService = game:GetService("MemStorageService")
local RunService = game:GetService("RunService")
local StudioService = game:GetService("StudioService")

local FFlagCleanupRightClickContextMenuFunctions2 = game:GetFastFlag("CleanupRightClickContextMenuFunctions2")
local FFlagNewPackageAnalyticsWithRefactor2 = game:GetFastFlag("NewPackageAnalyticsWithRefactor2")

local EVENT_ID_OPENASSETCONFIG = "OpenAssetConfiguration"

--TODO: Convert context menus into components to that they can have access to context services

local function removeAssets(apiImpl, assetData, assets, selectedAssets, store)
    for _, asset in pairs(assets) do
        if selectedAssets[asset.key] then
            if asset.assetType == Enum.AssetType.Place then
                AssetManagerService:RemovePlace(asset.id)
            elseif asset.assetType == Enum.AssetType.Image then
                AssetManagerService:DeleteAlias("Images/".. asset.name)
            elseif asset.assetType == Enum.AssetType.MeshPart then
                AssetManagerService:DeleteAlias("Meshes/".. asset.name)
            elseif asset.assetType == Enum.AssetType.Lua then
                AssetManagerService:DeleteAlias("Scripts/".. asset.name)
            elseif enableAudioImport() and asset.assetType == Enum.AssetType.Audio then
                AssetManagerService:DeleteAlias("Audio/".. asset.name)
            end
        end
    end
    store:dispatch(SetSelectedAssets({}))
    store:dispatch(SetAssets({
        assets = {},
    }))
    store:dispatch(GetAssets(apiImpl, assetData.assetType))
end

local function addRenameAliasContextItem(contextMenu, analytics, assetData, localization, onAssetPreviewClose, store)
    contextMenu:AddNewAction("RenameAlias", localization:getText("ContextMenu", "RenameAlias")).Triggered:connect(function()
        onAssetPreviewClose()
        local assetToEdit = {
            [assetData.id] = true,
        }
        store:dispatch(SetEditingAssets(assetToEdit))
        analytics:report("clickContextMenuItem")
    end)
end
local function addEditAssetContextItem(contextMenu, analytics, assetData, localization, assetType)
    if RunService:IsEdit() then
        contextMenu:AddNewAction("EditAsset", localization:getText("ContextMenu", "EditAsset")).Triggered:connect(function()
            MemStorageService:Fire(EVENT_ID_OPENASSETCONFIG,
                HttpService:JSONEncode({ id = assetData.id, assetType = assetType, }))
            analytics:report("clickContextMenuItem")
        end)
    end
end
local function addRemoveFromGameContextItem(contextMenu, apiImpl, analytics, assetData, localization, onAssetPreviewClose, store, state)
    local assets = state.AssetManagerReducer.assetsTable.assets
    local selectedAssets = state.AssetManagerReducer.selectedAssets
    contextMenu:AddNewAction("RemoveFromGame", localization:getText("ContextMenu", "RemoveFromGame")).Triggered:connect(function()
        removeAssets(apiImpl, assetData, assets, selectedAssets, store)
        onAssetPreviewClose()
        analytics:report("clickContextMenuItem")
    end)
end

local function createFolderContextMenu(analytics, apiImpl, assetData, contextMenu, localization, store)
    contextMenu:AddNewAction("OpenFolder", localization:getText("ContextMenu", "OpenFolder")).Triggered:connect(function()
        store:dispatch(SetScreen(assetData.Screen))
        analytics:report("clickContextMenuItem")
    end)
    if assetData.Screen.Key == Screens.IMAGES.Key then
        contextMenu:AddNewAction("AddImages", localization:getText("ContextMenu", "AddImages")).Triggered:connect(function()
            store:dispatch(LaunchBulkImport(Enum.AssetType.Image.Value))
            analytics:report("clickContextMenuItem")
        end)
    elseif enableAudioImport() and assetData.Screen.Key == Screens.AUDIO.Key then
        contextMenu:AddNewAction("AddAudio", localization:getText("ContextMenu", "AddAudio")).Triggered:connect(function()
            store:dispatch(LaunchBulkImport(Enum.AssetType.Audio.Value))
            analytics:report("clickContextMenuItem")
        end)
    elseif assetData.Screen.Key == Screens.MESHES.Key then
        contextMenu:AddNewAction("AddMeshes", localization:getText("ContextMenu", "AddMeshes")).Triggered:connect(function()
            store:dispatch(LaunchBulkImport(Enum.AssetType.MeshPart.Value))
            analytics:report("clickContextMenuItem")
        end)
    elseif assetData.Screen.Key == Screens.PLACES.Key then
        contextMenu:AddNewAction("AddPlace", localization:getText("ContextMenu", "AddNewPlace")).Triggered:connect(function()
            local placeId, errorMessage = AssetManagerService:AddNewPlace()
            if errorMessage then
                error(errorMessage)
                return
            end
            store:dispatch(SetAssets({
                assets = {},
            }))
            local state = store:getState()
            if state.Screen.currentScreen.Key == Screens.PLACES.Key then
                store:dispatch(GetAssets(apiImpl, Screens.PLACES.AssetType))
            else
                store:dispatch(SetScreen(Screens.PLACES))
            end
            analytics:report("clickContextMenuItem")
        end)
    end

    contextMenu:ShowAsync()
    contextMenu:Destroy()
end

local function createPlaceContextMenu(analytics, apiImpl, assetData, contextMenu, localization, onAssetPreviewClose, store)
    local state = store:getState()
    local assets = state.AssetManagerReducer.assetsTable.assets
    local selectedAssets = state.AssetManagerReducer.selectedAssets
    contextMenu:AddNewAction("Rename", localization:getText("ContextMenu", "Rename")).Triggered:connect(function()
        onAssetPreviewClose()
        local assetToEdit = {
            [assetData.id] = true,
        }
        store:dispatch(SetEditingAssets(assetToEdit))
        analytics:report("clickContextMenuItem")
    end)
    contextMenu:AddNewAction("CopyIdToClipboard", localization:getText("ContextMenu", "CopyIdToClipboard")).Triggered:connect(function()
        StudioService:CopyToClipboard(assetData.id)
        analytics:report("clickContextMenuItem")
    end)
    contextMenu:AddNewAction("ViewPlaceHistory", localization:getText("ContextMenu", "ViewPlaceHistory")).Triggered:connect(function()
        StudioService:ShowPlaceVersionHistoryDialog(assetData.id)
        analytics:report("clickContextMenuItem")
    end)
    if not assetData.isRootPlace then
        contextMenu:AddNewAction("RemoveFromGame", localization:getText("ContextMenu", "RemoveFromGame")).Triggered:connect(function()
            removeAssets(apiImpl, assetData, assets, selectedAssets, store)
            analytics:report("clickContextMenuItem")
        end)
    end

    contextMenu:ShowAsync()
    contextMenu:Destroy()
end

local function createPackageContextMenu(analytics, assetData, contextMenu, isAssetPreviewMenu, localization, onOpenAssetPreview, store)
    local state = store:getState()
    local view = state.AssetManagerReducer.view
    local userHasPermission = assetData.action == "Edit" or assetData.action == "Own"
    local userCanUpdate = assetData.upToVersion > 1
    if view.Key == View.LIST.Key and not isAssetPreviewMenu then
        contextMenu:AddNewAction("AssetPreview", localization:getText("ContextMenu", "AssetPreview")).Triggered:connect(function()
            -- when opening asset preview, set selected assets to that asset only
            store:dispatch(SetSelectedAssets({ [assetData.key] = true }))
            onOpenAssetPreview(assetData)
        end)
    end
    if RunService:IsEdit() then
        contextMenu:AddNewAction("Insert", localization:getText("ContextMenu", "Insert")).Triggered:connect(function()
            AssetManagerService:InsertPackage(assetData.id)
            analytics:report("clickContextMenuItem")
            local state = store:getState()
            local searchTerm = state.AssetManagerReducer.searchTerm
            if utf8.len(searchTerm) ~= 0 then
                analytics:report("insertAfterSearch")
            end
        end)
    end
    if RunService:IsEdit() and userCanUpdate then
        contextMenu:AddNewAction("UpdateAll", localization:getText("ContextMenu", "UpdateAll")).Triggered:connect(function()
            AssetManagerService:UpdateAllPackages(assetData.id)
            analytics:report("clickContextMenuItem")
            if FFlagNewPackageAnalyticsWithRefactor2 then
                analytics:report("massUpdateFromAssetManager")
            end
        end)
    end
    contextMenu:AddNewAction("ViewOnWebsite", localization:getText("ContextMenu", "ViewOnWebsite")).Triggered:connect(function()
        AssetManagerService:ViewPackageOnWebsite(assetData.id)
        analytics:report("clickContextMenuItem")
    end)
    contextMenu:AddNewAction("CopyIdToClipboard", localization:getText("ContextMenu", "CopyIdToClipboard")).Triggered:connect(function()
        StudioService:CopyToClipboard(assetData.id)
        analytics:report("clickContextMenuItem")
    end)
    if RunService:IsEdit() and userHasPermission then
        contextMenu:AddNewAction("PackageDetails", localization:getText("ContextMenu", "PackageDetails")).Triggered:connect(function()
            AssetManagerService:ShowPackageDetails(assetData.id)
            analytics:report("clickContextMenuItem")
        end)
    end

    contextMenu:ShowAsync()
    contextMenu:Destroy()
end

local function createImageContextMenu(analytics, apiImpl, assetData, contextMenu, isAssetPreviewMenu, localization, onOpenAssetPreview, onAssetPreviewClose, store)
    local state = store:getState()
    local assets = state.AssetManagerReducer.assetsTable.assets
    local selectedAssets = state.AssetManagerReducer.selectedAssets
    local view = state.AssetManagerReducer.view
    if view.Key == View.LIST.Key and not isAssetPreviewMenu then
        contextMenu:AddNewAction("AssetPreview", localization:getText("ContextMenu", "AssetPreview")).Triggered:connect(function()
            -- when opening asset preview, set selected assets to that asset only
            store:dispatch(SetSelectedAssets({ [assetData.key] = true }))
            onOpenAssetPreview(assetData)
        end)
    end
    if FFlagCleanupRightClickContextMenuFunctions2 then
        addEditAssetContextItem(contextMenu, analytics, assetData, localization, Enum.AssetType.Image.Value)
        addRenameAliasContextItem(contextMenu, analytics, assetData, localization, onAssetPreviewClose, store)
    else
        if RunService:IsEdit() then
            contextMenu:AddNewAction("EditAsset", localization:getText("ContextMenu", "EditAsset")).Triggered:connect(function()
                MemStorageService:Fire(EVENT_ID_OPENASSETCONFIG,
                    HttpService:JSONEncode({ id = assetData.id, assetType = Enum.AssetType.Image.Value, }))
                analytics:report("clickContextMenuItem")
            end)
        end
        contextMenu:AddNewAction("RenameAlias", localization:getText("ContextMenu", "RenameAlias")).Triggered:connect(function()
            onAssetPreviewClose()
            local assetToEdit = {
                [assetData.id] = true,
            }
            store:dispatch(SetEditingAssets(assetToEdit))
            analytics:report("clickContextMenuItem")
        end)
    end
    contextMenu:AddNewAction("Insert", localization:getText("ContextMenu", "Insert")).Triggered:connect(function()
        AssetManagerService:InsertImage(assetData.id)
        analytics:report("clickContextMenuItem")
        local searchTerm = state.AssetManagerReducer.searchTerm
        if utf8.len(searchTerm) ~= 0 then
            analytics:report("insertAfterSearch")
        end
    end)
    contextMenu:AddNewAction("CopyIdToClipboard", localization:getText("ContextMenu", "CopyIdToClipboard")).Triggered:connect(function()
        StudioService:CopyToClipboard("rbxassetid://" .. assetData.id)
        analytics:report("clickContextMenuItem")
    end)
    if FFlagCleanupRightClickContextMenuFunctions2 then
        addRemoveFromGameContextItem(contextMenu, apiImpl, analytics, assetData, localization, onAssetPreviewClose, store, state)
    else
        contextMenu:AddNewAction("RemoveFromGame", localization:getText("ContextMenu", "RemoveFromGame")).Triggered:connect(function()
            removeAssets(apiImpl, assetData, assets, selectedAssets, store)
            onAssetPreviewClose()
            analytics:report("clickContextMenuItem")
        end)
    end

    contextMenu:ShowAsync()
    contextMenu:Destroy()
end

local function createAudioContextMenu(analytics, apiImpl, assetData, contextMenu, isAssetPreviewMenu, localization, onOpenAssetPreview, onAssetPreviewClose, store)
    local state = store:getState()
    local view = state.AssetManagerReducer.view
    if view.Key == View.LIST.Key and not isAssetPreviewMenu then
        contextMenu:AddNewAction("AssetPreview", localization:getText("ContextMenu", "AssetPreview")).Triggered:connect(function()
            onOpenAssetPreview(assetData)
        end)
    end
    addEditAssetContextItem(contextMenu, analytics, assetData, localization, Enum.AssetType.Audio.Value)
    addRenameAliasContextItem(contextMenu, analytics, assetData, localization, onAssetPreviewClose, store)
    contextMenu:AddNewAction("Insert", localization:getText("ContextMenu", "Insert")).Triggered:connect(function()
        AssetManagerService:InsertAudio(assetData.id, assetData.name)
        analytics:report("clickContextMenuItem")
        local searchTerm = state.AssetManagerReducer.searchTerm
        if utf8.len(searchTerm) ~= 0 then
            analytics:report("insertAfterSearch")
        end
    end)
    contextMenu:AddNewAction("CopyIdToClipboard", localization:getText("ContextMenu", "CopyIdToClipboard")).Triggered:connect(function()
        StudioService:CopyToClipboard("rbxassetid://" .. assetData.id)
        analytics:report("clickContextMenuItem")
    end)
    addRemoveFromGameContextItem(contextMenu, apiImpl, analytics, assetData, localization, onAssetPreviewClose, store, state)
    contextMenu:ShowAsync()
    contextMenu:Destroy()
end

local function createMeshPartContextMenu(analytics, apiImpl, assetData, contextMenu, isAssetPreviewMenu, localization, onOpenAssetPreview, onAssetPreviewClose, store)
    local state = store:getState()
    local assets = state.AssetManagerReducer.assetsTable.assets
    local selectedAssets = state.AssetManagerReducer.selectedAssets
    local count = 0
    for _,_ in pairs(selectedAssets) do
        count = count + 1
    end
    local textureId = AssetManagerService:GetTextureId("Meshes/".. assetData.name)
    local view = state.AssetManagerReducer.view
    if view.Key == View.LIST.Key and not isAssetPreviewMenu then
        contextMenu:AddNewAction("AssetPreview", localization:getText("ContextMenu", "AssetPreview")).Triggered:connect(function()
            -- when opening asset preview, set selected assets to that asset only
            store:dispatch(SetSelectedAssets({ [assetData.key] = true }))
            onOpenAssetPreview(assetData)
        end)
    end
    if FFlagCleanupRightClickContextMenuFunctions2 then
        addEditAssetContextItem(contextMenu, analytics, assetData, localization, Enum.AssetType.MeshPart.Value)
        addRenameAliasContextItem(contextMenu, analytics, assetData, localization, onAssetPreviewClose, store)
    else
        if RunService:IsEdit() then
            contextMenu:AddNewAction("EditAsset", localization:getText("ContextMenu", "EditAsset")).Triggered:connect(function()
                MemStorageService:Fire(EVENT_ID_OPENASSETCONFIG,
                    HttpService:JSONEncode({ id = assetData.id, assetType = Enum.AssetType.MeshPart.Value, }))
                analytics:report("clickContextMenuItem")
            end)
        end
        contextMenu:AddNewAction("RenameAlias", localization:getText("ContextMenu", "RenameAlias")).Triggered:connect(function()
            onAssetPreviewClose()
            local assetToEdit = {
                [assetData.id] = true,
            }
            store:dispatch(SetEditingAssets(assetToEdit))
            analytics:report("clickContextMenuItem")
        end)
    end
    if count == 1 then
        contextMenu:AddNewAction("Insert", localization:getText("ContextMenu", "Insert")).Triggered:connect(function()
            AssetManagerService:InsertMesh("Meshes/".. assetData.name, false)
            analytics:report("clickContextMenuItem")
            local searchTerm = state.AssetManagerReducer.searchTerm
            if utf8.len(searchTerm) ~= 0 then
                analytics:report("insertAfterSearch")
            end
        end)
    end
    contextMenu:AddNewAction("InsertWithLocation", localization:getText("ContextMenu", "InsertWithLocation")).Triggered:connect(function()
        if count == 1 then
            AssetManagerService:InsertMesh("Meshes/".. assetData.name, false)
        else
            local selectedMeshes = {}
            for _, asset in pairs(assets) do
                local layoutOrder = asset.layoutOrder
                if selectedAssets[layoutOrder] then
                    table.insert(selectedMeshes, "Meshes/".. asset.name)
                end
            end
            AssetManagerService:InsertMeshesWithLocation(selectedMeshes)
        end
        analytics:report("clickContextMenuItem")
        local searchTerm = state.AssetManagerReducer.searchTerm
        if utf8.len(searchTerm) ~= 0 then
            analytics:report("insertAfterSearch")
        end
    end)
    contextMenu:AddNewAction("CopyIdToClipboard", localization:getText("ContextMenu", "CopyIdToClipboard")).Triggered:connect(function()
        StudioService:CopyToClipboard("rbxassetid://" .. AssetManagerService:GetMeshId("Meshes/".. assetData.name))
        analytics:report("clickContextMenuItem")
    end)
    if textureId ~= -1 then
        contextMenu:AddNewAction("CopyTextureIdToClipboard", localization:getText("ContextMenu", "CopyTextureIdToClipboard")).Triggered:connect(function()
            StudioService:CopyToClipboard("rbxassetid://" .. textureId)
            analytics:report("clickContextMenuItem")
        end)
    end
    if FFlagCleanupRightClickContextMenuFunctions2 then
        addRemoveFromGameContextItem(contextMenu, apiImpl, analytics, assetData, localization, onAssetPreviewClose, store, state)
    else
        contextMenu:AddNewAction("RemoveFromGame", localization:getText("ContextMenu", "RemoveFromGame")).Triggered:connect(function()
            removeAssets(apiImpl, assetData, assets, selectedAssets, store)
            onAssetPreviewClose()
            analytics:report("clickContextMenuItem")
        end)
    end

    contextMenu:ShowAsync()
    contextMenu:Destroy()
end

local function createLinkedScriptContextMenu(analytics, apiImpl, assetData, contextMenu, isAssetPreviewMenu, localization, onOpenAssetPreview, onAssetPreviewClose, store)
    local state = store:getState()
    local assets = state.AssetManagerReducer.assetsTable.assets
    local selectedAssets = state.AssetManagerReducer.selectedAssets
    local hasUnpublishedChanges = AssetManagerService:HasUnpublishedChangesForLinkedSource("Scripts/".. assetData.name)
    local view = state.AssetManagerReducer.view
    if view.Key == View.LIST.Key and not isAssetPreviewMenu then
        contextMenu:AddNewAction("AssetPreview", localization:getText("ContextMenu", "AssetPreview")).Triggered:connect(function()
            -- when opening asset preview, set selected assets to that asset only
            store:dispatch(SetSelectedAssets({ [assetData.key] = true }))
            onOpenAssetPreview(assetData)
        end)
    end
    if FFlagCleanupRightClickContextMenuFunctions2 then
        addRenameAliasContextItem(contextMenu, analytics, assetData, localization, onAssetPreviewClose, store)
    else
        contextMenu:AddNewAction("RenameAlias", localization:getText("ContextMenu", "RenameAlias")).Triggered:connect(function()
            onAssetPreviewClose()
            local assetToEdit = {
                [assetData.id] = true,
            }
            store:dispatch(SetEditingAssets(assetToEdit))
            analytics:report("clickContextMenuItem")
        end)
    end
    contextMenu:AddNewAction("InsertAsScript", localization:getText("ContextMenu", "InsertAsScript")).Triggered:connect(function()
        AssetManagerService:InsertLinkedSourceAsScript("Scripts/".. assetData.name)
        analytics:report("clickContextMenuItem")
        local searchTerm = state.AssetManagerReducer.searchTerm
        if utf8.len(searchTerm) ~= 0 then
            analytics:report("insertAfterSearch")
        end
    end)
    contextMenu:AddNewAction("InsertAsLocalScript", localization:getText("ContextMenu", "InsertAsLocalScript")).Triggered:connect(function()
        AssetManagerService:InsertLinkedSourceAsLocalScript("Scripts/".. assetData.name)
        analytics:report("clickContextMenuItem")
        local searchTerm = state.AssetManagerReducer.searchTerm
        if utf8.len(searchTerm) ~= 0 then
            analytics:report("insertAfterSearch")
        end
    end)
    contextMenu:AddNewAction("InsertAsModuleScript", localization:getText("ContextMenu", "InsertAsModuleScript")).Triggered:connect(function()
        AssetManagerService:InsertLinkedSourceAsModuleScript("Scripts/".. assetData.name)
            analytics:report("clickContextMenuItem")
        local searchTerm = state.AssetManagerReducer.searchTerm
        if utf8.len(searchTerm) ~= 0 then
            analytics:report("insertAfterSearch")
        end
    end)
    if hasUnpublishedChanges then
        contextMenu:AddNewAction("PublishedLinkedSource", localization:getText("ContextMenu", "PublishLinkedSource")).Triggered:connect(function()
            AssetManagerService:PublishLinkedSource(assetData.id, "Scripts/".. assetData.name)
            analytics:report("clickContextMenuItem")
        end)
    end
    if hasUnpublishedChanges then
        contextMenu:AddNewAction("RevertToLastPublishedVersion", localization:getText("ContextMenu", "RevertToLastPublishedVersion")).Triggered:connect(function()
            AssetManagerService:RevertLinkedSourceToLastPublishedVersion("Scripts/".. assetData.name)
            analytics:report("clickContextMenuItem")
        end)
    end
    contextMenu:AddNewAction("RefreshScript", localization:getText("ContextMenu", "RefreshScript")).Triggered:connect(function()
        AssetManagerService:RefreshLinkedSource("Scripts/".. assetData.name)
        analytics:report("clickContextMenuItem")
    end)
    if FFlagCleanupRightClickContextMenuFunctions2 then
        addRemoveFromGameContextItem(contextMenu, apiImpl, analytics, assetData, localization, onAssetPreviewClose, store, state)
    else
        contextMenu:AddNewAction("RemoveFromGame", localization:getText("ContextMenu", "RemoveFromGame")).Triggered:connect(function()
            removeAssets(apiImpl, assetData, assets, selectedAssets, store)
            onAssetPreviewClose()
            analytics:report("clickContextMenuItem")
        end)
    end

    contextMenu:ShowAsync()
    contextMenu:Destroy()
end

local function createAssetContextMenu(analytics, apiImpl, assetData, contextMenu, isAssetPreviewMenu, localization, onOpenAssetPreview, onAssetPreviewClose, store)
    local assetType = assetData.assetType
    if assetType == Enum.AssetType.Place then
        createPlaceContextMenu(analytics, apiImpl, assetData, contextMenu, localization, onAssetPreviewClose, store)
    elseif assetType == Enum.AssetType.Package then
        createPackageContextMenu(analytics, assetData, contextMenu, isAssetPreviewMenu, localization, onOpenAssetPreview, store)
    elseif assetType == Enum.AssetType.Image then
        createImageContextMenu(analytics, apiImpl, assetData, contextMenu, isAssetPreviewMenu, localization, onOpenAssetPreview, onAssetPreviewClose, store)
    elseif assetType == Enum.AssetType.MeshPart then
        createMeshPartContextMenu(analytics, apiImpl, assetData, contextMenu, isAssetPreviewMenu, localization, onOpenAssetPreview, onAssetPreviewClose, store)
    elseif assetType == Enum.AssetType.Lua then
        createLinkedScriptContextMenu(analytics, apiImpl, assetData, contextMenu, isAssetPreviewMenu, localization, onOpenAssetPreview, onAssetPreviewClose, store)
    elseif enableAudioImport() and assetType == Enum.AssetType.Audio then
        createAudioContextMenu(analytics, apiImpl, assetData, contextMenu, isAssetPreviewMenu, localization, onOpenAssetPreview, onAssetPreviewClose, store)
    end
end

return function(props)
    return function(store)
        local analytics = props.Analytics
        local apiImpl = props.API:get()
        local assetData = props.AssetData
        local isAssetPreviewMenu = props.IsAssetPreviewMenu
        local localization = props.Localization
        local plugin = props.Plugin:get()
        local onOpenAssetPreview = props.OnOpenAssetPreview
        local onAssetPreviewClose = props.OnAssetPreviewClose
        local contextMenu = plugin:CreatePluginMenu("AssetManagerContextMenu")
        local isFolder = assetData.ClassName == "Folder"
        if isFolder then
            createFolderContextMenu(analytics, apiImpl, assetData, contextMenu, localization, store)
        else
            createAssetContextMenu(analytics, apiImpl, assetData, contextMenu, isAssetPreviewMenu, localization, onOpenAssetPreview, onAssetPreviewClose, store)
        end
    end
end