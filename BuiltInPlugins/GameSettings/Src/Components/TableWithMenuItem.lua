--[[
	Individual entry in table

	Props:
		table RowData = Row data to add in the table
		table MenuItems = list of options to display in dropdown for button
			Formatted like this:
			{
				{Key = "Item1", Text = "SomeLocalizedTextForItem1"},
				{Key = "Item2", Text = "SomeLocalizedTextForItem2"},
			}
		function OnItemClicked(item) = A callback when the user selects an item in the dropdown.
			Returns the item as it was defined in the Items array.
		int LayoutOrder = Order of element in layout
	Optional Props:
		thumbnail Icon = Icon to display in first column of row entry
]]
local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Cryo = require(Plugin.Cryo)
local UILibrary = require(Plugin.UILibrary)

local Framework = Plugin.Framework

local ContextServices = require(Framework.ContextServices)

local UI = require(Framework.UI)
local HoverArea = UI.HoverArea

local FrameworkUtil = require(Plugin.Framework.Util)
local FitTextLabel = FrameworkUtil.FitFrame.FitTextLabel

local DropdownMenu = UILibrary.Component.DropdownMenu
local Tooltip = UILibrary.Component.Tooltip

local TextService = game:GetService("TextService")

local TableWithMenuItem = Roact.PureComponent:extend("TableWithMenuItem")

local function createRowLabelsWithIcon(theme, rowData, icon)
	local rowLabels = {}
	local width = 1 / (#rowData + 1) -- +1 because the icon takes a column and is not included in #rowData
	for col = (0), #rowData do -- iteration 0 adds column with icon
		local cellData = rowData[col]
		local cell
		if col == 0 then
			local iconContainer = Roact.createElement("Frame", {
				Size = UDim2.new(0, theme.table.icon.height, 0, theme.table.icon.height),
				BackgroundTransparency = 1,
			}, {
				Icon = icon,
			})
			cell = Roact.createElement("Frame", {
				LayoutOrder = col,
				Size = UDim2.new(width, 0, 0, theme.table.icon.height),
				BackgroundTransparency = 1,
			}, {
				Icon = iconContainer,
			})
		elseif col ~= #rowData then
			cell = Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Smaller, {
				Size = UDim2.new(width, 0, 0, theme.table.item.height),
				LayoutOrder = col,
				Text = cellData,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}), {
				Tooltip = Roact.createElement(Tooltip, {
					Text = cellData,
					Enabled = true,
				}),
			})
		else
			-- leave room for button
			cell = Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Smaller, {
				Size = UDim2.new(width, -theme.table.menu.buttonSize, 0, theme.table.item.height),
				LayoutOrder = col,
				Text = cellData,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}), {
				Tooltip = Roact.createElement(Tooltip, {
					Text = cellData,
					Enabled = true,
				}),
			})
		end
		rowLabels[col] = cell
	end

	return rowLabels
end

local function createRowLabels(theme, rowData)
	local rowLabels = { }
	for col = 1, #rowData do
		local cellData = rowData[col]
		local cell
		if col ~= #rowData then
			cell = Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Smaller, {
				Size = UDim2.new(1 / #rowData, 0, 0, theme.table.item.height),
				LayoutOrder = col,

				Text = cellData,

				BackgroundTransparency = 1,

				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}), {
				Tooltip = Roact.createElement(Tooltip, {
					Text = cellData,
					Enabled = true,
				}),
			})
		else
			-- leave room for button
			cell = Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Smaller, {
				Size = UDim2.new(1 / #rowData, -theme.table.menu.buttonSize, 0, theme.table.item.height),
				LayoutOrder = col,

				Text = cellData,

				BackgroundTransparency = 1,

				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}), {
				Tooltip = Roact.createElement(Tooltip, {
					Text = cellData,
					Enabled = true,
				}),
			})
		end
		rowLabels[col] = cell
	end

	return rowLabels
end

function TableWithMenuItem:init()
	self.state = {
		showMenu = false,
		isButtonHovered = false,
		menuItem = nil,
	}
	self.buttonRef = Roact.createRef()

	self.onItemClicked = function(item)
		self.props.OnItemClicked(item.Key)
		self.hideMenu()
	end

	self.showMenu = function()
		self:setState({
			showMenu = true,
		})
	end

	self.hideMenu = function()
		self:setState({
			showMenu = false,
			menuItem = Roact.None,
		})
	end

	self.onMenuItemEnter = function(item)
		self:setState({
			menuItem = item,
		})
	end

	self.onMenuItemLeave = function(item)
		if self.state.menuItem == item then
			self:setState({
				menuItem = Roact.None,
			})
		end
	end
