--[[
	A wrapped style dialog to show a dialog with confirm

	Required Props:
		string Text: text message in dialog
		callback OnClose: function to call when click confirm button
		table Localization: A Localization ContextItem, which is provided via mapToProps.

	Optional Props:
		string ConfirmText: if exist, confirm text will be replaced by it
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		string Title: title for dialog, using layered clothing editor is undefined
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local ConfirmDialog = Roact.PureComponent:extend("ConfirmDialog")

local StudioUI = Framework.StudioUI
local StyledDialog = StudioUI.StyledDialog

local Util = Framework.Util
local Typecheck = Util.Typecheck
Typecheck.wrap(ConfirmDialog, script)

local MessageBoxConfirm = "Confirm"

function ConfirmDialog:render()
	local props = self.props
	local localization = props.Localization
	local title = props.Title or localization:getText("Dialog","DefaultTitle")
	local theme = props.Stylizer
	local onClose = props.OnClose
	local confirmText = props.ConfirmText or props.Localization:getText("Dialog","Confirm")
	return Roact.createElement(StyledDialog, {
		Title = title,
		OnClose = onClose,
		OnButtonPressed = onClose,
		Buttons = {
				{ Text = confirmText, Key = MessageBoxConfirm, Style = "Round"},
			},
		MinContentSize = theme.PopupMessageSize,
		Modal = true,
	},{
		Message = Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			Text = props.Text,
			TextColor3 = theme.TextColor,
			BackgroundTransparency = 1.0,
			TextWrapped = true
		})
	})
end

ContextServices.mapToProps(ConfirmDialog,{
	Stylizer = ContextServices.Stylizer,
	Localization = ContextServices.Localization,
})

return ConfirmDialog
