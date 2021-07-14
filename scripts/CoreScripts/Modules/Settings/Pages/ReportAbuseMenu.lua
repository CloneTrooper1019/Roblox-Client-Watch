--[[
		Filename: ReportAbuseMenu.lua
		Written by: jeditkacheff
		Version 1.0
		Description: Takes care of the report abuse page in Settings Menu
--]]

local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local GuiService = game:GetService("GuiService")
local PlayersService = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local AnalyticsService = game:GetService("RbxAnalyticsService")

local utility = require(RobloxGui.Modules.Settings.Utility)
local RobloxTranslator = require(RobloxGui.Modules.RobloxTranslator)

local FFlagFixUsernamesAutoLocalizeIssue = require(RobloxGui.Modules.Flags.FFlagFixUsernamesAutoLocalizeIssue)

local ABUSE_TYPES_PLAYER = {
	"Swearing",
	"Inappropriate Username",
	"Bullying",
	"Scamming",
	"Dating",
	"Cheating/Exploiting",
	"Personal Question",
	"Offsite Links",
}

local ABUSE_TYPES_GAME = {
	"Inappropriate Content"
}

local DEFAULT_ABUSE_DESC_TEXT = "   Short Description (Optional)"
if utility:IsSmallTouchScreen() then
	DEFAULT_ABUSE_DESC_TEXT = "   (Optional)"
end

pcall(function()
	if utility:IsSmallTouchScreen() then
		DEFAULT_ABUSE_DESC_TEXT = RobloxTranslator:FormatByKey("KEY_DESCRIPTION_OPTIONAL")
	else
		DEFAULT_ABUSE_DESC_TEXT = RobloxTranslator:FormatByKey("KEY_DESCRIPTION_SHORT_DECRIPTION_OPTIONAL")
	end
end)

local PageInstance = nil

local success, result = pcall(function() return settings():GetFFlag('UseNotificationsLocalization') end)
local FFlagUseNotificationsLocalization = success and result

local FFlagCollectAnalyticsForSystemMenu = settings():GetFFlag("CollectAnalyticsForSystemMenu")

local Constants
if FFlagCollectAnalyticsForSystemMenu then
  Constants = require(RobloxGui.Modules:WaitForChild("InGameMenu"):WaitForChild("Resources"):WaitForChild("Constants"))
end

local MIN_GAME_REPORT_TEXT_LENGTH = 5

