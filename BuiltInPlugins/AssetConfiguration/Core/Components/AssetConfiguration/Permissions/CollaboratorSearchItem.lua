local Plugin = script.Parent.Parent.Parent.Parent.Parent
local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Util = Plugin.Core.Util
local Constants = require(Util.Constants)
local Framework = require(Libs.Framework)
local ContextServices = Framework.ContextServices

local Button = Framework.UI.Button

local THUMBNAIL_SIZE = 32
local COLLABORATOR_SEARCH_ITEM_HEIGHT = 50

local CollaboratorSearchItem = Roact.PureComponent:extend("CollaboratorSearchItem")

function CollaboratorSearchItem:render()
	local props = self.props
	local isHovered = props.IsHovered
	local icon = props.Icon
	local name = props.Name
	local layoutOrder = props.LayoutOrder
	local onActivated = props.OnActivated
	local size = props.Size
	local textPadding = props.TextPadding

	local itemHeight = COLLABORATOR_SEARCH_ITEM_HEIGHT

	local theme = self.props.Stylizer
	local searchBarTheme = theme.assetConfig.packagePermissions.searchBar

	-- setting offset for textbox to be icon frame or icon frame and enter icon frame if hovered and if showRibbon is true
	local iconOffset = isHovered and itemHeight * 2 or itemHeight
	local textLabelOffset = -iconOffset
	local backgroundColor = isHovered and searchBarTheme.dropDown.hovered.backgroundColor or searchBarTheme.dropDown.backgroundColor

	return Roact.createElement(Button, {
		Size = size,
		LayoutOrder = layoutOrder,
		OnClick = onActivated,
	}, {
		Container = Roact.createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = 0,
			BackgroundTransparency = 1,
		} , {
			UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
			}),

			IconFrame = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Size = UDim2.new(0, itemHeight, 0, itemHeight),
			}, {
				SmallIcon = Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = backgroundColor,
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, THUMBNAIL_SIZE, 0, THUMBNAIL_SIZE),
				}, {
					Icon = icon,
				}),
			}),

			TextLabel = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				Font = Constants.FONT,
				LayoutOrder = 2,
				Size = UDim2.new(1, textLabelOffset, 0, itemHeight),
				Text = name,
				TextColor3 = theme.assetConfig.textColor,
				TextSize = Constants.FONT_SIZE_TITLE,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, textPadding),
				}),
			}),
		})
	})
end

ContextServices.mapToProps(CollaboratorSearchItem, {
	Stylizer = ContextServices.Stylizer,
})

return CollaboratorSearchItem