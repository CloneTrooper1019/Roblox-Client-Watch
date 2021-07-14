--[[
	A generic dropdown menu interface which can accept any kind of components.
	The consuming component is in charge of implementing the logic that dictates
	when this dropdown menu should show and hide.

	This dropdown detects if it is too close to the corners of the gui and realigns if needed.
	For example, if it is too close to the bottom of the gui to render all elements, it
	renders its elements above the hosting button instead of below.

	For an example of how this component can be used, see StyledDropdown.

	Required Props:
		Rect SourceExtents = A Rect representing the absolute position and size of
			the button which is hosting this dropdown.

		table Items = An ordered array of each item that should appear in the dropdown.
			Each item in the array can be of any format, and will be passed to the RenderItem function.
		function RenderItem(item, index, activated) = A function used to render a dropdown item.
			Item is an entry from the Items array that was passed into this component's props.
			Index is the index of the current item in the Items array.
			Activated is a callback that the item should connect if it is clickable.

		function OnItemClicked(item) = A callback for when the user selects a dropdown entry.
			Returns the item as it was defined in the Items array.
		function OnFocusLost = A callback for when the user clicks away from the dropdown
			without selecting an item.

	Optional Props:
		int MaxHeight = An optional maximum height for this dropdown. If the items surpass
			the max height, a scrollbar will be added to the dropdown so all items are visible.
		int ScrollBarPadding = The padding which appears on either side of the scrollbar.
		int ScrollBarThickness = The horizontal width of the scrollbar.
		bool ShowBorder = Whether to show a border around the elements in the dropdown.
		Vector2 Offset = An offset from the button which is hosting this dropdown.
			Note that the dropdown already takes into account the size of the hosting button,
			and will already automatically place itself below the button. This offset is optional
			and can be used to add some extra padding.
		Enum.VerticalAlignment StartDirection=Bottom The direction the DropdownMenu will appear
			from SourceExtents by default. This can only be Top/Bottom. This will not lock the
			direction of the DropdownMenu. If there is not enough room in the default direction,
			it will flip to the other direction
]]

local ROUNDED_FRAME_SLICE = Rect.new(3, 3, 13, 13)
local SCROLLBAR_THICKNESS = 8
local SCROLLBAR_PADDING = 2

local RunService = game:GetService("RunService")

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local Focus = require(Library.Focus)
local CaptureFocus = Focus.CaptureFocus
local withFocus = Focus.withFocus

local StyledScrollingFrame = require(Library.Components.StyledScrollingFrame)

local DropdownMenu = Roact.PureComponent:extend("DropdownMenu")

function DropdownMenu:init(props)
	assert( props.StartDirection == Enum.VerticalAlignment.Top or
			props.StartDirection == Enum.VerticalAlignment.Bottom or
			props.StartDirection == nil,

			"StartDirection must be Enum.VerticalAlignment.Bottom, Enum.VerticalAlignment.Top, or nil. "
			.."Got '"..tostring(props.StartDirection).."'"
	)

	self.direction = props.StartDirection or Enum.VerticalAlignment.Bottom
	self.layout = 0

	self.recalculateSize = function(rbx)
		-- We have to wait one step to change the state here, or
		-- we will change the state while the component is rendering
		-- and the component won't move to the right location.
		local nextStep
		nextStep = RunService.Heartbeat:Connect(function()
			nextStep:Disconnect()

			-- The component may have since been unmounted, in which case
			-- we shouldn't update state or it will fail with an error
			if not self.mounted then return end

			self:setState({
				menuSize = rbx.AbsoluteContentSize
			})
		end)
	end

	self.resetLayout = function()
		self.layout = 0
	end

	self.nextLayout = function()
		self.layout = self.layout + 1
		return self.layout
	end
end

function DropdownMenu:didMount()
	self.mounted = true
end

function DropdownMenu:willUnmount()
	self.mounted = false
end

