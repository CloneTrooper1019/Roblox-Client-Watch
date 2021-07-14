--[[
	A wrapped style dialog to show a dialog with confirm and cancel

	Required Props:
		string Text: text message in dialog
		callback OnConfirm: function to call when click confirm button
		callback OnClose: function to call when close dialog or click cancel button
		table Localization: A Localization ContextItem, which is provided via mapToProps.
	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		string Title: title for dialog, using layered clothing editor is undefined
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local StudioUI = Framework.StudioUI
local StyledDialog = StudioUI.StyledDialog

local ConfirmCancelDialog = Roact.PureComponent:extend("ConfirmCancelDialog")

local Util = Framework.Util
local Typecheck = Util.Typecheck
Typecheck.wrap(ConfirmCancelDialog, script)

local MessageBoxConfirm = "Confirm"
local MessageBoxCancel = "Cancel"

function ConfirmCancelDialog:init()
	local props = self.props
	self.onMessageBoxButtonClicked = function(key)
		props.OnClose()
		if key == MessageBoxConfirm then
			props.OnConfirm()
		end
	end
end

function ConfirmCancelDialog:render()
	local props = self.props
	local localization = props.Localization
	local title = props.Title or localization:getText("Dialog","DefaultTitle")
	local theme = props.Stylizer
	local onClose = props.OnClose
	return Roact.createElement(StyledDialog, {
        Title = title,
        OnClose = onClose,
        OnButtonPressed = self.onMessageBoxButtonClicked,
        Buttons = {
                { Text = props.Localization:getText("Dialog","Confirm"), Key = MessageBoxConfirm, Style = "Round"},
				{ Text = props.Localization:getText("Dialog","Cancel"), Key = MessageBoxCancel, Style = "Round"},
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

ContextServices.mapToProps(ConfirmCancelDialog,{
	Stylizer = ContextServices.Stylizer,
	Localization = ContextServices.Localization,
})

return ConfirmCancelDialog
