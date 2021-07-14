--[[
	A dropdown menu styled to match the Roblox Studio start page.
	Consists of a button used to open the dropdown as well as the menu itself.
	Note that the logic for opening and closing the menu is contained within this component,
	but the consumer is responsible for showing the current value in the button.

	Required Props:
		UDim2 Size = The size of the button that opens the dropdown.
		UDim2 Position = The position of the button that opens the dropdown.
		int TextSize = The size of the text in the dropdown and button.
		int ItemHeight = The height of each entry in the dropdown, in pixels.
		string ButtonText = The text to display in the button that opens the dropdown.
			Usually should be set to the currently selected dropdown entry.
		array Items = An ordered array of each item that should appear in the dropdown.
			The array is formatted like this:
			{
				{Key = "Item1", Text = "SomeLocalizedTextForItem1"},
				{Key = "Item2", Text = "SomeLocalizedTextForItem2"},
				{Key = "Item3", Text = "SomeLocalizedTextForItem3"},
			}
			Key is how the item will be referenced in code. Text is what will appear to the user.
		function OnItemClicked(item) = A callback when the user selects an item in the dropdown.
			Returns the item as it was defined in the Items array.

	Optional Props:
		int MaxItems = The maximum number of entries that can display at a time.
			If this is less than the number of entries in the dropdown, a scrollbar will appear.
		bool ShowRibbon = Whether to show a colored ribbon next to the currently
			hovered dropdown entry. Usually should be enabled for Light theme only.
		int TextPadding = The amount of padding, in pixels, around the text elements.
		int IconSize = The size of the arrow icon in the button.
		int IconPadding = The distance from the right side of the arrow icon to the button edge.
		int ScrollBarPadding = The padding which appears on either side of the scrollbar.
		int ScrollBarThickness = The horizontal width of the scrollbar.
]]

-- Defaults
local TEXT_PADDING = 8
local ICON_SIZE = 12
local ICON_PADDING = 4

local RIBBON_WIDTH = 5
local VERTICAL_OFFSET = 2

local TextService = game:GetService("TextService")

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local DropdownMenu = require(Library.Components.DropdownMenu)
local RoundFrame = require(Library.Components.RoundFrame)

local StyledDropdown = Roact.PureComponent:extend("StyledDropdown")

function StyledDropdown:init()
	self.state = {
		showDropdown = false,
		isButtonHovered = false,
		hoveredKey = nil,
	}
	self.buttonRef = Roact.createRef()

	self.onItemClicked = function(key)
		self.props.OnItemClicked(key)
		self.hideDropdown()
	end

	self.showDropdown = function()
		self:setState({
			showDropdown = true,
		})
	end

	self.hideDropdown = function()
		self:setState({
			showDropdown = false,
		})
	end

	self.onKeyMouseEnter = function(key)
		self:setState({
			hoveredKey = key,
		})
	end

	self.onKeyMouseLeave = function(key)
		if self.state.hoveredKey == key then
			self:setState({
				hoveredKey = Roact.None,
			})
		end
	end

	self.onMouseEnter = function()
		self:setState({
			isButtonHovered = true,
		})
	end

	self.onMouseLeave = function()
		self:setState({
			isButtonHovered = false,
		})
	end
end

function StyledDropdown:createLabel(key, displayText, textSize, textPadding, font, textColor)
	return Roact.createElement("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		Font = font,
		TextSize = textSize,
		Text = displayText,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = textColor,
		BackgroundTransparency = 1,

		[Roact.Event.MouseEnter] = function()
			self.onKeyMouseEnter(key)
		end,
		[Roact.Event.MouseLeave] = function()
			self.onKeyMouseLeave(key)
		end,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, textPadding),
		}),
	})
end

