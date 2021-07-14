local FIntMaxNameLength = game:DefineFastInt("MaxNameLength", 50)
local FIntPaidAccessMinPrice = game:DefineFastInt("PaidAccessMinPrice", 25)
local FIntPaidAccessMaxPrice = game:DefineFastInt("PaidAccessMaxPrice", 1000)
local FIntPrivateServersMinPrice = game:DefineFastInt("PrivateServersMinPrice", 10)
local FIntDevProductsMinPrice = game:DefineFastInt("DevProductsMinPrice", 1)
local FIntDevProductsMaxPrice = game:DefineFastInt("DevProductsMaxPrice", 1000000000)

local FFlagSupportFreePrivateServers = game:GetFastFlag("SupportFreePrivateServers")
local FFlagEnableDevProductsInGameSettings = game:GetFastFlag("EnableDevProductsInGameSettings")
local FFlagDeveloperSubscriptionsEnabled = game:GetFastFlag("DeveloperSubscriptionsEnabled")
local FFlagStudioFixGameManagementIndexNil = game:getFastFlag("StudioFixGameManagementIndexNil")
local FFlagStudioFixMissingMonetizationHeader = game:DefineFastFlag("StudioFixMissingMonetizationHeader", false)
local FVariableMaxRobuxPrice = game:DefineFastInt("DeveloperSubscriptionsMaxRobuxPrice", 2000)

local Page = script.Parent
local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local Cryo = require(Plugin.Cryo)
local Framework = Plugin.Framework
local ContextServices = require(Framework.ContextServices)

local Header = require(Plugin.Src.Components.Header)
local PaidAccess = require(Page.Components.PaidAccess)
local VIPServers = require(Page.Components.VIPServers)
local DevProducts = require(Page.Components.DevProducts)
local SettingsPage = require(Plugin.Src.Components.SettingsPages.SettingsPage)
local DevSubList = require(Page.Components.DevSubList)
local DevSubDetails = require(Page.Components.DevSubDetails)
local Badges = require(Page.Components.Badges)

local FrameworkUI = require(Framework.UI)
local HoverArea = FrameworkUI.HoverArea
local Separator = FrameworkUI.Separator

local FrameworkUtil = require(Framework.Util)
local LayoutOrderIterator = FrameworkUtil.LayoutOrderIterator
local FitFrameOnAxis = FrameworkUtil.FitFrame.FitFrameOnAxis

local UILibrary = require(Plugin.UILibrary)
local TitledFrame = UILibrary.Component.TitledFrame
local RoundTextBox = UILibrary.Component.RoundTextBox
local RoundFrame = UILibrary.Component.RoundFrame
local TextEntry = UILibrary.Component.TextEntry
local GetTextSize = UILibrary.Util.GetTextSize
local BadgeIconThumbnail = require(Plugin.Src.Components.AutoThumbnails.BadgeIconThumbnail)
local Separator = require(Plugin.Src.Components.Separator)

local AddChange = require(Plugin.Src.Actions.AddChange)
local AddErrors = require(Plugin.Src.Actions.AddErrors)
local DiscardError = require(Plugin.Src.Actions.DiscardError)
local SetEditDevProductId = require(Plugin.Src.Actions.SetEditDevProductId)
local SetComponentLoadState = require(Plugin.Src.Actions.SetComponentLoadState)

local LoadDeveloperProducts = require(Page.Thunks.LoadDeveloperProducts)
local LoadBadges = require(Page.Thunks.LoadBadges)

local AddDevSubKeyChange = require(Page.Thunks.AddDevSubKeyChange)
local AddDevSubKeyError = require(Page.Thunks.AddDevSubKeyError)
local AddDevSubChange = require(Page.Thunks.AddDevSubChange)

local Container = FrameworkUI.Container
local LoadingIndicator = UILibrary.Component.LoadingIndicator
local LoadState = require(Plugin.Src.Util.LoadState)
local ShouldAllowBadges = require(Plugin.Src.Util.GameSettingsUtilities).shouldAllowBadges

local HttpService = game:GetService("HttpService")

local Monetization = Roact.PureComponent:extend(script.name)

local LOCALIZATION_ID = script.Name
local BADGES = "Badges"

--[[
    TODO 7/16/2020 Fetch these values from the BE so we don't need to keep syncing with BE whenever they change
]]

local priceErrors = {
    BelowMin = "ErrorPriceBelowMin",
    AboveMax = "ErrorPriceAboveMax",
    Invalid = "ErrorPriceInvalid",
}

local BELOW_MIN = "BelowMin"
local ABOVE_MAX = "AboveMax"
local INVALID = "Invalid"

local nameErrors = {
    Empty = "ErrorNameEmpty",
}

local nextDevProductName = ""

