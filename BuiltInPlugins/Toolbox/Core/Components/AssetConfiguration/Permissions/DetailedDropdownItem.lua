local Plugin = script.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local Framework = require(Libs.Framework)
local ContextServices = Framework.ContextServices

local Button = Framework.UI.Button

local Constants = require(Plugin.Core.Util.Constants)
local TEXT_PADDING = 10

local DetailedDropdownItem = Roact.PureComponent:extend("DetailedDropdownItem")

function DetailedDropdownItem:render()
	local props = self.props
	local layoutOrder = props.LayoutOrder
	local onActivated = props.OnActivated
	local titleText = props.Title
	local descriptionText = props.Description

	local theme = props.Stylizer
	local dropdownTheme = theme.detailedDropdown
	local textPadding = TEXT_PADDING

	local selected = props.Selected
	local isHovered = props.IsHovered
	local displayTextColor = isHovered and dropdownTheme.hovered.displayText or dropdownTheme.displayText

	return Roact.createElement(Button, {
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = layoutOrder,
		OnClick = onActivated,
		Size = UDim2.new(1, 0, 0, 0),
		Style = selected and "SelectedDetailedDropdownItem" or nil,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, textPadding),
			PaddingBottom = UDim.new(0, textPadding),
		}),

		MainTextLabel = Roact.createElement("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			Font = Constants.FONT,
			TextSize = 20,
			Text = titleText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = displayTextColor,
			BackgroundTransparency = 1,
			TextWrapped = true,
			LayoutOrder = 0,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, textPadding),
			}),
		}),

		DescriptionTextLabel = Roact.createElement("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			Font = Constants.FONT,
			TextSize = 18,
			Text = descriptionText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = dropdownTheme.descriptionText,
			BackgroundTransparency = 1,
			TextWrapped = true,
			LayoutOrder = 1,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingRight = UDim.new(0, textPadding),
				PaddingLeft = UDim.new(0, textPadding),
			}),
		}),
	})
end

ContextServices.mapToProps(DetailedDropdownItem, {
	Stylizer = ContextServices.Stylizer,
})

return DetailedDropdownItem