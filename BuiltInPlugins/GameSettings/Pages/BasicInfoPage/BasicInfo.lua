--[[
	Settings page for Basic Info settings.
		- Game name and description
		- Game privacy settings (who is allowed to play the game)
		- Playable Devices (which devices can run this game)
		- Genre
		- Thumbnails (Screenshots and Video)
		- Game Icon

	Settings:
		string Name - The game name
		bool IsActive - Whether the game is public or private
		bool IsFriendsOnly - Whether the game is open to everyone or only friends/group members
		string Group - The name of the group that owns this game, if one does
		string Description - The game description
		string Genre - The genre of this game
		table Devices - A table of which devices are playable
		table Thumbnails - A table of this game's thumbnails
		list Order - The order in which this game's thumbnails display
		string GameIcon - The rbxassetid url of the game's icon, or "None" if no icon exists.

	Errors:
		name: "Empty", "TooLong"
		description: "TooLong"
		devices: "NoDevices"
]]

local FFlagLuobuDevPublishLua = game:GetFastFlag("LuobuDevPublishLua")
local FFlagLuobuDevPublishLuaTempOptIn = game:GetFastFlag("LuobuDevPublishLuaTempOptIn")
local FFlagUseLayoutIteratorGameSettingsPublishPlace = game:GetFastFlag("UseLayoutIteratorGameSettingsPublishPlace")

local StudioService = game:GetService("StudioService")
local GuiService = game:GetService("GuiService")

local LOCALIZATION_ID = script.Name

local MAX_NAME_LENGTH = 50
local MAX_DESCRIPTION_LENGTH = 1000

local nameErrors = {
	Moderated = "ErrorNameModerated",
	Empty = "ErrorNameEmpty",
}

local descriptionErrors = {
	Moderated = "ErrorDescModerated",
}

local imageErrors = {
	UploadingTooQuickly = "ErrorImageLimit",
	ImageNotRecognized = "ErrorImageNotRecognized",
}

local Page = script.Parent
local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local Cryo = require(Plugin.Cryo)
local UILibrary = require(Plugin.UILibrary)
local ContextServices = require(Plugin.Framework.ContextServices)

local Dialog = require(Plugin.Src.ContextServices.Dialog)

local TitledFrame = UILibrary.Component.TitledFrame
local CheckBoxSet = require(Plugin.Src.Components.CheckBoxSet)
local RoundTextBox = UILibrary.Component.RoundTextBox
local Dropdown = require(Plugin.Src.Components.Dropdown)
local Separator = require(Plugin.Framework).UI.Separator
local ThumbnailController = require(Page.Components.Thumbnails.ThumbnailController)
local UploadableIconWidget = require(Plugin.Src.Components.UploadableIcon.UploadableIconWidget)
local SettingsPage = require(Plugin.Src.Components.SettingsPages.SettingsPage)
local ListDialog = require(Plugin.Src.Components.Dialog.ListDialog)
local SimpleDialog = require(Plugin.Src.Components.Dialog.SimpleDialog)
local InsufficientPermissionsPage = require(Plugin.Src.Components.SettingsPages.InsufficientPermissionsPage)

local AddChange = require(Plugin.Src.Actions.AddChange)
local AddErrors = require(Plugin.Src.Actions.AddErrors)
local SetCreatorId = require(Plugin.Src.Actions.SetCreatorId)
local SetCreatorType = require(Plugin.Src.Actions.SetCreatorType)

local FileUtils = require(Plugin.Src.Util.FileUtils)
local DEPRECATED_Constants = require(Plugin.Src.Util.DEPRECATED_Constants)

local shouldShowDevPublishLocations = require(Plugin.Src.Util.GameSettingsUtilities).shouldShowDevPublishLocations
local getPlayerAppDownloadLink = require(Plugin.Src.Util.GameSettingsUtilities).getPlayerAppDownloadLink
local getOptInLocationsRequirementsLink = require(Plugin.Src.Util.GameSettingsUtilities).getOptInLocationsRequirementsLink

local KeyProvider = require(Plugin.Src.Util.KeyProvider)

local GetOptInLocationsKeyName = KeyProvider.getOptInLocationsKeyName
local optInLocationsKey = (FFlagLuobuDevPublishLua or FFlagLuobuDevPublishLuaTempOptIn) and GetOptInLocationsKeyName and GetOptInLocationsKeyName() or "OptInLocations"

local GetChinaKeyName = KeyProvider.getChinaKeyName
local chinaKey = FFlagLuobuDevPublishLua and GetChinaKeyName() or nil