local KeyProvider = require(Plugin.Src.Util.KeyProvider)
local GetIsFriendsOnlyKeyName = KeyProvider.getIsFriendOnlyKeyName
local GetIsActiveKeyName = KeyProvider.getIsActiveKeyName
local GetIsForSaleKeyName = KeyProvider.getIsForSaleKeyName
local GetVipServersIsEnabledKeyName = KeyProvider.getVipServersIsEnabledKeyName

local function loadSettings(store, contextItems)
    local state = store:getState()
    local gameId = state.Metadata.gameId
    local monetizationController = contextItems.monetizationController
    local devSubsController = contextItems.devSubsController
    local gamePermissionsController = contextItems.gamePermissionsController

    local settingsLoadJobs = {
        function(loadedSettings)
            local taxRate = monetizationController:getTaxRate()

            loadedSettings["taxRate"] = taxRate
        end,

        function(loadedSettings)
            local minimumFee = monetizationController:getMinimumFee()
            loadedSettings["minimumFee"] = minimumFee
        end,

        function(loadedSettings)
            local isForSale = monetizationController:getPaidAccessEnabled(gameId)
            loadedSettings[GetIsForSaleKeyName()] = isForSale
        end,

        function(loadedSettings)
            local price = monetizationController:getPaidAccessPrice(gameId)
            loadedSettings["price"] = price
        end,

        function(loadedSettings)
            local vipServersIsEnabled = monetizationController:getVIPServersEnabled(gameId)
            loadedSettings[GetVipServersIsEnabledKeyName()] = vipServersIsEnabled
        end,

        function(loadedSettings)
            local vipServersPrice = monetizationController:getVIPServersPrice(gameId)
            loadedSettings["vipServersPrice"] = vipServersPrice and vipServersPrice or 0
        end,

        function(loadedSettings)
            local vipServersActiveServersCount = monetizationController:getVIPServersActiveServersCount(gameId)
            loadedSettings["vipServersActiveServersCount"] = vipServersActiveServersCount
        end,

        function(loadedSettings)
            local vipServersActiveSubscriptionsCount = monetizationController:getVIPServersActiveSubscriptionsCount(gameId)
            loadedSettings["vipServersActiveSubscriptionsCount"] = vipServersActiveSubscriptionsCount
        end,

        function(loadedSettings)
            local developerProducts, cursor = monetizationController:getDeveloperProducts(gameId)

            loadedSettings["developerProducts"] = developerProducts
            loadedSettings["devProductsCursor"] = cursor
        end,

        function(loadedSettings)
            if not FFlagDeveloperSubscriptionsEnabled then
                return
            end

            local openDevSubs = devSubsController:getDevSubs(gameId, true)

            loadedSettings["DeveloperSubscriptions"] = openDevSubs
        end,

        function(loadedSettings)
            if state.Settings.Current[GetIsActiveKeyName()] == nil then 
                local isActive = gamePermissionsController:isActive(gameId)
                loadedSettings[GetIsActiveKeyName()] = isActive
            end
        end,

        function(loadedSettings)
            if state.Settings.Current[GetIsFriendsOnlyKeyName()] == nil then 
                local isFriendsOnly = gamePermissionsController:isFriendsOnly(gameId)
                loadedSettings[GetIsFriendsOnlyKeyName()] = isFriendsOnly
            end
        end,
    }
    
	table.insert(settingsLoadJobs, function(loadedSettings)

		if ShouldAllowBadges() then
			local badges, cursor = monetizationController:getBadges(gameId)

			loadedSettings["badges"] = badges
			loadedSettings["badgesCursor"] = cursor
		end
	end)
     
    return settingsLoadJobs
end

local function saveSettings(store, contextItems)
    local state = store:getState()
    local gameId = state.Metadata.gameId
    local monetizationController = contextItems.monetizationController
    local devSubsController = contextItems.devsubs
    local unsavedDevProducts = state.Settings.Changed.unsavedDevProducts
    local editedDevProducts = state.Settings.Changed.editedDeveloperProducts
    local currDevSubs = state.Settings.Current.DeveloperSubscriptions
    local changedDevSubs = state.Settings.Changed.DeveloperSubscriptions or {}

    local saveFunctions = {
        function()
            local changed = state.Settings.Changed.isForSale

            if changed ~= nil then
                monetizationController:setPaidAccessEnabled(gameId, changed)
            end
        end,

        function()
            local changed = state.Settings.Changed.price

            if changed ~= nil then
                monetizationController:setPaidAccessPrice(gameId, changed)
            end
        end,

        function()
            local changed = state.Settings.Changed.vipServersIsEnabled

            if changed ~= nil then
                monetizationController:setVIPServersEnabled(gameId, changed)
            end
        end,

        function()
            local changed = state.Settings.Changed.vipServersPrice

            if changed ~= nil then
                monetizationController:setVIPServersPrice(gameId, changed)
            end
        end,
    }

    if unsavedDevProducts ~= nil then
        for _, product in pairs(unsavedDevProducts) do
            table.insert(saveFunctions, function()
                monetizationController:createDevProduct(gameId, product)
            end)
        end
    end


    if editedDevProducts ~= nil then
        for _,product in pairs(editedDevProducts) do
            table.insert(saveFunctions, function()
                monetizationController:updateDevProduct(gameId, product)
            end)
        end
    end

    if FFlagDeveloperSubscriptionsEnabled and changedDevSubs ~= nil then
        for key, devSub in pairs(changedDevSubs) do
            if devSub.IsNew then
                table.insert(saveFunctions, function()
                    devSubsController:createDevSub(gameId, devSub)
                end)
            else
                if devSub.Active == false then
                    table.insert(saveFunctions, function()
                        devSubsController:discontinueDevSub(currDevSubs[key])
                    end)
                else
                    table.insert(saveFunctions, function()
                        devSubsController:changeDevSub(currDevSubs[key], devSub)
                    end)
                end
            end
        end
    end

    return saveFunctions
