--[[
	A dropdown menu styled to match the Roblox Studio start page.
	Consists of a button used to open the dropdown as well as the menu itself.
	Note that the logic for opening and closing the menu is contained within this component,
	but the consumer is responsible for showing the current value in the button.

	Required Props:
		UDim2 Size = The size of the button that opens the dropdown.
		UDim2 Position = The position of the button that opens the dropdown.
		int DisplayTextSize = The size of the text in the dropdown and button.
		int DescriptionTextSize = The size of the subtext in the dropdown
		int ItemHeight = The height of each entry in the dropdown, in pixels.
		string ButtonText = Text to display currently selected option in menu
		array Items = An ordered array of each item that should appear in the dropdown.
			The array is formatted like this:
			{
				{Key = "Item1", Display = "SomeLocalizedTextForItem1", Description = "SomeLocalizedDescriptionForItem1"},
				{Key = "Item2", Display = "SomeLocalizedTextForItem2", Description = "SomeLocalizedDescriptionForItem2"},
				{Key = "Item3", Display = "SomeLocalizedTextForItem3", Description = "SomeLocalizedDescriptionForItem3"},
			}
			Key is how the item will be referenced in code. Text is what will appear to the user.
		function OnItemClicked(item) = A callback when the user selects an item in the dropdown.
			Returns the item as it was defined in the Items array.
		bool Enabled = Enables component if true and accepts input

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
local TEXT_PADDING = 10
local ICON_SIZE = 12
local ICON_PADDING = 4

local RIBBON_WIDTH = 5
local VERTICAL_OFFSET = 2

local MAX_WIDTH = 300

local TextService = game:GetService("TextService")

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local DropdownMenu = require(Library.Components.DropdownMenu)
local RoundFrame = require(Library.Components.RoundFrame)
local createFitToContent = require(Library.Components.createFitToContent)

local DetailedDropdown = Roact.PureComponent:extend("DetailedDropdown")

local FitToContent = createFitToContent("Frame", "UIListLayout", {
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, TEXT_PADDING),
})

function DetailedDropdown:init()
	self.state = {
		showDropdown = false,
		isButtonHovered = false,
		dropdownItem = nil,
	}
	self.buttonRef = Roact.createRef()

	self.onItemClicked = function(item)
		if self.props.Enabled then
			self.props.OnItemClicked(item.Key)
			self.hideDropdown()
		end 
	end

	self.showDropdown = function()
		if self.props.Enabled then
			self:setState({
				showDropdown = true,
			})
		end
	end

	self.hideDropdown = function()
		if self.props.Enabled then
			self:setState({
				showDropdown = false,
			})
		end
	end

	self.onKeyMouseEnter = function(item)
		if self.props.Enabled then
			self:setState({
				dropdownItem = item,
			})
		end
	end

	self.onKeyMouseLeave = function(item)
		if self.props.Enabled then
			if self.state.dropdownItem == item then
				self:setState({
					dropdownItem = Roact.None,
				})
			end
		end
	end

	self.onMouseEnter = function()
		if self.props.Enabled then
			self:setState({
				isButtonHovered = true,
			})
		end
	end

	self.onMouseLeave = function()
		if self.props.Enabled then
			self:setState({
				isButtonHovered = false,
			})
		end
	end
end

function DetailedDropdown:createMainTextLabel(key, displayText, displayTextSize, displayTextColor, textPadding, font, height)
	return Roact.createElement("TextLabel", {
		Size = UDim2.new(1, 0, 0, height),
		Font = font,
		TextSize = displayTextSize,
		Text = displayText,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = displayTextColor,
		BackgroundTransparency = 1,
		TextWrapped = true,
		LayoutOrder = 0,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, textPadding),
			PaddingLeft = UDim.new(0, textPadding),
        }),
	})
end

function DetailedDropdown:createDescriptionTextLabel(key, descriptionText, descriptionTextSize, descriptionTextColor, textPadding, font, height)
	return Roact.createElement("TextLabel", {
		Size = UDim2.new(1, 0, 0, height),
		Font = font,
		TextSize = descriptionTextSize,
		Text = descriptionText,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = descriptionTextColor,
		BackgroundTransparency = 1,
		TextWrapped = true,
		LayoutOrder = 1,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, textPadding),
			PaddingRight = UDim.new(0, textPadding),
        }),
	})
end

