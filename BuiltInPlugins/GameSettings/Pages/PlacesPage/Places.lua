--[[
    Settings page for Places settings:
        - Create place
        - List of places in game
        - Edit Place

	Settings:
        - Name
        - Server Fill
        - Max Players
        - Version History

	Errors:
		name: "Empty", "TooLong"
		description: "TooLong"
		devices: "NoDevices"
]]
local Plugin = script.Parent.Parent.Parent

local KeyProvider = require(Plugin.Src.Util.KeyProvider)
local GetEditKeyName = KeyProvider.getEditKeyName
local GetVersionHistoryKeyName = KeyProvider.getVersionHistoryKeyName

local Page = script.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local Cryo = require(Plugin.Cryo)

local Framework = Plugin.Framework
local ContextServices = require(Framework.ContextServices)

local FrameworkUI = require(Framework.UI)
local Button = FrameworkUI.Button
local HoverArea = FrameworkUI.HoverArea
local Separator = FrameworkUI.Separator
local LinkText = FrameworkUI.LinkText

local FrameworkUtil = require(Framework.Util)
local LayoutOrderIterator = FrameworkUtil.LayoutOrderIterator
local FitFrameOnAxis = FrameworkUtil.FitFrame.FitFrameOnAxis

local UILibrary = require(Plugin.UILibrary)
local GetTextSize = UILibrary.Util.GetTextSize
local deepJoin = UILibrary.Util.deepJoin
local TitledFrame = UILibrary.Component.TitledFrame
local RoundTextBox = UILibrary.Component.RoundTextBox

local Header = require(Plugin.Src.Components.Header)
local ServerFill = require(Page.Components.ServerFill)
local TableWithMenu = require(Plugin.Src.Components.TableWithMenu)
local RadioButtonSet = require(Plugin.Src.Components.RadioButtonSet)
local SettingsPage = require(Plugin.Src.Components.SettingsPages.SettingsPage)

local AddChange = require(Plugin.Src.Actions.AddChange)
local AddErrors = require(Plugin.Src.Actions.AddErrors)
local DiscardChanges = require(Plugin.Src.Actions.DiscardChanges)
local DiscardError = require(Plugin.Src.Actions.DiscardError)
local DiscardErrors = require(Plugin.Src.Actions.DiscardErrors)
local SetEditPlaceId = require(Plugin.Src.Actions.SetEditPlaceId)

local ReloadPlaces = require(Page.Thunks.ReloadPlaces)

local Places = Roact.PureComponent:extend(script.Name)

local LOCALIZATION_ID = script.Name