end

--Loads settings values into props by key
local function loadValuesToProps(getValue, state)
    local errors = state.Settings.Errors

    local changed = false
    local vipServersShutdown = state.Settings.Changed.vipServersIsEnabled == false
    -- Changed for the sake of warning about canceling subscriptions should only be 
    if state.Settings.Current.vipServersIsEnabled then
        if state.Settings.Changed.vipServersPrice ~= nil then
            changed = true
        end
    end

    local loadedProps = {
        TaxRate = getValue("taxRate"),
        MinimumFee = getValue("minimumFee"),

        PaidAccess = {
            enabled = getValue(GetIsForSaleKeyName()),
            price = getValue("price"),
            initialPrice = state.Settings.Current.price and state.Settings.Current.price or 0,
        },
        VIPServers = {
            isEnabled = getValue(GetVipServersIsEnabledKeyName()),
            price = getValue("vipServersPrice"),
            initialPrice = state.Settings.Current.vipServersPrice and state.Settings.Current.vipServersPrice or 0,
            activeServersCount = getValue("vipServersActiveServersCount"),
            activeSubscriptionsCount = getValue("vipServersActiveSubscriptionsCount"),
            changed = changed,
            willShutdown = vipServersShutdown,
        },

        UnsavedDevProducts = getValue("unsavedDevProducts"),
        DevProducts = state.Settings.Current.developerProducts,
        EditedDevProducts = state.Settings.Changed.editedDeveloperProducts,

        EditDevProductId = state.EditAsset.editDevProductId,

        AccessPriceError = errors.monetizationPrice,
        DevProductPriceError = errors.devProductPrice,
        DevProductNameError = errors.devProductName,

        isEditingSubscription = getValue("isEditingSubscription"),
        editedSubscriptionKey = getValue("editedSubscriptionKey"),

        Badges = state.Settings.Current.badges,

        BadgeLoadState = state.ComponentLoadState.Badges,
        
        isPublic = getValue(GetIsActiveKeyName()) and not getValue(GetIsFriendsOnlyKeyName()),

        -- To allow players with games already saved in this error state (notPublic and isMonetized) have the ability to change the setting. Once allowed states are saved the error state will not be selectable.
        isInitiallyEnabled = (not state.Settings.Current[GetIsActiveKeyName()] or state.Settings.Current[GetIsFriendsOnlyKeyName()]) 
                            and (state.Settings.Current[GetIsForSaleKeyName()] or state.Settings.Current[GetVipServersIsEnabledKeyName()])
    }

    return loadedProps
end

local function checkChangedDevSubKey(dispatch, devSubKey, valueKey, value)
    if valueKey == "Name" and (value == "" or value == nil) then
        dispatch(AddDevSubKeyError(devSubKey, valueKey, {Empty = "Name can't be empty"}))
    elseif valueKey == "Price" then
        local price = tonumber(value)
        if not price or price <= 0  then
            dispatch(AddDevSubKeyError(devSubKey, valueKey, {NotANumber = "Price needs to be a valid number"}))
        elseif FVariableMaxRobuxPrice and price > FVariableMaxRobuxPrice then
            dispatch(AddDevSubKeyError(devSubKey, valueKey, {AboveMaxRobuxAmount = "Price must be less than a certain amount"}))
        end
    elseif valueKey == "Image" and (value == nil or value == "None") then
        dispatch(AddDevSubKeyError(devSubKey, valueKey, {Empty = "Image can't be empty"}))
    end
end

local function checkChangedDevSub(dispatch, devSub)
    checkChangedDevSubKey(dispatch, devSub.Key, "Name", devSub.Name)
    checkChangedDevSubKey(dispatch, devSub.Key, "Image", devSub.Image)
    checkChangedDevSubKey(dispatch, devSub.Key, "Price", devSub.Price)
end