----------- CLASS DECLARATION --------------
local function Initialize()
	local settingsPageFactory = require(RobloxGui.Modules.Settings.SettingsPageFactory)
	local this = settingsPageFactory:CreateNewPage()

	local playerNames = {}
	local nameToRbxPlayer = {}
	local nextPlayerToReport = nil

	function this:GetPlayerNameText(player)
		return player.DisplayName .. " [@" .. player.Name .. "]"
	end

	function this:GetPlayerFromIndex(index)
		local playerName = playerNames[index]
		if playerName then
			return nameToRbxPlayer[playerName]
		end

		return nil
	end

	function this:SetNextPlayerToReport(player)
		nextPlayerToReport = player
	end

	function this:UpdatePlayerDropDown()
		playerNames = {}
	    nameToRbxPlayer = {}

		local players = PlayersService:GetPlayers()
		local index = 1
		for i = 1, #players do
			local player = players[i]
			if player ~= PlayersService.LocalPlayer and player.UserId > 0 then
				local nameText = this:GetPlayerNameText(player)
				playerNames[index] = nameText
				nameToRbxPlayer[nameText] = player
				index = index + 1
			end
		end

		table.sort(playerNames, function(a, b)
			return a:lower() < b:lower()
		end)

        this.WhichPlayerMode:UpdateDropDownList(playerNames)

        --Reset GameOrPlayerMode to Game if no other players
        if index == 1 then
			this.GameOrPlayerMode:SetSelectionIndex(1)
		end

		this.GameOrPlayerMode:SetInteractable(index > 1)

		if this.GameOrPlayerMode.CurrentIndex == 1 then
			this.WhichPlayerMode:SetInteractable(false)
			this.TypeOfAbuseMode:UpdateDropDownList(ABUSE_TYPES_GAME)
			this.TypeOfAbuseMode:SetInteractable(#ABUSE_TYPES_GAME > 1)
		else
			this.WhichPlayerLabel.ZIndex = 2
			this.WhichPlayerMode:SetInteractable(index > 1)
			this.TypeOfAbuseMode:UpdateDropDownList(ABUSE_TYPES_PLAYER)
			this.TypeOfAbuseMode:SetInteractable(#ABUSE_TYPES_PLAYER > 1)
		end

		if nextPlayerToReport then
			local playerNameText = this:GetPlayerNameText(nextPlayerToReport)
			local playerSelected = this.WhichPlayerMode:SetSelectionByValue(playerNameText)
			nextPlayerToReport = nil

			if this.GameOrPlayerMode.CurrentIndex == 2 then
				if playerSelected then --if the reported player is still in game
					--Auto select type of abuse when report a player
					GuiService.SelectedCoreObject = this.TypeOfAbuseMode.DropDownFrame
				else
					GuiService.SelectedCoreObject = this.WhichPlayerMode.DropDownFrame
				end
			end
		end
	end

	------ TAB CUSTOMIZATION -------
	this.TabHeader.Name = "ReportAbuseTab"
	this.TabHeader.Icon.Image = "rbxasset://textures/ui/Settings/MenuBarIcons/ReportAbuseTab.png"
	if FFlagUseNotificationsLocalization then
		this.TabHeader.Title.Text = "Report"
	else
		this.TabHeader.Icon.Title.Text = "Report"
	end

	------ PAGE CUSTOMIZATION -------
	this.Page.Name = "ReportAbusePage"

	-- need to override this function from SettingsPageFactory
	-- DropDown menus require hub to to be set when they are initialized
	function this:SetHub(newHubRef)
		this.HubRef = newHubRef

		if utility:IsSmallTouchScreen() then
			this.GameOrPlayerFrame,
			this.GameOrPlayerLabel,
			this.GameOrPlayerMode = utility:AddNewRow(this, "Experience or Person?", "Selector", {"Experience", "Person"}, 2)
		else
			this.GameOrPlayerFrame,
			this.GameOrPlayerLabel,
			this.GameOrPlayerMode = utility:AddNewRow(this, "Experience or Person?", "Selector", {"Experience", "Person"}, 2, 3)
		end
		this.GameOrPlayerMode.Selection.LayoutOrder = 1

		local whichPlayerText = "Which Person?"
		if FFlagFixUsernamesAutoLocalizeIssue then
			whichPlayerText = RobloxTranslator:FormatByKey("Feature.SettingsHub.Label.WhichPlayer")
		end
		this.WhichPlayerFrame, this.WhichPlayerLabel, this.WhichPlayerMode =
			utility:AddNewRow(this, whichPlayerText, "DropDown", {"update me"})
		this.WhichPlayerMode:SetInteractable(false)
		if FFlagFixUsernamesAutoLocalizeIssue then
			this.WhichPlayerMode:SetAutoLocalize(false)
		end
		this.WhichPlayerLabel.ZIndex = 1
		this.WhichPlayerFrame.LayoutOrder = 2

		this.TypeOfAbuseFrame,
		this.TypeOfAbuseLabel,
		this.TypeOfAbuseMode = utility:AddNewRow(this, "Type Of Abuse", "DropDown", ABUSE_TYPES_GAME, 1)
		this.TypeOfAbuseFrame.LayoutOrder = 3

		if utility:IsSmallTouchScreen() then
			this.AbuseDescriptionFrame,
			this.AbuseDescriptionLabel,
			this.AbuseDescription = utility:AddNewRow(this, DEFAULT_ABUSE_DESC_TEXT, "TextBox", nil, nil, 5)

			this.AbuseDescriptionLabel.Text = "Abuse Description"
		else
			this.AbuseDescriptionFrame,
			this.AbuseDescriptionLabel,
			this.AbuseDescription = utility:AddNewRow(this, DEFAULT_ABUSE_DESC_TEXT, "TextBox", nil, nil, 5)

			this.AbuseDescriptionFrame.Size = UDim2.new(1, -10, 0, 100)
			this.AbuseDescription.Selection.Size = UDim2.new(1, 0, 1, 0)
		end

		this.AbuseDescriptionFrame.LayoutOrder = 4

		this.AbuseDescription.Selection.FocusLost:connect(function()
			if this.AbuseDescription.Selection.Text == "" then
				this.AbuseDescription.Selection.Text = DEFAULT_ABUSE_DESC_TEXT
			end
		end)

		local _SelectionOverrideObject = utility:Create'ImageLabel'
		{
			Image = "",
			BackgroundTransparency = 1
		};

		local submitButton, submitText = nil, nil

		local function makeSubmitButtonActive()
			submitButton.ZIndex = 2
			submitButton.Selectable = true
			submitText.ZIndex = 2
		end

		local function makeSubmitButtonInactive()
			submitButton.ZIndex = 1
			submitButton.Selectable = false
			submitText.ZIndex = 1
		end

		local function updateSubmitButton()
			if this.GameOrPlayerMode.CurrentIndex == 1 then -- 1 is Report Game
				if this.AbuseDescription.Selection.Text ~= DEFAULT_ABUSE_DESC_TEXT then
					if utf8.len(utf8.nfcnormalize(this.AbuseDescription.Selection.Text)) > MIN_GAME_REPORT_TEXT_LENGTH then
						makeSubmitButtonActive()
						return
					end
				end
			else
				if this.WhichPlayerMode:GetSelectedIndex() then
					if this.TypeOfAbuseMode:GetSelectedIndex() then
						makeSubmitButtonActive()
						return
					end
				end
			end
			makeSubmitButtonInactive()
		end

		local function updateAbuseDropDown()
			this.WhichPlayerMode:ResetSelectionIndex()
			this.TypeOfAbuseMode:ResetSelectionIndex()

			if this.GameOrPlayerMode.CurrentIndex == 1 then
				this.TypeOfAbuseMode:UpdateDropDownList(ABUSE_TYPES_GAME)

				this.TypeOfAbuseMode:SetInteractable(#ABUSE_TYPES_GAME > 1)
				this.TypeOfAbuseLabel.ZIndex = (#ABUSE_TYPES_GAME > 1 and 2 or 1)

				this.WhichPlayerMode:SetInteractable(false)
				this.WhichPlayerLabel.ZIndex = 1

				updateSubmitButton()
			else
				this.TypeOfAbuseMode:UpdateDropDownList(ABUSE_TYPES_PLAYER)
				this.TypeOfAbuseMode:SetInteractable(#ABUSE_TYPES_PLAYER > 1)
				this.TypeOfAbuseLabel.ZIndex = (#ABUSE_TYPES_PLAYER > 1 and 2 or 1)

				if #playerNames > 0 then
					this.WhichPlayerMode:SetInteractable(true)
					this.WhichPlayerLabel.ZIndex = 2
				else
					this.WhichPlayerMode:SetInteractable(false)
					this.WhichPlayerLabel.ZIndex = 1
				end

				updateSubmitButton()
			end
		end

		local function cleanupReportAbuseMenu()
			updateAbuseDropDown()
			this.AbuseDescription.Selection.Text = DEFAULT_ABUSE_DESC_TEXT
			this.HubRef:SetVisibility(false, true)
		end

		local function reportAnalytics(reportType, id)
			if not FFlagCollectAnalyticsForSystemMenu then return end

			local stringTable = {}
			stringTable[#stringTable + 1] = "report_type=" .. tostring(reportType)
			stringTable[#stringTable + 1] = "report_source=ingame"
			stringTable[#stringTable + 1] = "reported_entity_id=" .. tostring(id)

			local infoString = table.concat(stringTable,"&")

			local eventTable = {}
			eventTable["universeid"] = tostring(game.GameId)

			AnalyticsService:SetRBXEventStream(Constants.AnalyticsTargetName, Constants.AnalyticsReportSubmittedName, infoString, eventTable)
		end

		local function onReportSubmitted()
			local abuseReason = nil
			local reportSucceeded = false
			if this.GameOrPlayerMode.CurrentIndex == 2 then
				abuseReason = ABUSE_TYPES_PLAYER[this.TypeOfAbuseMode.CurrentIndex]

				local currentAbusingPlayer = this:GetPlayerFromIndex(this.WhichPlayerMode.CurrentIndex)
				if currentAbusingPlayer and abuseReason then
					reportSucceeded = true
					spawn(function()
						PlayersService:ReportAbuse(currentAbusingPlayer, abuseReason, this.AbuseDescription.Selection.Text)
						reportAnalytics("user", currentAbusingPlayer.UserId)
					end)
				end
			else
				abuseReason = ABUSE_TYPES_GAME[this.TypeOfAbuseMode.CurrentIndex]
				if abuseReason then
					reportSucceeded = true
					spawn(function()
						local placeId,placeName,placeDescription = tostring(game.PlaceId), "N/A", "N/A"
						local abuseDescription = this.AbuseDescription.Selection.Text
						pcall(function()
							local productInfo = MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Asset)
							placeName = productInfo.Name
							placeDescription = productInfo.Description
						end)
						local formattedText = string.format("User Report: \n    %s \n".."Place Title: \n    %s \n".."PlaceId: \n    %s \n".."Place Description: \n    %s \n",abuseDescription, placeName, placeId, placeDescription)

						PlayersService:ReportAbuse(nil, abuseReason, formattedText)
						reportAnalytics("game", game.GameId)
					end)
				end
			end

			if reportSucceeded then
				local alertText = "Thanks for your report! Our moderators will review the chat logs and evaluate what happened."

				if abuseReason == 'Cheating/Exploiting' then
					alertText = "Thanks for your report! We've recorded your report for evaluation."
				elseif abuseReason == 'Inappropriate Username' then
					alertText = "Thanks for your report! Our moderators will evaluate the username."
				elseif abuseReason == "Bad Model or Script" or  abuseReason == "Inappropriate Content" or abuseReason == "Offsite Link" or abuseReason == "Offsite Links" then
					alertText = "Thanks for your report! Our moderators will review the place and make a determination."
				end

				utility:ShowAlert(alertText, "Ok", this.HubRef, cleanupReportAbuseMenu)

				this.LastSelectedObject = nil
			end
		end

		submitButton, submitText = utility:MakeStyledButton("SubmitButton", "Submit", UDim2.new(0,198,0,50), onReportSubmitted, this)

		submitButton.AnchorPoint = Vector2.new(0.5,0)
		submitButton.Position = UDim2.new(0.5,0,1,5)

		updateSubmitButton()
		submitButton.Parent = this.AbuseDescription.Selection

		local function playerSelectionChanged(newIndex)
			updateSubmitButton()
		end
		this.WhichPlayerMode.IndexChanged:connect(playerSelectionChanged)

		local function typeOfAbuseChanged(newIndex)
			updateSubmitButton()
		end
		this.TypeOfAbuseMode.IndexChanged:connect(typeOfAbuseChanged)

		this.GameOrPlayerMode.IndexChanged:connect(updateAbuseDropDown)

		local function abuseDescriptionChanged()
			updateSubmitButton()
		end
		this.AbuseDescription.Selection:GetPropertyChangedSignal("Text"):connect(abuseDescriptionChanged)

		this:AddRow(nil, nil, this.AbuseDescription)

		this.Page.Size = UDim2.new(1,0,0,submitButton.AbsolutePosition.Y + submitButton.AbsoluteSize.Y)
	end

	return this
end


----------- Public Facing API Additions --------------
do
	PageInstance = Initialize()

	PageInstance.Displayed.Event:connect(function()
		PageInstance:UpdatePlayerDropDown()
	end)

	function PageInstance:ReportPlayer(player)
		if player then
			local setReportPlayerConnection = nil
			PageInstance:SetNextPlayerToReport(player)
			setReportPlayerConnection = PageInstance.Displayed.Event:connect(function()
				PageInstance.GameOrPlayerMode:SetSelectionIndex(2)

				if setReportPlayerConnection then
					setReportPlayerConnection:disconnect()
					setReportPlayerConnection = nil
				end
			end)

			if not PageInstance.HubRef:GetVisibility() then
				PageInstance.HubRef:SetVisibility(true, false, PageInstance)
			else
				PageInstance.HubRef:SwitchToPage(PageInstance, false)
			end
		end
	end
end


return PageInstance
