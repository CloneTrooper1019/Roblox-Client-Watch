--[[
	A single item displayed in a TreeView component.

	Required Props:
		element = instance, The instance to display.
		indent = number, The level of indentation this item appears at.
		canExpand = boolean, Whether this item has children and can be expanded.
		isExpanded = boolean, Whether this item is showing its children.
		isSelected = boolean, Whether this item is the selected item.
		rowIndex = number, The order in which this item appears in the list.
		toggleSelected = callback, A callback when this item is clicked.
]]
local Library = script.Parent.Parent.Parent

local Roact = require(Library.Parent.Parent.Roact)

local GetClassIcon = require(Library.Utils.GetClassIcon)
local TooltipWrapper = require(Library.Components.Tooltip)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local ELEMENT_PADDING = 5

local TreeViewItem = Roact.PureComponent:extend("TreeViewItem")

function TreeViewItem:init()
	self.state = {
		Hovering = false,
	}

	self.mouseEnter = function()
		self:setState({
			Hovering = true,
		})
	end

	self.mouseLeave = function()
		self:setState({
			Hovering = false,
		})
	end

	self.onClick = function()
		self.props.toggleSelected()
	end
end

function TreeViewItem:render(props)
	return withTheme(function(theme)
		local treeViewTheme = theme.instanceTreeView
		local instance = self.props.element
		local name = instance.Name
		local iconInfo = GetClassIcon(instance)
		if typeof(instance) == "table" and instance.Icon then
			iconInfo = instance.Icon
		end

		local indent = self.props.indent
		local expandable = self.props.canExpand
		local expanded = self.props.isExpanded
		local selected = self.props.isSelected
		local layoutOrder = self.props.rowIndex or 1
		local height = treeViewTheme.treeItemHeight
		local hover = self.state.Hovering

		local selectionOffset = height

		local labelOffset = selectionOffset + ELEMENT_PADDING
			+ (iconInfo and (height + treeViewTheme.treeViewIndent) or 0)

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, height),
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, indent * treeViewTheme.treeViewIndent),
			}),

			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, ELEMENT_PADDING),
				FillDirection = Enum.FillDirection.Horizontal,
			}),

			Expand = Roact.createElement("ImageButton", {
				LayoutOrder = 0,
				Size = UDim2.new(0, height, 0, height),
				BackgroundTransparency = 1,
				ImageTransparency = 1,

				[Roact.Event.Activated] = self.props.toggleExpanded,
			}, {
				ExpandIcon = expandable and Roact.createElement("ImageLabel", {
					BackgroundTransparency = 1,
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.new(0, 9, 0, 9),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 1),
					ImageTransparency = expandable and 0 or 1,
					Image = expanded and treeViewTheme.arrowExpanded or treeViewTheme.arrowCollapsed,
					ImageColor3 = treeViewTheme.arrowColor,
				}),
			}),

			Icon = iconInfo and Roact.createElement("ImageLabel", {
				ZIndex = 2,
				LayoutOrder = 1,
				Size = UDim2.new(0, height, 0, height),
				BackgroundTransparency = 1,
				Image = iconInfo.Image,
				ImageRectSize = iconInfo.ImageRectSize,
				ImageRectOffset = iconInfo.ImageRectOffset,
			}),

			Name = Roact.createElement("TextLabel", {
				ZIndex = 2,
				LayoutOrder = 2,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -labelOffset, 0, height),
				Font = treeViewTheme.font,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = treeViewTheme.textSize,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Text = name,
				TextColor3 = selected and treeViewTheme.selectedText or treeViewTheme.textColor,
				BorderSizePixel = 0,
			}, {
				Tooltip = Roact.createElement(TooltipWrapper, {
					Text = name,
					Enabled = hover,
					ShowDelay = treeViewTheme.tooltipShowDelay,
				}),
			}),

			-- We have to create a Folder so that the hover is not affected by the UIListLayout.
			HoverFolder = Roact.createElement("Folder", {}, {
				Hover = Roact.createElement("ImageButton", {
					Size = UDim2.new(1, -selectionOffset, 1, 4),
					Position = UDim2.new(0, selectionOffset, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = (hover or selected) and 0 or 1,
					BackgroundColor3 = selected and treeViewTheme.selected or treeViewTheme.hover,
					BorderSizePixel = 0,
					AutoButtonColor = false,

					[Roact.Event.MouseEnter] = self.mouseEnter,
					[Roact.Event.MouseLeave] = self.mouseLeave,
					[Roact.Event.Activated] = self.onClick,
				}),
			}),
		})
	end)
end

return TreeViewItem