--Implements dispatch functions for when the user changes values
local function dispatchChanges(setValue, dispatch)
    local dispatchFuncs = {
        PaidAccessToggled = function(value, initialPrice)
            -- on toggle, reset the price to what it was before or FIntPaidAccessMinPrice, whichever is larger.
            -- on toggle off, this will reset any changes to price that have been made,
            -- on toggle on for the first time, this will set the price to 25 (lowest valid price) as default.
            dispatch(AddChange("price", initialPrice))
            dispatch(DiscardError("monetizationPrice"))
            dispatch(AddChange(GetIsForSaleKeyName(), value))
        end,

        PaidAccessPriceChanged = function(text)
            local numberValue = tonumber(text)

            dispatch(AddChange("price", numberValue))
            dispatch(DiscardError("monetizationPrice"))

            if not numberValue then
                dispatch(AddErrors({monetizationPrice = INVALID}))
            elseif numberValue < FIntPaidAccessMinPrice then
                dispatch(AddErrors({monetizationPrice = BELOW_MIN}))
            elseif numberValue > FIntPaidAccessMaxPrice then
                dispatch(AddErrors({monetizationPrice = ABOVE_MAX}))
            end
        end,

        VIPServersToggled = function(value, initialPrice)
            -- on toggle, reset the price to what it was before or FIntPrivateServersMinPrice, whichever is larger.
            -- on toggle off, this will reset any changes to price that have been made,
            -- on toggle on for the first time, this will set the price to 10 (lowest valid price) as default.
            dispatch(AddChange("vipServersPrice", initialPrice))
            dispatch(DiscardError("monetizationPrice"))
            dispatch(AddChange(GetVipServersIsEnabledKeyName(), value))
        end,

        VIPServersPriceChanged = function(text)
            local numberValue = tonumber(text)

            dispatch(AddChange("vipServersPrice", numberValue))
            dispatch(DiscardError("monetizationPrice"))

            if FFlagSupportFreePrivateServers then
                if not numberValue then
                    dispatch(AddErrors({monetizationPrice = INVALID}))
                elseif numberValue ~= 0 and numberValue < FIntPrivateServersMinPrice then
                    dispatch(AddErrors({monetizationPrice = BELOW_MIN}))
                end
            else
                if not numberValue then
                    dispatch(AddErrors({monetizationPrice = INVALID}))
                elseif numberValue < FIntPrivateServersMinPrice then
                    dispatch(AddErrors({monetizationPrice = BELOW_MIN}))
                end
            end
        end,

        SetEditDevProductId = function(devProductId)
            dispatch(SetEditDevProductId(devProductId))
        end,

        SetUnsavedDevProducts = function(unsavedDevProducts, errorKey, errorValue)
            if errorValue then
                dispatch(AddErrors({ [errorKey] = errorValue }))
            elseif errorKey then
                if type(errorKey) == "table" then
                    for _, key in ipairs(errorKey) do
                        dispatch(DiscardError(key))
                    end
                else
                    dispatch(DiscardError(errorKey))
                end
            end

            dispatch(AddChange("unsavedDevProducts", unsavedDevProducts))
        end,

        SetDevProducts = function(devProducts, errorKey, errorValue)
            if errorValue then
                dispatch(AddErrors({ [errorKey] = errorValue }))
            elseif errorKey then
                if type(errorKey) == "table" then
                    for _, key in ipairs(errorKey) do
                        dispatch(DiscardError(key))
                    end
                else
                    dispatch(DiscardError(errorKey))
                end
            end
            dispatch(AddChange("editedDeveloperProducts", devProducts))
        end,

        LoadMoreDevProducts = function()
            dispatch(LoadDeveloperProducts())
        end,

        LoadMoreBadges = function()            
            dispatch(LoadBadges())
        end,
        
        RefreshBadges = function()            
            dispatch(SetComponentLoadState(BADGES, LoadState.Loading))
            dispatch(LoadBadges(true))
            dispatch(SetComponentLoadState(BADGES, LoadState.Loaded))
        end or nil,

        SetDevSubKey = function(devSubKey, valueKey, value)
            dispatch(AddDevSubKeyChange(devSubKey, valueKey, value))
            checkChangedDevSubKey(dispatch, devSubKey, valueKey, value)
        end,

        OnDeveloperSubscriptionChanged = function(devSub)
            checkChangedDevSub(dispatch, devSub)
        end,

        OnDeveloperSubscriptionCreated = function()
            -- when we create a developer subscription, we grant it
            -- a temporary key. ultimately, its key will be based
            -- upon its id as given by the backend, but for now we
            -- just need to put it into our table for later
            local key = "TEMPORARY_"..HttpService:GenerateGUID()

            local newDeveloperSubscription = {
                IsNew = true,
                Key = key,
                Price = 0,
                Subscribers = 0,
                Active = false,
                Id = -1,
                Prepaid = 6,
            }

            -- in this case, we can borrow the functionality of this
            -- function in order to join this new sub to the store
            dispatch(AddDevSubChange(newDeveloperSubscription.Key, newDeveloperSubscription))
            checkChangedDevSub(dispatch, newDeveloperSubscription)

            -- now switch state, there's a chance that the new
            -- subscription isn't in the store as we understand it, but
            -- we just show nothing until the store gives it to us
            dispatch(AddChange("isEditingSubscription", true))
            dispatch(AddChange("editedSubscriptionKey", newDeveloperSubscription.Key))
        end,
    }
    return dispatchFuncs
