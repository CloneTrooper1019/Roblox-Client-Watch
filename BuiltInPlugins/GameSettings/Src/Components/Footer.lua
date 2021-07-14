--[[
	Footer shown at the bottom of the Game Settings widget.
	Contains the Save and Cancel buttons.

	Props:
		bool SaveActive = Whether or not saving is currently allowed.
			This will enable the Save button if true.
]]
local FFlagLuobuDevPublishLua = game:GetFastFlag("LuobuDevPublishLua")
local FFlagTextInputDialogDevFramework = game:GetFastFlag("TextInputDialogDevFramework")
local FFlagGameSettingsUseKeyProvider = game:GetFastFlag("GameSettingsUseKeyProvider")

local FOOTER_GRADIENT_SIZE = 3
local FOOTER_GRADIENT_TRANSPARENCY = 0.9

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local Promise = require(Plugin.Promise)
local Framework = require(Plugin.Framework)

local ContextServices = require(Plugin.Framework.ContextServices)
local Dialog = require(Plugin.Src.ContextServices.Dialog)

local DEPRECATED_Constants = require(Plugin.Src.Util.DEPRECATED_Constants)
local isEmpty = require(Plugin.Src.Util.isEmpty)

local ButtonBar = require(Plugin.Src.Components.ButtonBar)

local ConfirmAndSaveChanges = require(Plugin.Src.Thunks.ConfirmAndSaveChanges)
local PostContactEmail = require(Plugin.Src.Thunks.PostContactEmail)
local CurrentStatus = require(Plugin.Src.Util.CurrentStatus)

local TextInputDialog = FFlagLuobuDevPublishLua and Framework.UI.TextInputDialog or nil
local shouldShowDevPublishLocations = require(Plugin.Src.Util.GameSettingsUtilities).shouldShowDevPublishLocations

local KeyProvider = FFlagGameSettingsUseKeyProvider and require(Plugin.Src.Util.KeyProvider) or nil
local GetOptInLocationsKeyName = FFlagGameSettingsUseKeyProvider and KeyProvider.getOptInLocationsKeyName or nil
local optInLocationsKey = FFlagLuobuDevPublishLua and GetOptInLocationsKeyName and GetOptInLocationsKeyName() or "OptInLocations"
local GetChinaKeyName = FFlagGameSettingsUseKeyProvider and KeyProvider.getChinaKeyName or nil
local chinaKey = FFlagLuobuDevPublishLua and GetChinaKeyName and GetChinaKeyName() or "China"
local GetSelectedKeyName = FFlagGameSettingsUseKeyProvider and KeyProvider.getSelectedKeyName or nil
local selectedKey = FFlagLuobuDevPublishLua and GetSelectedKeyName and GetSelectedKeyName() or "selected"

local Footer = Roact.PureComponent:extend("Footer")

function Footer:saveAllSettings(userPressedSave)
	local props = self.props
	local localization = props.Localization
	local dialog = props.Dialog

	local resolved = self.props.SaveAllSettings(userPressedSave, localization, dialog):await()
	if resolved then
		self.props.OnClose(userPressedSave)
	end
end

function Footer:init()
	self.shouldShowEmailDialog = FFlagLuobuDevPublishLua and function()
		local props = self.props
		-- 5/25/21 - CurrentOptInLocations and ChangedOptInLocations are only set in Luobu Studio
		local currentOptInLocations = props.CurrentOptInLocations
		local changedOptInLocations = props.ChangedOptInLocations

		--[[
			false - Option 1: current = {"China": {"selected": false, ... }}, changed = {"China": {"selected": false, ... }}
			true - Option 2: current = {"China": {"selected": false, ... }}, changed = {"China": {"selected": true, ... }}
			false - Option 3: current = {"China": {"selected": false, ... }}, changed = nil
			true - Option 4: current = {"China": {"selected": true, ... }}, changed = {"China": {"selected": true, ... }}
			false - Option 5: current = {"China": {"selected": true, ... }}, changed = {"China": {"selected": false, ... }}
			true - Option 6: current = {"China": {"selected": true, ... }}, changed = nil
		]]

		if currentOptInLocations[chinaKey][selectedKey] then
			if not changedOptInLocations then
				return true
			end
			return changedOptInLocations[chinaKey][selectedKey]
		elseif not currentOptInLocations[chinaKey][selectedKey] then
			if not changedOptInLocations then
				return false
			end
			return changedOptInLocations[chinaKey][selectedKey]
		end
		return false

	end or nil

	self.state = FFlagLuobuDevPublishLua and {
		showEmailDialog = false,
		userPressedSave = false,
		bottomText = "",
	} or nil
end