function DropdownMenu:render()
	return withTheme(function(theme)
		return withFocus(function(pluginGui)
			local props = self.props
			local state = self.state

			local items = props.Items
			local renderItem = self.props.RenderItem
			local sourceExtents = props.SourceExtents

			assert(items ~= nil and type(items) == "table",
				"DropdownMenu requires an Items table.")
			assert(renderItem ~= nil and type(renderItem) == "function",
				"DropdownMenu requires a RenderItem function.")
			assert(sourceExtents ~= nil,
				"DropdownMenu requires a SourceExtents prop.")

			local components = {}

			local dropdownTheme = theme.dropdownMenu

			local canRender = state.menuSize ~= nil
			local menuSize = state.menuSize or Vector2.new()
			local width = props.ListWidth or menuSize.X
			local height = menuSize.Y

			local offset = props.Offset or Vector2.new()
			local showBorder = props.ShowBorder
			local scrollBarThickness = props.ScrollBarThickness or SCROLLBAR_THICKNESS
			local scrollBarPadding = props.ScrollBarPadding or SCROLLBAR_PADDING

			local maxHeight = props.MaxHeight
			if maxHeight == nil or maxHeight > height then
				maxHeight = height
			elseif maxHeight < height then
				-- Add scrollbar gutter
				width = width + scrollBarThickness + (scrollBarPadding * 2)
			end

			local sourcePosition = sourceExtents.Min
			local sourceSize = Vector2.new(sourceExtents.Width, sourceExtents.Height)
			local guiSize = pluginGui.AbsoluteSize

			local xPos, yPos
			if sourcePosition.X + offset.X + width <= guiSize.X then
				xPos = sourcePosition.X + offset.X
			else
				xPos = sourcePosition.X + sourceSize.X + offset.X - width
			end

			local enoughRoomOnBottom = sourcePosition.Y + sourceSize.Y + offset.Y + maxHeight < guiSize.Y
			local enoughRoomOnTop = sourcePosition.Y - offset.Y - maxHeight > 0

			-- Don't flip if there is not enough room on either side. This will just cause a spasm of
			-- flip-flopping every render
			if enoughRoomOnBottom or enoughRoomOnTop then
				if self.direction == Enum.VerticalAlignment.Bottom and not enoughRoomOnBottom then
					self.direction = Enum.VerticalAlignment.Top
				elseif self.direction == Enum.VerticalAlignment.Top and not enoughRoomOnTop then
					self.direction = Enum.VerticalAlignment.Bottom
				end
			end

			local verticalAlignment
			if self.direction == Enum.VerticalAlignment.Bottom then
				yPos = sourcePosition.Y + sourceSize.Y + offset.Y
				verticalAlignment = Enum.VerticalAlignment.Top
			else
				yPos = sourcePosition.Y - offset.Y - maxHeight
				verticalAlignment = Enum.VerticalAlignment.Bottom
			end

			local position = UDim2.new(0, xPos, 0, yPos)

			components.Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = verticalAlignment,
				[Roact.Change.AbsoluteContentSize] = self.recalculateSize,
			})

			for index, item in ipairs(items) do
				table.insert(components, renderItem(item, index, function()
					self.props.OnItemClicked(item)
				end))
			end

			local contents = {
				Border = showBorder and Roact.createElement("ImageLabel", {
					Visible = canRender,
					Position = position,
					Size = UDim2.new(0, width, 0, maxHeight),
					ZIndex = 3,

					BackgroundTransparency = 1,
					ImageColor3 = dropdownTheme.borderColor,

					Image = dropdownTheme.borderImage,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = ROUNDED_FRAME_SLICE,
				}),
			}

			if maxHeight and maxHeight < height then
				contents.ScrollingContainer = Roact.createElement(StyledScrollingFrame, {
					Visible = canRender,
					Position = position,
					Size = UDim2.new(0, width, 0, maxHeight),
					BackgroundTransparency = 1,
					CanvasSize = UDim2.new(0, 0, 0, height),
					ScrollBarPadding = scrollBarPadding,
					ScrollBarThickness = scrollBarThickness,
				}, components)
			else
				contents.Container = Roact.createElement("Frame", {
					Visible = canRender,
					Position = position,
					Size = UDim2.new(0, width, 0, height),
					BackgroundTransparency = 1,
				}, components)
			end

			return Roact.createElement(CaptureFocus, {
				OnFocusLost = props.OnFocusLost,
			}, contents)
		end)
	end)
end

return DropdownMenu