local GetPlayerAcceptanceKeyName = KeyProvider.getPlayerAcceptanceKeyName
local playerAcceptanceKey = FFlagLuobuDevPublishLua and GetPlayerAcceptanceKeyName() or nil

local Framework = require(Plugin.Framework)
local Tooltip = Framework.UI.Tooltip
local Image = Framework.UI.Decoration.Image
local HoverArea = Framework.UI.HoverArea
local TextWithInlineLink = Framework.UI.TextWithInlineLink
local LinkText = Framework.UI.LinkText

local Util = Framework.Util
local StyleModifier = Util.StyleModifier
local LayoutOrderIterator = Util.LayoutOrderIterator
local deepJoin = Util.deepJoin
local PartialHyperlink = UILibrary.Studio.PartialHyperlink

local function loadSettings(store, contextItems)
	local state = store:getState()
	local gameId = state.Metadata.gameId
	local gameInfoController = contextItems.gameInfoController
	local gameMetadataController = contextItems.gameMetadataController
	local policyInfoController = contextItems.policyInfoController

	return {
		function(loadedSettings)
			local name = gameInfoController:getName(gameId)

			loadedSettings["name"] = name
		end,
		function(loadedSettings)
			local description = gameInfoController:getDescription(gameId)

			loadedSettings["description"] = description
		end,
		function(loadedSettings)
			local genre = gameInfoController:getGenre(gameId)

			loadedSettings["genre"] = genre
		end,
		function(loadedSettings)
			local devices = gameInfoController:getSupportedDevices(gameId)

			local formatted = {}
			for _,v in ipairs(devices) do
				formatted[v] = true
			end

			loadedSettings["playableDevices"] = formatted
		end,
		function(loadedSettings)
			local thumbnails = gameInfoController:getThumbnails(gameId)

			local formatted = {}
			local order = {}
			for _, thumbnail in pairs(thumbnails) do
				local stringId = tostring(thumbnail.id)
				formatted[stringId] = thumbnail
				table.insert(order, stringId)
			end

			loadedSettings["thumbnailOrder"] = order
			loadedSettings["thumbnails"] = formatted
		end,
		function(loadedSettings)
			local gameIcon, isApproved = gameInfoController:getIcon(gameId)

			loadedSettings["gameIcon"] = gameIcon or "None"
			loadedSettings["gameIconApproved"] = isApproved
		end,
		function(loadedSettings)
			local ownerId = gameMetadataController:getCreatorId(gameId)

			store:dispatch(SetCreatorId(ownerId))
		end,
		function(loadedSettings)
			local ownerType = gameMetadataController:getCreatorType(gameId)

			store:dispatch(SetCreatorType(ownerType))
		end,
		function(loadedSettings)
			if FFlagLuobuDevPublishLua and shouldShowDevPublishLocations() then
				--[[
					Endpoint returns optInLocations in the following format:
						[
							{
								"region": "China",
								"status": "Approved"
							},
						]
					This function transforms it into the following format so changes are applied properly to the store:
						{
							China = {
								status = "Unknown",
								selected = false,
							}
						}
				]]

				local optInLocations = gameInfoController:getOptInLocations(gameId)

				local transformedOptInLocations = {}
				if optInLocations == nil or next(optInLocations) == nil then
					transformedOptInLocations = {
						China = {
							status = "Unknown",
							selected = false,
						}
					}
				else
					for _,location in pairs(optInLocations) do
						transformedOptInLocations[location.region] = {
							status = location.status,
							selected = location.status ~= "Removed" and location.status ~= "Unknown"
						}
					end

				end
				loadedSettings[optInLocationsKey] = transformedOptInLocations
			end
		end,
		function(loadedSettings)
			if FFlagLuobuDevPublishLua and shouldShowDevPublishLocations() then
				loadedSettings[playerAcceptanceKey] = policyInfoController:getPlayerAcceptances()
			end
		end,
	}
end