function Footer:render()
	local props = self.props
	local theme = props.Theme:get("Plugin")
	local localization = props.Localization

	local saveActive = props.SaveActive
	local cancelActive = props.CancelActive

	local postContactEmail = props.PostContactEmail

	return Roact.createElement("Frame", {
		BackgroundColor3 = theme.backgroundColor,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
	}, {
		Gradient = Roact.createElement("ImageLabel", {
			Size = UDim2.new(1, 0, 0, FOOTER_GRADIENT_SIZE),
			AnchorPoint = Vector2.new(0, 1),
			Image = DEPRECATED_Constants.GRADIENT_IMAGE,
			ImageRectSize = DEPRECATED_Constants.GRADIENT_RECT_SIZE,
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			ImageColor3 = theme.footer.gradient,
			ImageTransparency = FOOTER_GRADIENT_TRANSPARENCY,
			ZIndex = 1,
		}),

		SaveSettings = Roact.createElement(ButtonBar, {
			ZIndex = 2,
			Buttons = {
				{Name = localization:getText("General", "ButtonCancel"), Active = cancelActive, Value = false},
				{Name = localization:getText("General", "ButtonSave"), Default = true, Active = saveActive, Value = true},
			},
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			ButtonClicked = function(userPressedSave)
				-- Make changes here before save happens to show dialog
				if FFlagLuobuDevPublishLua and FFlagTextInputDialogDevFramework then
					if userPressedSave and shouldShowDevPublishLocations() and self.shouldShowEmailDialog() then
						self:setState({
							showEmailDialog = true,
							userPressedSave = userPressedSave,
						})
					else
						self:saveAllSettings(userPressedSave)
					end
				else
					self:saveAllSettings(userPressedSave)
				end
			end,
		}, {
			EmailDialog = FFlagLuobuDevPublishLua and FFlagTextInputDialogDevFramework and Roact.createElement(TextInputDialog,
			{
				Enabled = self.state.showEmailDialog,
				Size = Vector2.new(theme.emailDialog.Size.X, theme.emailDialog.Size.Y),
				Title = localization:getText(optInLocationsKey, "EmailDialogHeader"),
				Header = localization:getText(optInLocationsKey, "EmailDialogHeader"),
				Buttons = {
					{Key = "Submit", Text = localization:getText("General", "ButtonSubmit")},
					{Key = "Cancel", Text = localization:getText("General", "ButtonCancel")},
				},
				Body = localization:getText(optInLocationsKey, "EmailDialogBody"),
				Description = localization:getText(optInLocationsKey, "EmailDialogDescription"),
				TextInput = {
					{PlaceholderText = localization:getText(optInLocationsKey, "EmailAddress"),},
					{PlaceholderText = localization:getText(optInLocationsKey, "ConfirmEmailAddress"), BottomText = self.state.bottomText,},
				},
				OnClose = function()
					self:setState({
						showEmailDialog = false,
						userPressedSave = false,
						bottomText = "",
					})
				end,
				OnButtonPressed = function(buttonKey, email1, email2)
					local submitButtonPressed = buttonKey == "Submit"
					if submitButtonPressed then
						if email1 == email2 then
							local responseCode = postContactEmail(email1)
							if not responseCode then
								self:saveAllSettings(self.state.userPressedSave)
								self:setState({
									showEmailDialog = false,
									userPressedSave = false,
									bottomText = "",
								})
							else
								local message = localization:getText(optInLocationsKey, "EmailSubmitFailure") .. responseCode
								warn(message)
							end
						else
							self:setState({
								bottomText = localization:getText(optInLocationsKey, "ErrorEmailNotEqual")
							})
						end
					else
						self:setState({
							showEmailDialog = false,
							userPressedSave = false,
							bottomText = "",
						})
					end
				end,
			}) or nil
		}),
	})
end

ContextServices.mapToProps(Footer,{
	Theme = ContextServices.Theme,
	Localization = ContextServices.Localization,
	Dialog = Dialog,
})

Footer = RoactRodux.connect(
	function(state, props)
		if not state then return end
		return {
			SaveActive = not isEmpty(state.Settings.Changed)
				and state.Status == CurrentStatus.Open
				and isEmpty(state.Settings.Errors),
			CancelActive = state.Status == CurrentStatus.Open,
			CurrentOptInLocations = FFlagLuobuDevPublishLua and state.Settings.Current[optInLocationsKey] or nil,
			ChangedOptInLocations = FFlagLuobuDevPublishLua and state.Settings.Changed[optInLocationsKey] or nil,
		}
	end,
	function(dispatch)
		return {
			SaveAllSettings = function(userPressedSave, ...)
				if userPressedSave then
					return dispatch(ConfirmAndSaveChanges(...))
				else
					return Promise.resolve()
				end
			end,

			PostContactEmail = function(contactEmail)
				return dispatch(PostContactEmail(contactEmail))
			end,
		}
	end
)(Footer)

return Footer