end

local function convertBadgesForTable(badges)    
    local result = {}
    local count = 0
    
    for index, badge in pairs(badges) do
        result[badge.id] = {
            index = index,
            row = {
                badge.name,
                badge.description
            },
            icon = Roact.createElement(BadgeIconThumbnail, {
                Id = badge.iconImageId,
                Size = UDim2.fromScale(1, 1),
            })
        }
        
        count = count + 1
    end

    return result, count
end

local function convertDeveloperProductsForTable(devProducts, localization)
    local result = {}
    local numberOfDevProducts = 1

    for index, product in pairs(devProducts) do
        -- Newly created Dev Products will not have an id field, but saved ones will.
        local saved = product.id ~= nil
        local displayId = saved and product.id or localization:getText("Monetization", "UnsavedDevProduct")
        local mapId = saved and product.id or numberOfDevProducts

        result[mapId] = {
            index = index,
            row = {
                displayId,
                product.name,
                product.price,
            },
        }
        numberOfDevProducts = numberOfDevProducts + 1
    end

    -- Subtract 1 because of indicies start at 1 and this is later used to show/hide the table based on if the table is empty.
    return result, numberOfDevProducts - 1
end

local function combineUnsavedAndSavedDevProducts(unsaved, saved)
    local keys = {}
    for k, _ in pairs(saved) do table.insert(keys, k) end
    table.sort(keys)

    local result = {}

    local appendIndex = 1
    for _,product in pairs(unsaved) do
        table.insert(result, appendIndex, product)
        appendIndex = appendIndex + 1
    end

    for _, key in ipairs(keys) do
        table.insert(result, appendIndex, saved[key])
        appendIndex = appendIndex + 1
    end

    return result
end

local function getPriceErrorText(error, vipServersEnabled, paidAccessEnabled, localization)
    if not error then return nil end

    local priceError

    if priceErrors[error] then
        local errorValue

        if error == BELOW_MIN then
            if vipServersEnabled then
                errorValue = string.format("%.f", FIntPrivateServersMinPrice)
            elseif paidAccessEnabled then
                errorValue = string.format("%.f", FIntPaidAccessMinPrice)
            else
                errorValue = string.format("%.f", FIntDevProductsMinPrice)
            end
        elseif error == ABOVE_MAX then
            if paidAccessEnabled then
                errorValue = string.format("%.f", FIntPaidAccessMaxPrice)
            else
                errorValue = string.format("%.f", FIntDevProductsMaxPrice)
            end
        end

        priceError = localization:getText("Errors", priceErrors[error], {errorValue})
    end

    return priceError
end

local function getNameErrorText(error, localization)
    if not error then return nil end

    local nameError
    if nameErrors[error] then
        if error == "Empty" then
            nameError = localization:getText("General", nameErrors[error])
        end
    end

    return nameError
end

local function sanitizeCurrentDevProduct(devProduct, initialName)
    local errorKeys = {}
    local name = devProduct.name
    local nameLength = utf8.len(name)
    local price = tonumber(devProduct.price)

    if nameLength < 1 or nameLength > FIntMaxNameLength then
        devProduct = Cryo.Dictionary.join(devProduct, {
            name = initialName
        })
        table.insert(errorKeys, "devProductName")
    end

    if type(price) ~= "number" or price < 1 then
        devProduct = Cryo.Dictionary.join(devProduct, {
            price = 1,
        })
        table.insert(errorKeys, "devProductPrice")
    end

    return devProduct, errorKeys
end

