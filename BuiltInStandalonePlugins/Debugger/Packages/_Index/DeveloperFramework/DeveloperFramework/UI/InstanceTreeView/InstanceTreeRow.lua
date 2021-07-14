--[[
	Displays the hierarchy of an instance.

	Required Props:
		table row: The InstanceTreeView to render
		table style: The style of the parent InstanceTreeView
		callback onToggled: Called when the user toggles the row
		callback onSelected: Called when the user selects the row

	Optional Props:
		Style Style: a style table supplied from props and theme:getStyle()
		boolean isSelected: Whether the row is selected
		boolean isExpanded: Whether the row is expanded
]]

local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local Util = require(Framework.Util)
local Typecheck = Util.Typecheck

local isInputMainPress = Util.isInputMainPress

local InstanceTreeRow = Roact.PureComponent:extend("InstanceTreeRow")

local UI = Framework.UI
local Container = require(UI.Container)
local TextLabel = require(UI.TextLabel)
Typecheck.wrap(InstanceTreeRow, script)

local defaultIcon = {
	Image = "rbxasset://textures/ClassImages.png",
	ImageRectOffset = Vector2.new(736, 0),
	ImageRectSize = Vector2.new(16, 16),
}

local StudioService = game:GetService("StudioService")
-- Prevent GetClassIcon throwing an error from crashing the UI
local canUseGetClassIcon = pcall(function()
	return StudioService:GetClassIcon("Folder")
end)

local function getClassIcon(instance)
	if not canUseGetClassIcon then
		return defaultIcon
	end
	local className = instance.ClassName
	if instance.IsA then
		if instance:IsA("JointInstance") and className == "ManualWeld" or className == "ManualGlue" then
			return StudioService:GetClassIcon("JointInstance")
		end
	end
	return StudioService:GetClassIcon(className)
end

function InstanceTreeRow:init()
	self.state = {
		isHovering = false
	}

	self.onMouseEnter = function()
		self:setState({
			isHovering = true
		})
	end

	self.onMouseLeave = function()
		self:setState({
			isHovering = false
		})
	end

	self.onInputBegan = function(frame, input)
		local isMainPress = isInputMainPress(input)
		if isMainPress then
			self.props.onSelected(self.props.row)
		end
	end
end

function InstanceTreeRow:render()
	local props = self.props
	local row = props.row
	local item = row.item
	local style = props.style
	local isSelected = props.isSelected
	local isExpanded = props.isExpanded
	local hasChildren = #item:GetChildren() > 0
	
	local onToggled = props.onToggled
	local indent = row.depth * style.Indent

	local arrowSize = style.Arrow.Size
	local padding = style.IconPadding
	local iconInfo = getClassIcon(item)

	-- Default iconSize to (0, 0) as ImageRectSize is unavailable in Roblox CLI
	local iconSize = iconInfo.ImageRectSize or Vector2.new()
	local labelOffset = indent + arrowSize + 2 * padding
	local textOffset = iconSize.X + 3 * padding

	return Roact.createElement(Container, {
		Size = UDim2.new(1, -indent, 0, style.RowHeight),
		LayoutOrder = row.index,
	}, {
		Toggle = hasChildren and Roact.createElement("ImageButton", {
			Position = UDim2.new(0, indent + padding, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.new(0, arrowSize, 0, arrowSize),
			BackgroundTransparency = 1,
			Image = style.Arrow.Image,
			ImageColor3 = style.Arrow.Color,
			ImageRectSize = Vector2.new(arrowSize, arrowSize),
			ImageRectOffset = isExpanded and style.Arrow.ExpandedOffset or style.Arrow.CollapsedOffset,
			[Roact.Event.Activated] = function()
				onToggled(row)
			end
		}) or nil,
		Label = Roact.createElement("Frame", {
			[Roact.Event.MouseEnter] = self.onMouseEnter,
			[Roact.Event.MouseLeave] = self.onMouseLeave,
			[Roact.Event.InputBegan] = self.onInputBegan,
			BackgroundTransparency = self.state.isHovering or isSelected and 0 or 1,
			BorderSizePixel = 0,
			BackgroundColor3 = isSelected and style.SelectedColor or style.HoverColor,
			Position = UDim2.fromOffset(labelOffset, 0),
			Size = UDim2.new(1, -arrowSize, 1, 0),
		}, {
			Icon = Roact.createElement("ImageLabel", {
				Size = UDim2.fromOffset(iconSize.X, iconSize.Y),
				BackgroundTransparency = 1,
				Image = iconInfo.Image,
				ImageRectSize = iconSize,
				ImageRectOffset = iconInfo.ImageRectOffset,
				Position = UDim2.new(0, padding, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5)
			}),
			Text = Roact.createElement(TextLabel, {
				Style = style.Text,
				Text = item.Name,
				TextColor = isSelected and style.SelectedTextColor or nil,
				Size = UDim2.new(1, -textOffset, 1, 0),
				Position = UDim2.new(0, textOffset, 0, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center
			})
		})
	})
end

return InstanceTreeRow