local function saveSettings(store, contextItems)
	local state = store:getState()
	local gameId = state.Metadata.gameId
	local gameInfoController = contextItems.gameInfoController

	return {
		function()
			local changed = state.Settings.Changed.name

			if changed ~= nil then
				local success, result = pcall(function()
					gameInfoController:setName(gameId, changed)
				end)

				if not success then
					if result == gameInfoController.NameModerated then
						store:dispatch(AddErrors({name = "Moderated"}))
					end

					error("Game name was moderated")
				end
			end
		end,
		function()
			local changed = state.Settings.Changed.description

			if changed ~= nil then
				local success, result = pcall(function()
					gameInfoController:setDescription(gameId, changed)
				end)

				if not success then
					if result == gameInfoController.DescriptionModerated then
						store:dispatch(AddErrors({description = "Moderated"}))
					end

					error("Game description was moderated")
				end
			end
		end,
		function()
			local changed = state.Settings.Changed.genre

			if changed ~= nil then
				gameInfoController:setGenre(gameId, changed)
			end
		end,
		function()
			local changed = state.Settings.Changed.playableDevices

			if changed ~= nil then
				local changedDevices = {}
				for k,v in pairs(changed) do
					if v then
						table.insert(changedDevices, k)
					end
				end

				gameInfoController:setSupportedDevices(gameId, changedDevices)
			end
		end,
		function(loadedSettings)
			local currentThumbnails = state.Settings.Current.thumbnails
			local changedThumbnails = state.Settings.Changed.thumbnails

			local currentOrder = state.Settings.Current.thumbnailOrder
			local changedOrder = state.Settings.Changed.thumbnailOrder

			if changedThumbnails ~= nil or changedOrder ~= nil then
				if currentThumbnails and changedThumbnails then
					local thumbnailFilesToAdd = {}
					local thumbnailIdsToRemove = {}

					for thumbnailId in pairs(currentThumbnails) do
						if changedThumbnails[thumbnailId] == nil then
							table.insert(thumbnailIdsToRemove, tonumber(thumbnailId))
						end
					end
					for id, data in pairs(changedThumbnails) do
						if currentThumbnails[id] == nil then
							table.insert(thumbnailFilesToAdd, data.asset)
						end
					end

					local lastError
					local pendingJobs = 0
					if #thumbnailIdsToRemove > 0 then
						pendingJobs = pendingJobs + 1
						coroutine.wrap(function()
							local success, result = pcall(function() gameInfoController:removeThumbnails(gameId, thumbnailIdsToRemove) end)
							if not success then lastError = result end
							pendingJobs = pendingJobs - 1
						end)()
					end
					if #thumbnailFilesToAdd > 0 then
						pendingJobs = pendingJobs + 1
						coroutine.wrap(function()
							local success, result = pcall(function() return gameInfoController:addThumbnails(gameId, thumbnailFilesToAdd) end)
							if success then
								for thumbnailFile,thumbnailId in pairs(result) do
									local oldIndex = Cryo.List.find(changedOrder, thumbnailFile:GetTemporaryId())
									changedOrder = Cryo.Dictionary.join(changedOrder, { [oldIndex] = thumbnailId })
								end
							else
								lastError = result
							end
							pendingJobs = pendingJobs - 1
						end)()
					end

					while pendingJobs > 0 do wait() end

					if lastError then
						error(lastError)
					end
				end

				if currentOrder ~= changedOrder then
					for index,thumbnailId in pairs(changedOrder) do
						changedOrder = Cryo.Dictionary.join(changedOrder, { [index] = tonumber(thumbnailId) })
					end
					gameInfoController:setThumbnailsOrder(gameId, changedOrder)
				end
			end
		end,
		function()
			local changed = state.Settings.Changed.gameIcon

			if changed ~= nil then
				gameInfoController:setIcon(gameId, changed)
			end
		end,
		function()
			if FFlagLuobuDevPublishLua and shouldShowDevPublishLocations() then
				local changed = state.Settings.Changed[optInLocationsKey]

				if changed ~= nil then
					local optInLocations = {}
					local optOutLocations = {}
					for region,values in pairs(changed) do
						if values.selected then
							table.insert(optInLocations, region)
						else
							table.insert(optOutLocations, region)
						end
					end

					gameInfoController:setOptInLocations(gameId, optInLocations, optOutLocations)
				end
			end
		end,
	}
end

--Loads settings values into props by key
local function loadValuesToProps(getValue, state)
	local errors = state.Settings.Errors
	local loadedProps = {
		Name = getValue("name"),
		Description = getValue("description"),
		Genre = getValue("genre"),
		Devices = getValue("playableDevices"),
		Thumbnails = getValue("thumbnails"),
		ThumbnailOrder = getValue("thumbnailOrder"),
		GameIcon = getValue("gameIcon"),
		OptInLocations = FFlagLuobuDevPublishLua and shouldShowDevPublishLocations() and getValue(optInLocationsKey) or nil,

		PlayerAcceptance = FFlagLuobuDevPublishLua and shouldShowDevPublishLocations() and getValue(playerAcceptanceKey) or nil,

		NameError = errors.name,
		DescriptionError = errors.description,
		DevicesError = errors.playableDevices,

		IsCurrentlyActive =  state.Settings.Current.isActive,

		OwnerId = state.GameOwnerMetadata.creatorId,
		OwnerType = state.GameOwnerMetadata.creatorType,
	}

	loadedProps.ThumbnailsError = errors.thumbnails
	loadedProps.GameIconError = errors.gameIcon

	return loadedProps