--Uses props to display current settings values
local function displayMonetizationPage(props)
    local localization = props.Localization
    local theme = props.Theme:get("Plugin")
    
    local taxRate = props.TaxRate
    local minimumFee = props.MinimumFee

    local paidAccessEnabled = props.PaidAccess.enabled
    local paidAccessPrice = props.PaidAccess.price

    local vipServers = props.VIPServers

    local unsavedDevProducts = props.UnsavedDevProducts and props.UnsavedDevProducts or {}
    local devProducts = props.DevProducts and props.DevProducts or {}
    local editedDevProducts = props.EditedDevProducts and props.EditedDevProducts or {}

    devProducts = Cryo.Dictionary.join(devProducts, editedDevProducts)

    local allDevProducts = combineUnsavedAndSavedDevProducts(unsavedDevProducts, devProducts)

    local devProductsForTable, numberOfDevProducts = convertDeveloperProductsForTable(allDevProducts, localization)

    local paidAccessToggled = props.PaidAccessToggled
    local paidAccessPriceChanged = props.PaidAccessPriceChanged

    local vipServersToggled = props.VIPServersToggled
    local vipServersPriceChanged = props.VIPServersPriceChanged

    local setUnsavedDevProducts = props.SetUnsavedDevProducts
    local setEditDevProductId = props.SetEditDevProductId
    local loadMoreDevProducts = props.LoadMoreDevProducts

    local isPublic = props.isPublic
    local isInitiallyEnabled = props.isInitiallyEnabled

    local badgesForTable, numberOfBadges, loadMoreBadges, refreshBadges, badgeLoadState
    local showBadges = ShouldAllowBadges()

    if showBadges then
        badgesForTable, numberOfBadges = convertBadgesForTable(props.Badges)
        loadMoreBadges = props.LoadMoreBadges
        refreshBadges = props.RefreshBadges
        badgeLoadState = props.BadgeLoadState
    end

    local developerSubscriptionCreated = props.OnDeveloperSubscriptionCreated

    local priceError = getPriceErrorText(props.AccessPriceError, vipServers.isEnabled, paidAccessEnabled, localization)

    local layoutIndex = LayoutOrderIterator.new()

    if not taxRate then
        paidAccessEnabled = nil
        vipServers.isEnabled = nil
    end

    return {
        BadgesLoadingIndicatorContainer = showBadges and badgeLoadState == LoadState.Loading and Roact.createElement(Container, {
            Size = UDim2.new(1, 0, 0, theme.table.height/2)
        }, {
            BadgesLoadingIndicator = Roact.createElement(LoadingIndicator, {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
            })
        }),
        
        Badges = showBadges and badgeLoadState ~= LoadState.Loading and Roact.createElement(Badges, {
            BadgeList = badgesForTable,
            LayoutOrder = layoutIndex:getNextOrder(),
            OnLoadMoreBadges = loadMoreBadges,
            RefreshBadges = refreshBadges,
        }),

        Separator =  showBadges and Roact.createElement(Separator, {
            LayoutOrder = layoutIndex:getNextOrder(),
            Size = UDim2.new(1, 0, 0, 1),
        }),
        
        PaidAccess = Roact.createElement(PaidAccess, {
            Price = paidAccessPrice,
            TaxRate = taxRate,
            MinimumFee = minimumFee,

            PriceError = paidAccessEnabled and priceError or nil,

            LayoutOrder = layoutIndex:getNextOrder(),
            -- Need to enable it if user already has it on nonpublic + monetized
            Enabled = vipServers.isEnabled == false and (paidAccessEnabled and isInitiallyEnabled or isPublic),
            Selected = paidAccessEnabled,

            OnPaidAccessToggle = function(button)
                local initialPrice = math.max(props.PaidAccess.initialPrice, FIntPaidAccessMinPrice)
                return paidAccessToggled(button, initialPrice)
            end,
            OnPaidAccessPriceChanged = paidAccessPriceChanged,
        }),

        VIPServers = Roact.createElement(VIPServers, {
            VIPServersData = vipServers,
            TaxRate = taxRate,
            MinimumFee = minimumFee,

            PriceError = vipServers.isEnabled and priceError or nil,

            LayoutOrder = layoutIndex:getNextOrder(),
            -- Need to enable it if user already has it on nonpublic + monetized
            Enabled = paidAccessEnabled == false and (vipServers.isEnabled and isInitiallyEnabled or isPublic),

            OnVipServersToggled = function(button)
                local initialPrice = math.max(props.VIPServers.initialPrice, FIntPrivateServersMinPrice)
                return vipServersToggled(button, initialPrice)
            end,
            OnVipServersPriceChanged = vipServersPriceChanged,
        }),

        DevSubsList = FFlagDeveloperSubscriptionsEnabled and Roact.createElement(DevSubList, {
            LayoutOrder = layoutIndex:getNextOrder(),
            OnDeveloperSubscriptionCreated = developerSubscriptionCreated,
        }),

        DevProducts = FFlagEnableDevProductsInGameSettings and Roact.createElement(DevProducts, {
            ProductList = devProductsForTable,
            ShowTable = numberOfDevProducts ~= 0,

            LayoutOrder = layoutIndex:getNextOrder(),

            CreateNewDevProduct = function()
                local nextNumber = string.format("%d", numberOfDevProducts + 1)
                nextDevProductName = localization:getText("Monetization", "UnsavedDevProductName1", {nextNumber})
                table.insert(unsavedDevProducts, 1, {
                    name = nextDevProductName,
                    price = 1,
                    iconImageAssetId = "None",
                })
                setUnsavedDevProducts(unsavedDevProducts, nil, nil)
            end,
            OnLoadMoreDevProducts = loadMoreDevProducts,
            OnEditDevProductClicked = setEditDevProductId
        }),
    }
end

