--[[
	A dialog to display that a purchase has succeeded.

	Props:
		string Name = The name of the product to purchase.
		int Balance = The current user's Robux balance.
		bool IsFree = Whether the plugin is a free plugin.

		function OnClose = A callback for when the dialog is closed.
]]
local FFlagToolboxUseDevFrameworkDialogs = game:GetFastFlag("ToolboxUseDevFrameworkDialogs")

local Plugin = script.Parent.Parent.Parent.Parent
local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextServices = require(Libs.Framework).ContextServices

local StyledDialog
if FFlagToolboxUseDevFrameworkDialogs then
	local StudioUI = require(Libs.Framework).StudioUI
	StyledDialog = StudioUI.StyledDialog
else
	local UILibrary = require(Libs.UILibrary)
	StyledDialog = UILibrary.Component.StyledDialog
end

local ContextHelper = require(Plugin.Core.Util.ContextHelper)
local Images = require(Plugin.Core.Util.Images)
local Constants = require(Plugin.Core.Util.Constants)
local Dialog = Constants.Dialog

local withTheme = ContextHelper.withTheme
local withLocalization = ContextHelper.withLocalization

local PurchaseDialog = Roact.PureComponent:extend("PurchaseDialog")

function PurchaseDialog:render()
	return withLocalization(function(localization, localizedContent)
		if FFlagToolboxUseDevFrameworkDialogs then
			return self:renderContent(nil, localization, localizedContent)
		else
			return withTheme(function(theme)
				return self:renderContent(theme, localization, localizedContent)
			end)
		end
	end)
end

function PurchaseDialog:renderContent(theme, localization, localizedContent)
		local props = self.props
		local onClose = props.OnClose
		local name = props.Name
		local balance = props.Balance or "---"
		local isFree = props.IsFree

		if FFlagToolboxUseDevFrameworkDialogs then
			theme = self.props.Stylizer
		end

		local textWidth = Constants.getTextSize(localizedContent.PurchaseFlow.CurrentBalance,
			Constants.FONT_SIZE_MEDIUM).X

		local title = isFree and localizedContent.PurchaseFlow.FreeTitle
			or localizedContent.PurchaseFlow.BuyTitle
		local header = isFree and localizedContent.PurchaseFlow.FreeSuccessHeader
			or localizedContent.PurchaseFlow.SuccessHeader

		local primaryString = FFlagToolboxUseDevFrameworkDialogs and "RoundPrimary" or "Primary"

		local styledDialogProps
		if FFlagToolboxUseDevFrameworkDialogs then
			styledDialogProps = {
				AutomaticSize = Enum.AutomaticSize.Y,
				Title = title,
				MinContentSize = Vector2.new(Dialog.PROMPT_SIZE.X.Offset, Dialog.DETAILS_SIZE.Y.Offset + Dialog.BALANCE_SIZE.Y.Offset),
				Buttons = {
					{Key = true, Text = localizedContent.PurchaseFlow.OK, Style = primaryString},
				},
				OnButtonPressed = onClose,
				OnClose = onClose,
			}
		else
			styledDialogProps = {
				Buttons = {
					{Key = true, Text = localizedContent.PurchaseFlow.OK, Style = primaryString},
				},
				OnButtonClicked = onClose,
				OnClose = onClose,
				Size = Dialog.SIZE,
				Resizable = false,
				BorderPadding = Dialog.BORDER_PADDING,
				ButtonHeight = Dialog.BUTTON_SIZE.Y,
				ButtonWidth = Dialog.BUTTON_SIZE.X,
				ButtonPadding = Dialog.BUTTON_PADDING,
				TextSize = Constants.FONT_SIZE_LARGE,
				Title = title,
				Modal = true,
			}
		end

		return Roact.createElement(StyledDialog, styledDialogProps, {
			UIListLayout = FFlagToolboxUseDevFrameworkDialogs and Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),

			Header = Roact.createElement("TextLabel", {
				AutomaticSize = FFlagToolboxUseDevFrameworkDialogs and Enum.AutomaticSize.Y or nil,
				Size = Dialog.HEADER_SIZE,
				BackgroundTransparency = 1,
				LayoutOrder = FFlagToolboxUseDevFrameworkDialogs and 1 or nil,

				Text = header,
				TextSize = Constants.FONT_SIZE_TITLE,
				Font = Constants.FONT_BOLD,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = theme.purchaseDialog.promptText,
			}),

			Details = Roact.createElement("TextLabel", {
				AutomaticSize = FFlagToolboxUseDevFrameworkDialogs and Enum.AutomaticSize.Y or nil,
				Size = Dialog.DETAILS_SIZE,
				Position = Dialog.DETAILS_POSITION,
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				LayoutOrder = FFlagToolboxUseDevFrameworkDialogs and 2 or nil,

				Text = localization:getPurchaseSuccessDetails(name),
				TextSize = Constants.FONT_SIZE_LARGE,
				Font = Constants.FONT,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextColor3 = theme.purchaseDialog.promptText,
				TextWrapped = true,
			}),

			Balance = Roact.createElement("Frame", {
				Size = Dialog.BALANCE_SIZE,
				Position = UDim2.new(0, 0, 1, 10),
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
				LayoutOrder = FFlagToolboxUseDevFrameworkDialogs and 3 or nil,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = Dialog.BALANCE_PADDING,
				}),

				Text = Roact.createElement("TextLabel", {
					LayoutOrder = 1,
					Size = UDim2.new(0, textWidth, 1, 0),
					BackgroundTransparency = 1,

					Text = localizedContent.PurchaseFlow.CurrentBalance,
					TextSize = Constants.FONT_SIZE_MEDIUM,
					Font = Constants.FONT,
					TextColor3 = theme.purchaseDialog.balanceText,
				}),

				Icon = Roact.createElement("ImageLabel", {
					LayoutOrder = 2,
					Size = Dialog.ROBUX_SIZE,
					BackgroundTransparency = 1,
					Image = Images.ROBUX_SMALL,
					ImageColor3 = theme.purchaseDialog.balanceText,
				}),

				Robux = Roact.createElement("TextLabel", {
					LayoutOrder = 3,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,

					Text = balance,
					TextSize = Constants.FONT_SIZE_MEDIUM,
					Font = Constants.FONT,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = theme.purchaseDialog.balanceText,
				}),
			}),
		})
end

if FFlagToolboxUseDevFrameworkDialogs then
	ContextServices.mapToProps(PurchaseDialog, {
		Stylizer = ContextServices.Stylizer,
	})
end

return PurchaseDialog