end

function TableWithMenuItem:renderMenuItem(item, index, activated, theme, maxWidth)
	local key = item.Key
	local displayText = item.Text
	local isHovered = self.state.menuItem == key

	local displayTextBound = TextService:GetTextSize(displayText,
		theme.fontStyle.Normal.TextSize, theme.fontStyle.Normal.Font, Vector2.new(maxWidth, math.huge))

	local itemColor = theme.dropDownEntry.background
	if isHovered then
		itemColor = theme.dropDownEntry.hovered
	end

	return Roact.createElement("ImageButton", {
		Size = UDim2.new(0, maxWidth, 0, displayTextBound.Y + theme.table.menu.buttonPaddingY),
		BackgroundColor3 = itemColor,
		BorderSizePixel = 0,
		LayoutOrder = index,
		AutoButtonColor = false,
		[Roact.Event.Activated] = activated,
		[Roact.Event.MouseEnter] = function()
			self.onMenuItemEnter(key)
		end,
		[Roact.Event.MouseLeave] = function()
			self.onMenuItemLeave(key)
		end,
	}, {
		Roact.createElement(HoverArea, {Cursor = "PointingHand"}),

		Label = Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Smaller, {
			Size = UDim2.new(1, 0, 0, displayTextBound.Y),
			Position = UDim2.new(0, theme.table.textPadding, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Text = displayText,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
		})),
	})
end

function TableWithMenuItem:render()
	local props = self.props
	local state = self.state
	local theme = props.Theme:get("Plugin")

	local rowData = props.RowData
	local layoutOrder = props.LayoutOrder

	local icon = props.Icon
	local row = icon and createRowLabelsWithIcon(theme, rowData, icon) or createRowLabels(theme, rowData)

	local showMenu = state.showMenu
	local buttonRef = self.buttonRef and self.buttonRef.current
	local buttonExtents
	if buttonRef then
		local buttonMin = buttonRef.AbsolutePosition
		local buttonSize = buttonRef.AbsoluteSize
		local buttonMax = buttonMin + buttonSize
		buttonExtents = Rect.new(buttonMin.X, buttonMin.Y, buttonMax.X, buttonMax.Y)
	end

	local menuItems = props.MenuItems

	local maxWidth = 0
	for _, data in ipairs(menuItems) do
		local textBound = TextService:GetTextSize(data.Text,
			theme.fontStyle.Normal.TextSize, theme.fontStyle.Normal.Font, Vector2.new(math.huge, math.huge))

		local itemWidth = textBound.X + theme.table.menu.itemPadding
		maxWidth = math.max(maxWidth, itemWidth)
	end

	row[#rowData + 1] = Roact.createElement("ImageButton", {
		Size = UDim2.new(0, theme.table.menu.buttonSize, 0, theme.table.menu.buttonSize),
		LayoutOrder = #rowData + 1,

		BackgroundTransparency = 1,

		[Roact.Ref] = self.buttonRef,

		[Roact.Event.Activated] = self.showMenu,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, theme.table.item.padding),
		}),

		Dots = Roact.createElement(FitTextLabel,  Cryo.Dictionary.join(theme.fontStyle.Normal, {
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),

			Text = "...",
			Font = Enum.Font.SourceSansBold,

			BackgroundTransparency = 1,

			width = theme.table.menu.buttonSize,
		})),

		Menu = showMenu and buttonRef and Roact.createElement(DropdownMenu, {
			OnItemClicked = self.onItemClicked,
			OnFocusLost = self.hideMenu,
			SourceExtents = buttonExtents,
			ShowBorder = false,

			Items = menuItems,
			RenderItem = function(item, index, activated)
				return self:renderMenuItem(item, index, activated, theme, maxWidth)
			end,
		}),

		Roact.createElement(HoverArea, {Cursor = "PointingHand"}),
	})
	
	local iconOffset = 10
	local height = (icon and theme.table.icon.height + iconOffset) or theme.table.item.height

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, height),

		BackgroundColor3 = theme.table.item.background,
		BorderSizePixel = 0,

		LayoutOrder = layoutOrder,
	}, Cryo.Dictionary.join({
		RowLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Padding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, theme.table.textPadding),
			PaddingRight = UDim.new(0, theme.table.textPadding),
		}),
	}, row))
end

ContextServices.mapToProps(TableWithMenuItem, {
	Theme = ContextServices.Theme,
	Mouse = ContextServices.Mouse,
})

return TableWithMenuItem