--[[
	TODO 7/8/2020 Fetch this from BE since it can be different based on logged-in user's roleset
	(and so we don't keep syncing with BE whenever it changes)
]]
local FIntStudioPlaceConfigurationMaxPlayerCount = game:DefineFastInt("StudioPlaceConfigurationMaxPlayerCount", 200)

local MAX_NAME_LENGTH = 50
local MIN_PLAYER_COUNT = 1
local MAX_PLAYER_COUNT = FIntStudioPlaceConfigurationMaxPlayerCount
local MIN_SOCIAL_SLOT_COUNT = 1
local MAX_SOCIAL_SLOT_COUNT = 10

local AssetManagerService = game:GetService("AssetManagerService")
local StudioService = game:GetService("StudioService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

local nameErrors = {
	Empty = "ErrorNameEmpty",
}

local FFlagFixRadioButtonSeAndTableHeadertForTesting = game:getFastFlag("FixRadioButtonSeAndTableHeadertForTesting")
local FFlagStudioFixGameManagementIndexNil = game:getFastFlag("StudioFixGameManagementIndexNil")

local function loadSettings(store, contextItems)
	local state = store:getState()
	local gameId = state.Metadata.gameId
	local placesController = contextItems.placesController

	return {
		function(loadedSettings)
			local places, placesPageCursor, index = placesController:getPlaces(gameId):await()

			loadedSettings["places"] = places
			loadedSettings["placesPageCursor"] = placesPageCursor
			loadedSettings["placesIndex"] = index
		end,
	}
end

local function saveSettings(store, contextItems)
	local state = store:getState()
	local placesController = contextItems.placesController
	local placeId = state.EditAsset.editPlaceId
	local places = state.Settings.Changed.places or {}

	return {
		function()
			local changed
			if FFlagStudioFixGameManagementIndexNil then
				changed = places[placeId]
			else
				changed = state.Settings.Changed.places[placeId]
			end

			if changed ~= nil and changed.name then
				placesController:setName(placeId, changed.name)
			end
		end,
		function()
			local changed
			if FFlagStudioFixGameManagementIndexNil then
				changed = places[placeId]
			else
				changed = state.Settings.Changed.places[placeId]
			end

			if changed ~= nil and changed.maxPlayerCount then
				placesController:setMaxPlayerCount(placeId, changed.maxPlayerCount)
			end
		end,
		function()
			local changed
			if FFlagStudioFixGameManagementIndexNil then
				changed = places[placeId]
			else
				changed = state.Settings.Changed.places[placeId]
			end

			if changed ~= nil and changed.allowCopying then
				placesController:setAllowCopying(placeId, changed.allowCopying)
			end
		end,
		function()
			local changed
			if FFlagStudioFixGameManagementIndexNil then
				changed = places[placeId]
			else
				changed = state.Settings.Changed.places[placeId]
			end

			if changed ~= nil and changed.socialSlotType then
				placesController:setSocialSlotType(placeId, changed.socialSlotType)
			end
		end,
		function()
			local changed
			if FFlagStudioFixGameManagementIndexNil then
				changed = places[placeId]
			else
				changed = state.Settings.Changed.places[placeId]
			end

			if changed ~= nil and changed.customSocialSlotsCount then
				placesController:setCustomSocialSlotsCount(placeId, changed.customSocialSlotsCount)
			end
		end,
	}
end

--Loads settings values into props by key
local function loadValuesToProps(getValue, state)
	local errors = state.Settings.Errors
	local loadedProps = {
		Places = getValue("places"),
		EditPlaceId = state.EditAsset.editPlaceId,

		PlaceNameError = errors.placeName,
		PlacePlayerCountError = errors.placePlayerCount,
		PlaceCustomSocialSlotCountError = errors.placeCustomSocialSlotsCount,
	}
	return loadedProps
end

--Implements dispatch functions for when the user changes values
local function dispatchChanges(setValue, dispatch)
	local dispatchFuncs = {
		dispatchReloadPlaces = function(forceReload)
			dispatch(ReloadPlaces(forceReload))
		end,

		dispatchSetEditPlaceId = function(placeId)
			dispatch(SetEditPlaceId(placeId))
		end,

		dispatchSetPlaceName = function(places, placeId, placeName)
			local nameLength = utf8.len(placeName)
			if nameLength == 0 then
				dispatch(AddErrors({placeName = "Empty"}))
			else
				local newPlaces = deepJoin(places, {
					[placeId] = {
						name = placeName,
					}
				})
				dispatch(AddChange("places", newPlaces))
				dispatch(DiscardError("placeName"))
				if nameLength > MAX_NAME_LENGTH then
					dispatch(AddErrors({placeName = "TooLong"}))
				end
			end
		end,

		dispatchSetPlaceMaxPlayerCount = function(places, placeId, maxPlayerCount)
			local numberPlayerCount = tonumber(maxPlayerCount)

			if not numberPlayerCount then
				dispatch(AddErrors({placePlayerCount = "Error"}))
			elseif numberPlayerCount and (numberPlayerCount < MIN_PLAYER_COUNT or numberPlayerCount > MAX_PLAYER_COUNT) then
				dispatch(AddErrors({placePlayerCount = "Error"}))
			else
				local newPlaces = deepJoin(places, {
					[placeId] = {
						maxPlayerCount = numberPlayerCount,
					}
				})
				dispatch(AddChange("places", newPlaces))
				dispatch(DiscardError("placePlayerCount"))
			end
		end,

		dispatchSetAllowCopyingEnabled = function(places, placeId, allowCopyingEnabled)
			local newPlaces = deepJoin(places, {
				[placeId] = {
					allowCopying = allowCopyingEnabled,
				}
			})
			dispatch(AddChange("places", newPlaces))
		end,

		dispatchSetSocialSlotType = function(places, placeId, socialSlotType)
			local newPlaces = deepJoin(places, {
				[placeId] = {
					socialSlotType = socialSlotType,
				}
			})
			dispatch(AddChange("places", newPlaces))
		end,

		dispatchSetCustomSocialSlotsCount = function(places, placeId, customSocialSlotsCount)
			local numberCustomSocialSlotsCount = tonumber(customSocialSlotsCount)

			if not numberCustomSocialSlotsCount then
				dispatch(AddErrors({placeCustomSocialSlotsCount = "Error"}))
			elseif numberCustomSocialSlotsCount and
			(numberCustomSocialSlotsCount < MIN_SOCIAL_SLOT_COUNT or numberCustomSocialSlotsCount > MAX_SOCIAL_SLOT_COUNT) then
				dispatch(AddErrors({placeCustomSocialSlotsCount = "Error"}))
			else
				local newPlaces = deepJoin(places, {
					[placeId] = {
						customSocialSlotsCount = numberCustomSocialSlotsCount,
					}
				})
				dispatch(AddChange("places", newPlaces))
				dispatch(DiscardError("placeCustomSocialSlotsCount"))
			end
		end,

		dispatchDiscardChanges = function()
			dispatch(DiscardChanges())
		end,

		dispatchDiscardErrors = function()
			dispatch(DiscardErrors())
		end,
	}

	return dispatchFuncs
end

local function createPlaceTableData(places)
	local data = {}

	for _, place in pairs(places) do
		local rowData = {
			index = place.index + 1,
			row = {
				place.currentSavedVersion,
				place.name,
				place.maxPlayerCount
			},
		}
		data[place.id] = rowData
	end

	return data
end

local function displayPlaceListPage(props, localization)
	local theme = props.Theme:get("Plugin")

	local layoutIndex = LayoutOrderIterator.new()

	local buttonText = localization:getText("General", "ButtonCreate")
	local buttonTextExtents = GetTextSize(buttonText, theme.fontStyle.Header.TextSize, theme.fontStyle.Header.Font)

	local dispatchReloadPlaces = props.dispatchReloadPlaces

	local placeTableHeaders
	if FFlagFixRadioButtonSeAndTableHeadertForTesting then
		placeTableHeaders = {
			{
				Text = localization:getText("Places", "PlaceVersion"),
				Id = "PlaceVersion",
			},
			{
				Text = localization:getText("Places", "PlaceName"),
				Id = "PlaceName",
			},
			{
				Text = localization:getText("Places", "MaxPlayers"),
				Id = "MaxPlayers",
			}
		}
	else
		placeTableHeaders = {
			localization:getText("Places", "PlaceVersion"),
			localization:getText("Places", "PlaceName"),
			localization:getText("Places", "MaxPlayers"),
		}
	end

	local places = props.Places and props.Places or {}
	local placesData = createPlaceTableData(places)

	return
	{
		CreateButton = Roact.createElement(Button, {
			Style = "GameSettingsPrimaryButton",
			Text = buttonText,
			Size = UDim2.new(0, buttonTextExtents.X + theme.createButton.PaddingX,
			0, buttonTextExtents.Y + theme.createButton.PaddingY),
			LayoutOrder = layoutIndex:getNextOrder(),
			OnClick = function()
				-- method already handles printing error message
				local success, _ = pcall(function() AssetManagerService:AddNewPlace() end)
				if success then
					dispatchReloadPlaces(FFlagStudioFixGameManagementIndexNil and true or nil)
				end
			end,
		}, {
			Roact.createElement(HoverArea, {Cursor = "PointingHand"}),
		}),

		PlacesTable = Roact.createElement(TableWithMenu, {
			LayoutOrder = layoutIndex:getNextOrder(),
			Headers = placeTableHeaders,
			Data = placesData,
			MenuItems = {
				{ Key = GetEditKeyName(), Text = localization:getText("General", "ButtonEdit") },
				{ Key = GetVersionHistoryKeyName(), Text = localization:getText("Places", "VersionHistory") },
			},
			OnItemClicked = function(key, id)
				if key == (GetEditKeyName()) then
					props.dispatchSetEditPlaceId(id)
				elseif key == (GetVersionHistoryKeyName()) then
					StudioService:ShowPlaceVersionHistoryDialog(id)
				end
			end,
			NextPageFunc = function()
				dispatchReloadPlaces()
			end
		})
	}
end

local function displayEditPlacePage(props, localization)
	local theme = props.Theme:get("Plugin")

	local layoutIndex = LayoutOrderIterator.new()

	local maxPlayersSubText = localization:getText("Places", "MaxPlayersSubText")
	local maxPlayersSubTextSize = GetTextSize(maxPlayersSubText, theme.fontStyle.Subtext.TextSize, theme.fontStyle.Subtext.Font)
	local viewButtonText = localization:getText("General", "ButtonView")
	local viewButtonFrameSize = Vector2.new(math.huge, theme.button.height)
	local viewButtonTextExtents = GetTextSize(viewButtonText, theme.fontStyle.Header.TextSize, theme.fontStyle.Header.Font, viewButtonFrameSize)

	local viewButtonButtonWidth = math.max(viewButtonTextExtents.X, theme.button.width)
	local viewButtonPaddingY = theme.button.height - viewButtonTextExtents.Y

	local viewButtonSize = UDim2.new(0, viewButtonButtonWidth, 0, viewButtonTextExtents.Y + viewButtonPaddingY)

	local places
	local editPlaceId = props.EditPlaceId
	local placeToEdit
	if FFlagStudioFixGameManagementIndexNil then
		places = props.Places or {}
		placeToEdit = places[editPlaceId] or {}
	else
		places = props.Places
		placeToEdit = places[editPlaceId]
	end
	local placeName = placeToEdit.name
	local placeNameError
	if props.PlaceNameError and nameErrors[props.PlaceNameError] then
		placeNameError = localization:getText("General", nameErrors[props.PlaceNameError])
	end

	local maxPlayerCount = placeToEdit.maxPlayerCount
	local placePlayerCountError
	if props.PlacePlayerCountError then
		placePlayerCountError = localization:getText("Places", "NumberError", {minRange = MIN_PLAYER_COUNT, maxRange = MAX_PLAYER_COUNT, })
	end

	local allowCopying = placeToEdit.allowCopying

	local serverFill = placeToEdit.socialSlotType
	local customSocialSlotsCount = placeToEdit.customSocialSlotsCount
	local placeCustomSocialSlotCountError
	if props.PlaceCustomSocialSlotCountError then
		placeCustomSocialSlotCountError = localization:getText("Places", "NumberError", {minRange = MIN_SOCIAL_SLOT_COUNT, maxRange = MAX_SOCIAL_SLOT_COUNT, })
	end

	local dispatchSetPlaceName = props.dispatchSetPlaceName
	local dispatchSetPlaceMaxPlayerCount = props.dispatchSetPlaceMaxPlayerCount
	local dispatchSetSocialSlotType = props.dispatchSetSocialSlotType
	local dispatchSetCustomSocialSlotsCount = props.dispatchSetCustomSocialSlotsCount
	local dispatchSetAllowCopyingEnabled = props.dispatchSetAllowCopyingEnabled

	local allowCopyingDesc = localization:getText("General", "AllowCopyingDesc")
	local allowCopyingDescSize = TextService:GetTextSize(allowCopyingDesc, theme.fontStyle.Subtext.TextSize,
		theme.fontStyle.Subtext.Font, Vector2.new(theme.radioButton.descriptionWidth, math.huge))

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
					props.dispatchDiscardChanges()
					props.dispatchDiscardErrors()
					props.dispatchSetEditPlaceId(0)
				end,
			}, {
				Roact.createElement(HoverArea, {Cursor = "PointingHand"}),
			}),

			Roact.createElement(Separator, {
				LayoutOrder = 1
			}),

			Header = Roact.createElement(Header, {
				Title = localization:getText("Places", "EditPlace"),
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
				MaxLength = MAX_NAME_LENGTH,
				ErrorMessage = placeNameError,
				Text = placeName,
				TextSize = theme.fontStyle.Normal.TextSize,

				SetText = function(name)
					dispatchSetPlaceName(places, editPlaceId, name)
				end,
			}),
		}),

		MaxPlayers = Roact.createElement(TitledFrame, {
			Title = localization:getText("Places", "MaxPlayers"),
			MaxHeight = 60,
			LayoutOrder = layoutIndex:getNextOrder(),
			TextSize = theme.fontStyle.Normal.TextSize,
		}, {
			HeaderLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			TextBox = Roact.createElement(RoundTextBox, {
				Active = true,
				LayoutOrder = 1,
				ShowToolTip = placePlayerCountError and true or false,
				Size = UDim2.new(0, theme.placePage.textBox.length, 0, theme.textBox.height),
				Text = maxPlayerCount,
				ErrorMessage = placePlayerCountError,
				TextSize = theme.fontStyle.Normal.TextSize,

				SetText = function(playerCount)
					dispatchSetPlaceMaxPlayerCount(places, editPlaceId, playerCount)
				end,
			}),

			MaxPlayersSubText = not placePlayerCountError and Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Subtext, {
				Size = UDim2.new(1, 0, 0, maxPlayersSubTextSize.Y),
				LayoutOrder = 2,

				BackgroundTransparency = 1,

				Text = maxPlayersSubText,

				TextYAlignment = Enum.TextYAlignment.Center,
				TextXAlignment = Enum.TextXAlignment.Left,

				TextWrapped = true,
			})),
		}),

		ServerFill = Roact.createElement(ServerFill, {
            LayoutOrder = layoutIndex:getNextOrder(),
			Enabled = true,

			CustomSocialSlotsCount = customSocialSlotsCount,
			Selected = serverFill,
			ErrorMessage = placeCustomSocialSlotCountError,

			OnSocialSlotTypeChanged = function(button)
				dispatchSetSocialSlotType(places, editPlaceId, button.Id)
			end,
			OnCustomSocialSlotsCountChanged = function(customSocialSlotsCount)
				dispatchSetCustomSocialSlotsCount(places, editPlaceId, customSocialSlotsCount)
			end,
		}),

		AllowCopying = Roact.createElement(RadioButtonSet, {
			Title = localization:getText("General", "TitleAllowCopying"),
			Buttons = {{
					Id = true,
					Title = localization:getText("General", "SettingOn"),
					Children = {
						LinkText = Roact.createElement(LinkText, {
							Text = allowCopyingDesc,
							Size = UDim2.new(0, allowCopyingDescSize.X, 0, allowCopyingDescSize.Y),
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
							OnClick = function()
								GuiService:OpenBrowserWindow(StudioService:GetTermsOfUseUrl())
							end,
						}),
				}}, {
					Id = false,
					Title = localization:getText("General", "SettingOff"),
				}
			},
			Enabled = true,
			LayoutOrder = layoutIndex:getNextOrder(),
			Selected = allowCopying,
			SelectionChanged = function(button)
				dispatchSetAllowCopyingEnabled(places, editPlaceId, button.Id)
			end,
		}),

		VersionHistory = Roact.createElement(TitledFrame, {
			Title = localization:getText("Places", "VersionHistory"),
			MaxHeight = 60,
			LayoutOrder = layoutIndex:getNextOrder(),
			TextSize = theme.fontStyle.Normal.TextSize,
		}, {
			ViewButton = Roact.createElement(Button, {
				Style = "GameSettingsButton",
				Text = viewButtonText,
				Size = viewButtonSize,
				LayoutOrder = layoutIndex:getNextOrder(),
				OnClick = function()
					StudioService:ShowPlaceVersionHistoryDialog(editPlaceId)
				end,
			}, {
				Roact.createElement(HoverArea, {Cursor = "PointingHand"}),
			}),
		})
	}
end

function Places:render()
	local props = self.props
	local localization = props.Localization

	local editPlaceId = props.EditPlaceId

	local createChildren
	if editPlaceId == 0 then
		createChildren = function()
			return displayPlaceListPage(props, localization)
		end
	else
		createChildren = function()
			return displayEditPlacePage(props, localization)
		end
	end

	return Roact.createElement(SettingsPage, {
		SettingsLoadJobs = loadSettings,
		SettingsSaveJobs = saveSettings,
		Title = localization:getText("General", "Category"..LOCALIZATION_ID),
		PageId = LOCALIZATION_ID,
		CreateChildren = createChildren,
		ShowHeader = editPlaceId == 0,
	})
end

ContextServices.mapToProps(Places, {
	Localization = ContextServices.Localization,
	Theme = ContextServices.Theme,
})

local settingFromState = require(Plugin.Src.Networking.settingFromState)
Places = RoactRodux.connect(
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
)(Places)

Places.LocalizationId = LOCALIZATION_ID

return Places