function DetailedDropdown:render()
	return withTheme(function(theme)
		local props = self.props
		local state = self.state
		local dropdownTheme = theme.detailedDropdown

		local showDropdown = state.showDropdown
		local buttonRef = self.buttonRef and self.buttonRef.current
		local buttonExtents
		if buttonRef then
			local buttonMin = buttonRef.AbsolutePosition
			local buttonSize = buttonRef.AbsoluteSize
			local buttonMax = buttonMin + buttonSize
			buttonExtents = Rect.new(buttonMin.X, buttonMin.Y, buttonMax.X, buttonMax.Y)
		end

		local items = props.Items or {}
		local selectedItem = props.SelectedItem
		local size = props.Size
		local position = props.Position
        local displayTextSize = props.DisplayTextSize
        local descriptionTextSize = props.DescriptionTextSize
		local itemHeight = props.ItemHeight
		local maxItems = props.MaxItems
		local showRibbon = props.ShowRibbon
		local enabled = props.Enabled

		local textPadding = props.TextPadding or TEXT_PADDING
		local iconSize = props.IconSize or ICON_SIZE
		local iconPadding = props.IconPadding or ICON_PADDING
		local scrollBarPadding = props.ScrollBarPadding
		local scrollBarThickness = props.ScrollBarThickness

		local dropdownItem = state.dropdownItem
		local isButtonHovered = state.isButtonHovered
		local buttonText = props.ButtonText

		local maxItemWidth = 0
		local maxWidth = props.MaxWidth or MAX_WIDTH
		local maxHeight = maxItems and (maxItems * itemHeight) or nil

		for _, data in ipairs(items) do
			local displayTextBound = TextService:GetTextSize(data.Display,
                displayTextSize, dropdownTheme.font, Vector2.new(math.huge, math.huge))

            local displayItemWidth = displayTextBound.X + textPadding * 2
            
            local descriptionTextBound = TextService:GetTextSize(data.Description,
                descriptionTextSize, dropdownTheme.font, Vector2.new(math.huge, math.huge))

			local descriptionItemWidth = descriptionTextBound.X + textPadding * 2

			maxItemWidth = math.max(maxItemWidth, displayItemWidth, descriptionItemWidth)
		end

		maxWidth = math.min(maxItemWidth, maxWidth)

		local hoverTheme = dropdownTheme.hovered

		local buttonTheme = (showDropdown or isButtonHovered) and hoverTheme
			or dropdownTheme

		return Roact.createElement("ImageButton", {
			LayoutOrder = props.LayoutOrder or 0,
			AnchorPoint = props.AnchorPoint or Vector2.new(0,0),
			Size = size,
			Position = position,
			BackgroundTransparency = 1,
			Image = "",

			[Roact.Ref] = self.buttonRef,

			[Roact.Event.Activated] = self.showDropdown,
			[Roact.Event.MouseEnter] = self.onMouseEnter,
			[Roact.Event.MouseLeave] = self.onMouseLeave,
		}, {
			RoundFrame = Roact.createElement(RoundFrame, {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = enabled and buttonTheme.backgroundColor or buttonTheme.disabled,
				BorderColor3 = buttonTheme.borderColor,
			}),

			ArrowIcon = Roact.createElement("ImageLabel", {
				Size = UDim2.new(0, iconSize, 0, iconSize),
				Position = UDim2.new(1, -iconPadding, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 1,
				ImageColor3 = enabled and buttonTheme.displayText or buttonTheme.disabledText,
				Image = dropdownTheme.arrowImage,
			}),

			TextLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, -iconSize, 1, 0),
				BackgroundTransparency = 1,
				Font = dropdownTheme.font,
				TextColor3 = enabled and buttonTheme.displayText or buttonTheme.disabledText,
				TextSize = displayTextSize,
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
				ShowBorder = false,
				ScrollBarPadding = scrollBarPadding,
				ScrollBarThickness = scrollBarThickness,

				Items = items,
				RenderItem = function(item, index, activated)
					local key = item.Key
					local selected = key == selectedItem
                    local displayText = item.Display
                    local descriptionText = item.Description
					local isHovered = dropdownItem == key
					local displayTextColor = isHovered and dropdownTheme.hovered.displayText
                        or dropdownTheme.displayText
					local descriptionTextColor = dropdownTheme.descriptionText
					
					local displayTextBound = TextService:GetTextSize(displayText,
                		displayTextSize, dropdownTheme.font, Vector2.new(maxWidth, math.huge))
            
            		local descriptionTextBound = TextService:GetTextSize(descriptionText,
						descriptionTextSize, dropdownTheme.font, Vector2.new(maxWidth, math.huge))

					local itemColor = dropdownTheme.backgroundColor
					if selected then
						itemColor = dropdownTheme.selected.backgroundColor
					elseif isHovered then
						itemColor = dropdownTheme.hovered.backgroundColor
					end

					return Roact.createElement("ImageButton", {
							Size = UDim2.new(0, maxWidth, 0, displayTextBound.Y + descriptionTextBound.Y + textPadding * 2),
							BackgroundColor3 = itemColor,
							BorderSizePixel = 0,
							LayoutOrder = index,
							AutoButtonColor = false,
							[Roact.Event.Activated] = activated,
							[Roact.Event.MouseEnter] = function()
								self.onKeyMouseEnter(key)
							end,
							[Roact.Event.MouseLeave] = function()
								self.onKeyMouseLeave(key)
							end,
						}, {
							Roact.createElement(FitToContent, {
								LayoutOrder = index,
								BackgroundTransparency = 1,
							} , {
								Ribbon = isHovered and showRibbon and Roact.createElement("Frame", {
									Size = UDim2.new(0, RIBBON_WIDTH, 1, 0),
									BackgroundColor3 = dropdownTheme.selected.backgroundColor,
									BorderSizePixel = 0,
								}),

								MainTextLabel = self:createMainTextLabel(key, displayText, displayTextSize, displayTextColor,
									textPadding, dropdownTheme.font, displayTextBound.Y),
								
								DescriptionTextLabel = self:createDescriptionTextLabel(key, descriptionText, descriptionTextSize, descriptionTextColor,
									textPadding, dropdownTheme.font, descriptionTextBound.Y),
							})
						})
				end,
			})
		})
	end)
end

return DetailedDropdown
