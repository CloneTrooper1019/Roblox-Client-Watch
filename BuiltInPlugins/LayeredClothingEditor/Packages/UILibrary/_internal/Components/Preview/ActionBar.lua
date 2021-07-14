--[[
	This component is responsible for managing action bar, which provides two components.
	Insert button and open more button.

	Necessary properties:
	Position = UDim2
	Size = UDim2
	TryInsert = call back
	Text = button text
	Color = button color

	Optionlal properties:
	LayoutOrder = num
	AssetId = id, for analytics
	InstallDisabled = true if we're a plugin and we are loading, disables install attempts while loading
	DisplayResultOfInsertAttempt = if true, overwrites button color/text once you click it based on result of insert
	ShowRobuxIcon = Whether to show a robux icon next to the text.
]]

local Library = script.Parent.Parent.Parent

local Roact = require(Library.Parent.Parent.Roact)

local GetTextSize = require(Library.Utils.GetTextSize)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local RoundFrame = require(Library.Components.RoundFrame)

local ActionBar = Roact.PureComponent:extend("ActionBar")

local BUTTON_STATUS = {
	default = 0,
	hovered = 1,
}


function ActionBar:init(props)
	self.state = {
		insertButtonStatus = BUTTON_STATUS.default
	}

	self.onInsertButtonEnter = function()
		self:setState({
			insertButtonStatus = BUTTON_STATUS.hovered
		})
	end

	self.onInsertButtonLeave = function()
		self:setState({
			insertButtonStatus = BUTTON_STATUS.default
		})
	end

	self.onShowMoreActiveted = function()
		self.props.TryCreateContextMenu()
	end

	self.onInsertActivated = function()
		-- If we're working with a plugin, it might still be loading/already clicked and completed
		-- In these cases, we do not want to allow an insert attempt
		if self.props.InstallDisabled then
			return
		end

		self.props.TryInsert()
	end
end

function ActionBar:render()
	return withTheme(function(theme)
		local props = self.props
		local size = props.Size
		local position = props.Position
		local anchorPoint = props.AnchorPoint
		local showRobuxIcon = props.ShowRobuxIcon
		local isDisabled = props.InstallDisabled
		local layoutOrder = props.LayoutOrder

		local text = props.Text

		local actionBarTheme = theme.assetPreview.actionBar

		local color = actionBarTheme.button.backgroundColor
		if isDisabled then
			color = actionBarTheme.button.backgroundDisabledColor
		elseif self.state.insertButtonStatus == BUTTON_STATUS.hovered then
			color = actionBarTheme.button.backgroundHoveredColor
		end

		local textColor = isDisabled and actionBarTheme.text.colorDisabled or actionBarTheme.text.color
		local textWidth = GetTextSize(text, theme.assetPreview.textSizeLarge, theme.assetPreview.fontBold).X

		local padding = -(actionBarTheme.padding * 2 + actionBarTheme.centerPadding)

		return Roact.createElement("Frame", {
			Size = size,
			Position = position,
			AnchorPoint = anchorPoint,

			BackgroundTransparency = 0,
			BackgroundColor3 = actionBarTheme.background,
			BorderSizePixel = 0,

			LayoutOrder = layoutOrder,
		},{
			UIPadding = Roact.createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 12),
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12),
				PaddingTop = UDim.new(0, 12),
			}),

			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10),
			}),

			ShowMoreButton = Roact.createElement(RoundFrame, {
				Size = UDim2.new(0, 28, 0, 28),

				BackgroundColor3 = actionBarTheme.showMore.backgroundColor,
				BackgroundTransparency = 0,
				BorderSizePixel = 1,
				BorderColor3 = actionBarTheme.showMore.borderColor,

				OnActivated = self.onShowMoreActiveted,

				LayoutOrder = 1,
			}, {
				ShowMoreImageLabel = Roact.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, 16, 0, 16),

					Image = actionBarTheme.images.showMore,
					BackgroundTransparency = 1,
				})
			}),

			InsertButton = Roact.createElement(RoundFrame, {
				Size = UDim2.new(1, padding, 1, 0),
				BackgroundColor3 = color,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,

				OnActivated = self.onInsertActivated,
				OnMouseEnter = self.onInsertButtonEnter,
				OnMouseLeave = self.onInsertButtonLeave,

				LayoutOrder = 2,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0, 2)
				}),

				Icon = showRobuxIcon and Roact.createElement("ImageLabel", {
					LayoutOrder = 1,
					Size = actionBarTheme.robuxSize,
					BackgroundTransparency = 1,
					Image = actionBarTheme.images.robuxSmall,
					ImageColor3 = actionBarTheme.images.colorWhite,
				}),

				InsertTextLabel = Roact.createElement("TextLabel", {
					LayoutOrder = 2,
					Size = UDim2.new(0, textWidth, 1, 0),

					Text = text,
					Font = theme.assetPreview.fontBold,
					TextSize = theme.assetPreview.textSizeMedium,
					TextColor3 = textColor,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,

					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}),
			}),
		})
	end)
end

return ActionBar