local function displayEditDevProductsPage(props)
    local theme = props.Theme:get("Plugin")
    local localization = props.Localization

    local layoutIndex = LayoutOrderIterator.new()

    local productId = props.EditDevProductId

    local unsavedDevProducts = props.UnsavedDevProducts and props.UnsavedDevProducts or {}
    local devProducts = props.DevProducts and props.DevProducts or {}

    local initialName
    if devProducts[productId] then
        initialName = devProducts[productId].name
    elseif unsavedDevProducts[productId] then
        initialName = nextDevProductName
    end

    local editedDevProducts = props.EditedDevProducts and props.EditedDevProducts or {}
    devProducts = Cryo.Dictionary.join(devProducts, editedDevProducts)

    local allDevProducts = Cryo.Dictionary.join(unsavedDevProducts, devProducts)
    local currentDevProduct
    if FFlagStudioFixGameManagementIndexNil then
        currentDevProduct = allDevProducts[productId] or {}
    else
        currentDevProduct = allDevProducts[productId]
    end

    if not initialName then initialName = currentDevProduct.name end

    local productTitle = currentDevProduct.name
    local productPrice = currentDevProduct.price

    local setEditDevProductId = props.SetEditDevProductId
    local setDevProducts = props.SetDevProducts

    local dpPriceError = getPriceErrorText(props.DevProductPriceError, nil, nil, localization)
    local dpPriceErrorSize
    if dpPriceError then
        dpPriceErrorSize = GetTextSize(dpPriceError, theme.fontStyle.SmallError.TextSize, theme.fontStyle.SmallError.Font)
    else
        dpPriceErrorSize = {}
    end

    local dpNameError = getNameErrorText(props.DevProductNameError, localization)

    local setUnsavedDevProducts = props.SetUnsavedDevProducts

    return {
        HeaderFrame = Roact.createElement(FitFrameOnAxis, {
            LayoutOrder = layoutIndex:getNextOrder(),
            BackgroundTransparency = 1,
            axis = FitFrameOnAxis.Axis.Vertical,
            minimumSize = UDim2.new(1, 0, 0, 0),
            contentPadding = UDim.new(0, theme.settingsPage.headerPadding),
        }, {
            BackButton = Roact.createElement("ImageButton", {
                Size = UDim2.new(0, theme.backButton.size, 0, theme.backButton.size),
                LayoutOrder = 0,

                Image = theme.backButton.image,

                BackgroundTransparency = 1,

                [Roact.Event.Activated] = function()
                    local cleanDevProduct, errorKeys = sanitizeCurrentDevProduct(currentDevProduct, initialName)

                    if cleanDevProduct.id then
                        editedDevProducts = Cryo.Dictionary.join(editedDevProducts, {
                            [productId] = cleanDevProduct
                        })
                        setDevProducts(editedDevProducts, errorKeys)
                    else
                        unsavedDevProducts = Cryo.Dictionary.join(unsavedDevProducts, {
                            [productId] = cleanDevProduct
                        })
                        setUnsavedDevProducts(unsavedDevProducts, errorKeys)
                    end

                    setEditDevProductId(nil)
                end,
            }, {
                Roact.createElement(HoverArea, {Cursor = "PointingHand"}),
            }),

            Roact.createElement(Separator, {
                LayoutOrder = 1
            }),

            Header = Roact.createElement(Header, {
                Title = localization:getText("Monetization", "EditDeveloperProduct"),
                LayoutOrder = 2,
            }),
        }),

        Name = Roact.createElement(TitledFrame, {
            Title = localization:getText("General", "TitleName"),
            MaxHeight = 60,
            LayoutOrder = layoutIndex:getNextOrder(),
            TextSize = theme.fontStyle.Normal.TextSize,
        }, {
            TextBox = Roact.createElement(RoundTextBox, {
                Active = true,
                MaxLength = FIntMaxNameLength,
                Text = productTitle,
                TextSize = theme.fontStyle.Normal.TextSize,

                ErrorMessage = dpNameError,

                SetText = function(name)
                    local nameLength = utf8.len(name)

                    local errorKey = "devProductName"
                    local errorValue
                    if nameLength == 0 then
                        errorValue = "Empty"
                    end

                    currentDevProduct = Cryo.Dictionary.join(currentDevProduct, {
                        name = tostring(name),
                    })

                    if currentDevProduct.id then
                        editedDevProducts = Cryo.Dictionary.join(editedDevProducts, {
                            [productId] = currentDevProduct
                        })
                        setDevProducts(editedDevProducts, errorKey, errorValue)
                    else
                        unsavedDevProducts = Cryo.Dictionary.join(unsavedDevProducts, {
                            [productId] = currentDevProduct
                        })
                        setUnsavedDevProducts(unsavedDevProducts, errorKey, errorValue)
                    end
                end
            }),
        }),

        Price = Roact.createElement(TitledFrame, {
            Title = localization:getText("Monetization", "PriceTitle"),
            MaxHeight = 150,
            LayoutOrder = layoutIndex:getNextOrder(),
            TextSize = theme.fontStyle.Normal.TextSize,
        }, {
            VerticalLayout = Roact.createElement("UIListLayout",{
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
            }),

            --TODO: Change price entry in RobuxFeeBase and this to be a shared component
            PriceFrame = Roact.createElement(RoundFrame, {
                Size = UDim2.new(0, theme.robuxFeeBase.priceField.width, 0, theme.rowHeight),

                BorderColor3 = theme.textBox.borderDefault,
                BorderSizePixel = 1,
                BackgroundColor3 = theme.textBox.background,

                LayoutOrder = 1,
            },{
                HorizontalLayout = Roact.createElement("UIListLayout",{
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                }),

                RobuxIcon = Roact.createElement("ImageLabel", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, theme.robuxFeeBase.icon.size, 0, theme.robuxFeeBase.icon.size),

                    ImageColor3 = theme.robuxFeeBase.icon.imageColor,
                    Image = theme.robuxFeeBase.icon.image,

                    BackgroundTransparency = 1,
                }),

                PriceTextBox = Roact.createElement(TextEntry, Cryo.Dictionary.join(theme.fontStyle.Normal, {
                    Size = UDim2.new(1, -theme.robuxFeeBase.icon.size, 1, 0),
                    Visible = true,

                    Text = productPrice,
                    PlaceholderText = "",
                    Enabled = true,

                    SetText = function(price)
                        local numberValue = tonumber(price)

                        local errorKey = "devProductPrice"
                        local errorValue
                        if not numberValue then
                            errorValue = INVALID
                        elseif numberValue < FIntDevProductsMinPrice then
                            errorValue = BELOW_MIN
                        elseif numberValue > FIntDevProductsMaxPrice then
                            errorValue = ABOVE_MAX
                        end

                        currentDevProduct = Cryo.Dictionary.join(currentDevProduct, {
                            price = tostring(price)
                        })

                        if currentDevProduct.id then
                            editedDevProducts = Cryo.Dictionary.join(editedDevProducts, {
                                [productId] = currentDevProduct
                            })
                            setDevProducts(editedDevProducts, errorKey, errorValue)
                        else
                            unsavedDevProducts = Cryo.Dictionary.join(unsavedDevProducts, {
                                [productId] = currentDevProduct
                            })
                            setUnsavedDevProducts(unsavedDevProducts, errorKey, errorValue)
                        end
                    end,

                    FocusChanged = function()
                    end,

                    HoverChanged = function()
                    end,
                }))
            }),

            ErrorMessage = dpPriceError and Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.SmallError, {
                Size = UDim2.new(0, dpPriceErrorSize.X, 0, dpPriceErrorSize.Y),

                BackgroundTransparency = 1,

                Text = dpPriceError,

                TextYAlignment = Enum.TextYAlignment.Center,
                TextXAlignment = Enum.TextXAlignment.Left,

                TextWrapped = true,

                LayoutOrder = 2,
            }))
        }),
    }