function StyledDropdown:render()
	return withTheme(function(theme)
		local props = self.props
		local state = self.state
		local dropdownTheme = theme.styledDropdown
		local listTheme = dropdownTheme.listTheme or dropdownTheme
		local showDropdown = state.showDropdown
		local buttonRef = self.buttonRef and self.buttonRef.current
		local buttonExtents
		if buttonRef then
			local buttonMin = buttonRef.AbsolutePosition
			local buttonSize = buttonRef.AbsoluteSize
			local buttonMax = buttonMin + buttonSize
			buttonExtents = Rect.new(buttonMin.X, buttonMin.Y, buttonMax.X, buttonMax.Y)
		end
		local listWidth = props.ListWidth or 0
		local items = props.Items or {}
		local size = props.Size
		local position = props.Position
		local textSize = props.TextSize
		local itemHeight = props.ItemHeight
		local maxItems = props.MaxItems
		local showRibbon = props.ShowRibbon

		local textPadding = props.TextPadding or TEXT_PADDING
		local iconSize = props.IconSize or ICON_SIZE
		local iconPadding = props.IconPadding or ICON_PADDING
		local scrollBarPadding = props.ScrollBarPadding
		local scrollBarThickness = props.ScrollBarThickness

		local hoveredKey = state.hoveredKey
		local selectedItem = props.SelectedItem
		local isButtonHovered = state.isButtonHovered
		local buttonText = props.ButtonText

		local maxWidth = 0
		local maxHeight = maxItems and (maxItems * itemHeight) or nil
		local LayoutOrder = props.LayoutOrder or 0

		for _, data in ipairs(items) do
			local textBound = TextService:GetTextSize(data.Text,
				textSize, dropdownTheme.font, Vector2.new(9000, 100))

			local itemWidth = textBound.X + textPadding * 2
			maxWidth = math.max(maxWidth, itemWidth)
		end

		maxWidth = math.max(maxWidth, listWidth)

		local buttonTheme = (showDropdown or isButtonHovered) and dropdownTheme.selected
			or dropdownTheme

		return Roact.createElement("ImageButton", {
			Size = size,
			Position = position,
			BackgroundTransparency = 1,
			ImageTransparency = 1,

			[Roact.Ref] = self.buttonRef,

			[Roact.Event.Activated] = self.showDropdown,
			[Roact.Event.MouseEnter] = self.onMouseEnter,
			[Roact.Event.MouseLeave] = self.onMouseLeave,

			LayoutOrder = LayoutOrder,
		}, {
			RoundFrame = Roact.createElement(RoundFrame, {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = buttonTheme.backgroundColor,
				BorderColor3 = buttonTheme.borderColor,
			}),

			ArrowIcon = Roact.createElement("ImageLabel", {
				Size = UDim2.new(0, iconSize, 0, iconSize),
				Position = UDim2.new(1, -iconPadding, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 1,
				ImageColor3 = buttonTheme.textColor,
				Image = dropdownTheme.arrowImage,
			}),

			TextLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, -iconSize, 1, 0),
				BackgroundTransparency = 1,
				Font = dropdownTheme.font,
				TextColor3 = buttonTheme.textColor,
				TextSize = textSize,
				Text = buttonText,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, textPadding),
				}),
			}),

			Dropdown = showDropdown and buttonRef and Roact.createElement(DropdownMenu, {
				OnItemClicked = self.onItemClicked,
				OnFocusLost = self.hideDropdown,
				SourceExtents = buttonExtents,
				Offset = Vector2.new(0, VERTICAL_OFFSET),
				MaxHeight = maxHeight,
				ShowBorder = true,
				ScrollBarPadding = scrollBarPadding,
				ScrollBarThickness = scrollBarThickness,
				ListWidth = maxWidth,
				Items = items,
				RenderItem = function(item, index, activated)
					local key = item.Key
					local selected = key == selectedItem
					local displayText = item.Text
					local isHovered = hoveredKey == key
					local textColor = (selected or isHovered) and dropdownTheme.hovered.textColor
						or dropdownTheme.textColor
					local itemColor = listTheme.backgroundColor
					if selected then
						itemColor = listTheme.selected.backgroundColor
					elseif isHovered then
						itemColor = listTheme.hovered.backgroundColor
					end

					return Roact.createElement("ImageButton", {
						Size = UDim2.new(0, maxWidth, 0, itemHeight),
						BackgroundColor3 = itemColor,
						BorderSizePixel = 0,
						LayoutOrder = index,
						AutoButtonColor = false,
						[Roact.Event.Activated] = activated,
					}, {
						Ribbon = isHovered and showRibbon and Roact.createElement("Frame", {
							Size = UDim2.new(0, RIBBON_WIDTH, 1, 0),
							BackgroundColor3 = listTheme.selected.backgroundColor,
							BorderSizePixel = 0,
						}),

						Label = self:createLabel(key, displayText, textSize,
							textPadding, dropdownTheme.font, textColor),
					})
				end,
			})
		})
	end)
end

return StyledDropdown