end

--Implements dispatch functions for when the user changes values
local function dispatchChanges(setValue, dispatch)
	local dispatchFuncs = {
		ThumbnailsChanged = setValue("thumbnails"),
		GenreChanged = setValue("genre"),

		NameChanged = function(text)
			dispatch(AddChange("name", text))
			local nameLength = utf8.len(text)
			if nameLength == 0 or string.len((string.gsub(text, " ", ""))) == 0 then
				dispatch(AddErrors({name = "Empty"}))
			elseif nameLength > MAX_NAME_LENGTH then
				dispatch(AddErrors({name = "TooLong"}))
			end
		end,
		DescriptionChanged = function(text)
			dispatch(AddChange("description", text))
			local descriptionLength = string.len(text)
			if descriptionLength > MAX_DESCRIPTION_LENGTH then
				dispatch(AddErrors({description = "TooLong"}))
			end
		end,
		DevicesChanged = function(devices)
			dispatch(AddChange("playableDevices", devices))
			for _, value in pairs(devices) do
				if value then
					return
				end
			end
			dispatch(AddErrors({playableDevices = "NoDevices"}))
		end,
		OptInLocationsChanged = function(locations)
			if FFlagLuobuDevPublishLua and shouldShowDevPublishLocations() then
				dispatch(AddChange(optInLocationsKey, locations))
			end
		end,
	}

	dispatchFuncs.GameIconChanged = setValue("gameIcon")
	dispatchFuncs.AddThumbnails = function(newThumbnails, oldThumbnails, oldOrder)
		local thumbnails = Cryo.Dictionary.join(oldThumbnails, {})
		local order = Cryo.List.join(oldOrder, {})
		for _, thumbnail in pairs(newThumbnails) do
			local id = thumbnail:GetTemporaryId()
			table.insert(order, id)
			thumbnails[id] = {
				asset = thumbnail,
				tempId = id,
			}
		end
		dispatch(AddChange("thumbnails", thumbnails))
		dispatch(AddChange("thumbnailOrder", order))

		if #order > DEPRECATED_Constants.MAX_THUMBNAILS then
			dispatch(AddErrors({thumbnails = "TooMany"}))
		end
	end

	dispatchFuncs.ThumbnailOrderChanged = function(order)
		dispatch(AddChange("thumbnailOrder", order))
		if #order > DEPRECATED_Constants.MAX_THUMBNAILS then
			dispatch(AddErrors({thumbnails = "TooMany"}))
		end
	end

	return dispatchFuncs
end

local BasicInfo = Roact.PureComponent:extend(script.Name)

function BasicInfo:hasPermissionToEdit()
	local props = self.props

	local ownerId = props.OwnerId
	local ownerType = props.OwnerType

	return ownerType == Enum.CreatorType.Group or ownerId == StudioService:GetUserId()
end

local function calculateTextSize(text, textSize, font)
	local hugeFrameSizeNoTextWrapping = Vector2.new(5000, 5000)
	return game:GetService('TextService'):GetTextSize(text, textSize, font, hugeFrameSizeNoTextWrapping)
end