end

local function displayEditDevSubPage(props)
    return {
        Roact.createElement(DevSubDetails, {
            SetDevSubKey = props.SetDevSubKey,
            OnDeveloperSubscriptionChanged = props.OnDeveloperSubscriptionChanged,
        })
    }
end

function Monetization:render()
    local props = self.props
    local localization = props.Localization

    local editDevProductId = props.EditDevProductId
    local isEditingSubscription = props.isEditingSubscription

    local createChildren
    local showHeader = editDevProductId == 0
    if isEditingSubscription then
        createChildren = function()
            return displayEditDevSubPage(props)
        end
    elseif editDevProductId == nil then
        if FFlagStudioFixMissingMonetizationHeader then
            showHeader = true
        end
        createChildren = function()
            return displayMonetizationPage(props)
        end
    elseif type(editDevProductId) == "number" then
        if FFlagStudioFixMissingMonetizationHeader then
            showHeader = false
        end
        createChildren = function()
            return displayEditDevProductsPage(props)
        end
    end

    return Roact.createElement(SettingsPage, {
        SettingsLoadJobs = loadSettings,
        SettingsSaveJobs = saveSettings,
        Title = localization:getText("General", "Category"..LOCALIZATION_ID),
        PageId = LOCALIZATION_ID,
        CreateChildren = createChildren,
        ShowHeader = showHeader,
    })
end

ContextServices.mapToProps(Monetization, {
    Localization = ContextServices.Localization,
    Theme = ContextServices.Theme,
})

local settingFromState = require(Plugin.Src.Networking.settingFromState)
Monetization = RoactRodux.connect(
    function(state, props)
        if not state then return end

        local getValue = function(propName)
            return settingFromState(state.Settings, propName)
        end

        return loadValuesToProps(getValue, state)
    end,

    function(dispatch)
        local setValue = function(propName)
            return function(value)
                dispatch(AddChange(propName, value))
            end
        end

        return dispatchChanges(setValue, dispatch)
    end
)(Monetization)

Monetization.LocalizationId = LOCALIZATION_ID

return Monetization