function BasicInfo:init()
	self.state = FFlagLuobuDevPublishLua and {
		-- StyleModifier must be upper case first character because of how Theme in ContextServices uses it.
		StyleModifier = nil,
	} or nil

	self.addIcons = function()
		local props = self.props
		local icon = FileUtils.PromptForGameIcon(self, props.Localization)

		if icon then
			self.props.GameIconChanged(icon)
		end
	end

	self.addThumbnails = function()
		local props = self.props
		local newThumbnails = FileUtils.PromptForThumbnails(self, props.Localization, props.Dialog.showDialog)

		if newThumbnails then
			self.props.AddThumbnails(newThumbnails, props.Thumbnails, props.ThumbnailOrder)
		end
	end

	self.getModerationStatus = FFlagLuobuDevPublishLua and function(self, location, status)
		local theme = self.props.Theme:get("Plugin")
		local localization = self.props.Localization

		local statusText = localization:getText(optInLocationsKey, "Status")
		local textColor = theme.fontStyle.Subtext.TextColor3
		local show = true

		if status == "Approved" then
			local value = status .. location
			statusText = statusText .. localization:getText(optInLocationsKey, value)
		elseif status == "In review" then
			statusText = statusText .. localization:getText(optInLocationsKey, "InReview")
		elseif status == "Rejected" then
			textColor = theme.fontStyle.Error.TextColor3
			statusText = statusText .. localization:getText(optInLocationsKey, status)
		else
			show = false
		end

		return {
			statusText = statusText,
			textColor = textColor,
			show = show,
		}
	end or nil

	self.onMouseEnter = FFlagLuobuDevPublishLua and function()
		if self.state.StyleModifier == nil then
			self:setState({
				StyleModifier = StyleModifier.Hover,
			})
		end
	end or nil

	self.onMouseLeave = FFlagLuobuDevPublishLua and function()
		if self.state.StyleModifier == StyleModifier.Hover then
			self:setState({
				StyleModifier = Roact.None,
			})
		end
	end or nil


	self.createOptInLocationBoxes = FFlagLuobuDevPublishLua and function(self, layoutOrder)
		local props = self.props
		local localization = self.props.Localization
		local theme = (FFlagLuobuDevPublishLua or FFlagLuobuDevPublishLuaTempOptIn) and self.props.Theme:get("Plugin") or nil

		local optInLocations = props[optInLocationsKey]

		local boxes = {}

		for region,values in pairs(optInLocations) do
			local status = values.status
			local selected = values.selected

			local moderationStatus = self:getModerationStatus(region, status)

			table.insert(boxes, {
				Id = region,
				Title = localization:getText("General", "Location" .. region),
				Selected = selected,
				LinkTextFrame = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					LayoutOrder = FFlagUseLayoutIteratorGameSettingsPublishPlace and layoutOrder:getNextOrder() or 150,
					Size = UDim2.new(1, theme.requirementsLink.length, 0, theme.requirementsLink.height),
					Position = UDim2.new(0, 0, 0, theme.requirementsLink.paddingY),
				}, {
					UILayout = Roact.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						Padding = UDim.new(0, theme.requirementsLink.paddingX),
					}),

					ModerationStatus = moderationStatus.show and Roact.createElement("TextLabel", {
						Size = UDim2.new(0, calculateTextSize(moderationStatus.statusText, theme.fontStyle.Subtext.TextSize, theme.fontStyle.Subtext.Font).X, 0, theme.fontStyle.Subtext.TextSize),
						BackgroundTransparency = 1,
						Text = moderationStatus.statusText,
						TextColor3 = moderationStatus.textColor,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextSize = theme.fontStyle.Subtext.TextSize,
						Font = theme.fontStyle.Subtext.Font,
						LayoutOrder = -1,
					}) or nil,

					RequirementsText = Roact.createElement(PartialHyperlink, {
						HyperLinkText = localization:getText(optInLocationsKey, "RequirementsLinkText"),
						NonHyperLinkText = localization:getText(optInLocationsKey, "ChinaRequirements"),
						Style = "RequirementsLink",
						Mouse = props.Mouse:get(),
						OnClick = function()
							local url = getOptInLocationsRequirementsLink(chinaKey)
							GuiService:OpenBrowserWindow(url)
						end,
					})
				})
			})
		end

		return boxes
	end
end

function BasicInfo:render()
	local localization = self.props.Localization
	local theme = (FFlagLuobuDevPublishLua or FFlagLuobuDevPublishLuaTempOptIn) and self.props.Theme:get("Plugin") or nil

	local layoutOrder = FFlagUseLayoutIteratorGameSettingsPublishPlace and LayoutOrderIterator.new() or nil
	local layoutOrder2 = (FFlagUseLayoutIteratorGameSettingsPublishPlace and FFlagLuobuDevPublishLuaTempOptIn and shouldShowDevPublishLocations()) and LayoutOrderIterator.new() or nil

	local function createChildren()
		if not self:hasPermissionToEdit() then
			return {
				InsufficientPermission = Roact.createElement(InsufficientPermissionsPage)
			}
		end

		local props = self.props

		local devices = props.Devices
		local dialog = props.Dialog

		local optInLocations
		local playerAcceptance
		if FFlagLuobuDevPublishLua and shouldShowDevPublishLocations() then
			optInLocations = props[optInLocationsKey]
			playerAcceptance = props.PlayerAcceptance and props.PlayerAcceptance or nil
		end

		local localizedGenreList = {
			{Id = "All", Title = localization:getText("General", "GenreAll")},
			{Id = "Adventure", Title = localization:getText("General", "GenreAdventure")},
			{Id = "Tutorial", Title = localization:getText("General", "GenreBuilding")},
			{Id = "Funny", Title = localization:getText("General", "GenreComedy")},
			{Id = "Ninja", Title = localization:getText("General", "GenreFighting")},
			{Id = "FPS", Title = localization:getText("General", "GenreFPS")},
			{Id = "Scary", Title = localization:getText("General", "GenreHorror")},
			{Id = "Fantasy", Title = localization:getText("General", "GenreMedieval")},
			{Id = "War", Title = localization:getText("General", "GenreMilitary")},
			{Id = "Pirate", Title = localization:getText("General", "GenreNaval")},
			{Id = "RPG", Title = localization:getText("General", "GenreRPG")},
			{Id = "SciFi", Title = localization:getText("General", "GenreSciFi")},
			{Id = "Sports", Title = localization:getText("General", "GenreSports")},
			{Id = "TownAndCity", Title = localization:getText("General", "GenreTownAndCity")},
			{Id = "WildWest", Title = localization:getText("General", "GenreWestern")},
		}

		local nameError
		if props.NameError and nameErrors[props.NameError] then
			nameError = localization:getText("General", nameErrors[props.NameError])
		end

		local descriptionError
		if props.DescriptionError and descriptionErrors[props.DescriptionError] then
			descriptionError = localization:getText("General", descriptionErrors[props.DescriptionError])
		end

		local gameIconError
		if props.GameIconError and imageErrors[props.GameIconError] then
			gameIconError = localization:getText("General", imageErrors[props.GameIconError])
		end

		local thumbnailError
		if props.ThumbnailsError and imageErrors[props.ThumbnailsError] then
			thumbnailError = localization:getText("General", imageErrors[props.ThumbnailsError])
		end

		local devicesError = nil
		if props.DevicesError then
			devicesError = localization:getText("General", "ErrorNoDevices")
		end

		return {
			Name = Roact.createElement(TitledFrame, {
				Title = localization:getText("General", "TitleName"),
				MaxHeight = 60,
				LayoutOrder = FFlagUseLayoutIteratorGameSettingsPublishPlace and layoutOrder:getNextOrder() or 10,
				TextSize = DEPRECATED_Constants.TEXT_SIZE,
			}, {
				TextBox = Roact.createElement(RoundTextBox, {
					Active = props.Name ~= nil,
					ErrorMessage = nameError,
					MaxLength = MAX_NAME_LENGTH,
					Text = props.Name or "",
					TextSize = DEPRECATED_Constants.TEXT_SIZE,

					SetText = props.NameChanged,
				}),
			}),

			Description = Roact.createElement(TitledFrame, {
				Title = localization:getText("General", "TitleDescription"),
				MaxHeight = 150,
				LayoutOrder = FFlagUseLayoutIteratorGameSettingsPublishPlace and layoutOrder:getNextOrder() or 20,
				TextSize = DEPRECATED_Constants.TEXT_SIZE,
			}, {
				TextBox = Roact.createElement(RoundTextBox, {
					Height = 130,
					Multiline = true,

					Active = props.Description ~= nil,
					ErrorMessage = descriptionError,
					MaxLength = MAX_DESCRIPTION_LENGTH,
					Text = props.Description or "",
					TextSize = DEPRECATED_Constants.TEXT_SIZE,

					SetText = props.DescriptionChanged,
				}),
			}),

			Separator = Roact.createElement(Separator, {
				LayoutOrder = FFlagUseLayoutIteratorGameSettingsPublishPlace and layoutOrder:getNextOrder() or 30,
			}),

			Icon = Roact.createElement(UploadableIconWidget, {
				Title = localization:getText("General", "TitleGameIcon"),
				LayoutOrder = FFlagUseLayoutIteratorGameSettingsPublishPlace and layoutOrder:getNextOrder() or 60,
				Enabled = props.GameIcon ~= nil,
				Icon = props.GameIcon,
				TutorialEnabled = true,
				AddIcon = self.addIcons,
				ErrorMessage = gameIconError,
			}),

			Separator3 = Roact.createElement(Separator, {
				LayoutOrder = FFlagUseLayoutIteratorGameSettingsPublishPlace and layoutOrder:getNextOrder() or 70,
			}),

			Thumbnails = Roact.createElement(ThumbnailController, {
				LayoutOrder = FFlagUseLayoutIteratorGameSettingsPublishPlace and layoutOrder:getNextOrder() or 80,
				Enabled = props.Thumbnails ~= nil,
				Thumbnails = props.Thumbnails,
				Order = props.ThumbnailOrder,
				AddThumbnail = self.addThumbnails,
				ErrorMessage = thumbnailError,
				ThumbnailsChanged = props.ThumbnailsChanged,
				ThumbnailOrderChanged = props.ThumbnailOrderChanged,
			}),

			Separator4 = Roact.createElement(Separator, {
				LayoutOrder = FFlagUseLayoutIteratorGameSettingsPublishPlace and layoutOrder:getNextOrder() or 90,
			}),

			Genre = Roact.createElement(TitledFrame, {
				Title = localization:getText("General", "TitleGenre"),
				MaxHeight = 38,
				LayoutOrder = FFlagUseLayoutIteratorGameSettingsPublishPlace and layoutOrder:getNextOrder() or 100,
				TextSize = DEPRECATED_Constants.TEXT_SIZE,
				ZIndex = 3,
			}, {
				Selector = Roact.createElement(Dropdown, {
					Entries = localizedGenreList,
					Enabled = props.Genre ~= nil,
					Current = props.Genre,
					CurrentChanged = props.GenreChanged,
				}),
			}),

			Separator5 = Roact.createElement(Separator, {
				LayoutOrder = FFlagUseLayoutIteratorGameSettingsPublishPlace and layoutOrder:getNextOrder() or 110,
			}),

			Devices = Roact.createElement(CheckBoxSet, {
				Title = localization:getText("General", "TitleDevices"),
				LayoutOrder = FFlagUseLayoutIteratorGameSettingsPublishPlace and layoutOrder:getNextOrder() or 120,
				Boxes = {{
						Id = "Computer",
						Title = localization:getText("General", "DeviceComputer"),
						Selected = devices and devices.Computer or false
					}, {
						Id = "Phone",
						Title = localization:getText("General", "DevicePhone"),
						Selected = devices and devices.Phone or false
					}, {
						Id = "Tablet",
						Title = localization:getText("General", "DeviceTablet"),
						Selected = devices and devices.Tablet or false
					}, {
						Id = "Console",
						Title = localization:getText("General", "DeviceConsole"),
						Selected = devices and devices.Console or false
					},
				},
				Enabled = devices ~= nil,
				ErrorMessage = devicesError,
				--Functionality
				EntryClicked = function(box)
					if box.Id == "Console" and not box.Selected then
						local dialogProps = {
							Size = Vector2.new(460, 308),
							Title = localization:getText("General", "ContentDialogHeader"),
							Header = localization:getText("General", "ContentDialogBody"),
							Entries = {
								localization:getText("General", "ContentDialogItem1"),
								localization:getText("General", "ContentDialogItem2"),
								localization:getText("General", "ContentDialogItem3"),
								localization:getText("General", "ContentDialogItem4"),
								localization:getText("General", "ContentDialogItem5"),
							},
							Buttons = {
								localization:getText("General", "ReplyDisagree"),
								localization:getText("General", "ReplyAgree")
							},
						}
						if not dialog.showDialog(ListDialog, dialogProps):await() then
							return
						end
					end

					local newDevices = Cryo.Dictionary.join(devices, {
						[box.Id] = (box.Selected) and Cryo.None or not box.Selected,
					})
					props.DevicesChanged(newDevices)
				end,
			}),

			Separator6 = not FFlagLuobuDevPublishLuaTempOptIn and FFlagLuobuDevPublishLua and shouldShowDevPublishLocations() and Roact.createElement(Separator, {
				LayoutOrder = FFlagUseLayoutIteratorGameSettingsPublishPlace and layoutOrder:getNextOrder() or 130,
			}) or nil,

			OptInLocations = not FFlagLuobuDevPublishLuaTempOptIn and FFlagLuobuDevPublishLua and shouldShowDevPublishLocations() and Roact.createElement(CheckBoxSet, {
				Title = localization:getText("General", "TitleOptInLocations"),
				LayoutOrder = FFlagUseLayoutIteratorGameSettingsPublishPlace and layoutOrder:getNextOrder() or 140,
				Boxes = self:createOptInLocationBoxes(layoutOrder),
				Enabled = optInLocations ~= nil,
				--Functionality
				EntryClicked = function(box)
					local dialogProps = {
						Size = Vector2.new(theme.dialog.size.width, theme.dialog.size.height),
						Title = "",
						Header = localization:getText("General", "TermsDialogHeader"),
						Buttons = {
							localization:getText("General", "ReplyOK"),
						},
						Body = Roact.createElement(TextWithInlineLink, {
							OnLinkClicked = function()
								local url = getPlayerAppDownloadLink(chinaKey)
								GuiService:OpenBrowserWindow(url)
							end,
							Text = localization:getText("General", "TermsDialogBody"),
							LinkText = localization:getText("General", "TermsDialogBodyLink"),
							LinkPlaceholder = "[link]",
							MaxWidth = theme.textWithInlineLink.maxWidth,
							TextProps = Cryo.Dictionary.join(theme.fontStyle.Normal, {
								BackgroundTransparency = 1,
							}),
						})
					}
					if not playerAcceptance then
						dialog.showDialog(SimpleDialog, dialogProps):await()
					else
						local newOptInLocations = deepJoin(optInLocations, {
							[box.Id] = {
								selected = not box.Selected,
							}
						})
						props.OptInLocationsChanged(newOptInLocations)
					end
				end,
				Tooltip = Roact.createElement(Image, {
					Size = UDim2.fromOffset(theme.tooltipIcon.size, theme.tooltipIcon.size),
					Position = UDim2.new(0, theme.tooltipIcon.paddingX, 0, theme.tooltipIcon.paddingY),
					Style = "TooltipStyle",
					StyleModifier = self.state.StyleModifier,
				}, {
					Roact.createElement(Tooltip, {
						Text = localization:getText(optInLocationsKey, "Tooltip"),
					}),
					Roact.createElement(HoverArea, {
						Cursor = "PointingHand",
						MouseEnter = self.onMouseEnter,
						MouseLeave = self.onMouseLeave,
					}),
				}),
			}) or nil,

			Separator7 = FFlagLuobuDevPublishLuaTempOptIn and shouldShowDevPublishLocations() and Roact.createElement(Separator, {
				LayoutOrder = FFlagUseLayoutIteratorGameSettingsPublishPlace and layoutOrder:getNextOrder() or 130,
			}) or nil,

			TempOptInLocations = FFlagLuobuDevPublishLuaTempOptIn and shouldShowDevPublishLocations() and Roact.createElement(TitledFrame, {
				Title = localization:getText("General", "TitleOptInLocations"),
				MaxHeight = 60,
				LayoutOrder = FFlagUseLayoutIteratorGameSettingsPublishPlace and layoutOrder:getNextOrder() or 140,
				TextSize = theme.fontStyle.Header.TextSize,
			}, {
				UILayout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),
				Text = Roact.createElement("TextLabel", {
					Size = UDim2.new(0, calculateTextSize(localization:getText(optInLocationsKey, "TempLinkDescription"), theme.fontStyle.Smaller.TextSize, theme.fontStyle.Smaller.Font).X, 0, theme.fontStyle.Smaller.TextSize),
					BackgroundTransparency = 1,
					TextColor3 = theme.fontStyle.Smaller.TextColor3,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = theme.fontStyle.Smaller.TextSize,
					Font = theme.fontStyle.Smaller.Font,
					Text = localization:getText(optInLocationsKey, "TempLinkDescription"),
					LayoutOrder = layoutOrder2 and layoutOrder2:getNextOrder() or 1,
				}),
				LinkText = Roact.createElement(LinkText, {
					Text = "roblox.cn",
					Style = "LinkTextStyle",
					OnClick = function()
						GuiService:OpenBrowserWindow("https://roblox.cn/")
					end,
					LayoutOrder = layoutOrder2 and layoutOrder2:getNextOrder() or 2,
				}),
			}) or nil,
		}
	end

	return Roact.createElement(SettingsPage, {
		SettingsLoadJobs = loadSettings,
		SettingsSaveJobs = saveSettings,
		Title = localization:getText("General", "Category"..LOCALIZATION_ID),
		PageId = LOCALIZATION_ID,
		CreateChildren = createChildren,
	})
end

ContextServices.mapToProps(BasicInfo, {
	Localization = ContextServices.Localization,
	Theme = ContextServices.Theme,
	Dialog = Dialog,
	Mouse = ContextServices.Mouse,
})

local settingFromState = require(Plugin.Src.Networking.settingFromState)
BasicInfo = RoactRodux.connect(
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
)(BasicInfo)

BasicInfo.LocalizationId = LOCALIZATION_ID

return BasicInfo
