--[[
	A generic dropdown menu interface which can accept any kind of components.
	This dropdown detects if it is too close to the corners of the gui and realigns if needed.
	For example, if it is too close to the bottom of the gui to render all elements, it
	renders its elements above the hosting button instead of below.

	Required Props:
		boolean Hide: Whether the menu is hidden
		table Items: An array of each item that should appear in the dropdown.
		callback OnItemActivated: A callback for when the user selects a dropdown entry.
		Focus Focus: a Focus object supplied by mapToProps()

	Optional Props:
		number Width: The width of the dropdown
		Theme Theme: a Theme object supplied by mapToProps()
		string PlaceholderText: A placeholder to display if there is no item selected.
		callback OnRenderItem: A function used to render a dropdown menu item.
		callback OnFocusLost: A function called when the focus on the menu is lost.
		number SelectedIndex: The currently selected item index.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Style Style: The style with which to render this component.

	Style Values:
		Style BackgroundStyle: The style with which to render the background.
		Vector2 Offset: The offset the menu appears from the input component.
		Color3 BackgroundColor: The background color of the dropdown menu.
		number Width: The width of the menu area.
		number MaxHeight: The maximum height of the menu area.
]]
local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local prioritize = Util.prioritize
local Typecheck = Util.Typecheck

local UI = Framework.UI
local Container = require(UI.Container)
local CaptureFocus = require(UI.CaptureFocus)
local ScrollingFrame = require(UI.ScrollingFrame)
local Button = require(UI.Button)
local RoundBox = require(UI.RoundBox)
local TextLabel = require(UI.TextLabel)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
local FlagsList = Util.Flags.new({
	FFlagRefactorDevFrameworkContextItems = {"RefactorDevFrameworkContextItems"},
	FFlagToolboxReplaceUILibraryComponentsPt2 = {"ToolboxReplaceUILibraryComponentsPt2"},
})

local DropdownMenu = Roact.PureComponent:extend("DropdownMenu")
Typecheck.wrap(DropdownMenu, script)

local BORDER_SIZE = 1

function DropdownMenu:init()
	self.ref = Roact.createRef()

	self.state = {
		absolutePosition = Vector2.new(0, 0),
		absoluteSize = Vector2.new(0, 0),
		menuContentSize = Vector2.new(0, 0),
	}

	self.recalculateContentSize = function(uiLayout)
		local ref = self.ref.current
		if ref ~= nil then
			self:setState({
				menuContentSize = uiLayout.AbsoluteContentSize,
				absolutePosition = ref.AbsolutePosition,
				absoluteSize = ref.AbsoluteSize,
			})
		else
			self:setState({
				menuContentSize = uiLayout.AbsoluteContentSize,
			})
		end
	end

	self.reposition = function()
		local ref = self.ref.current
		if ref ~= nil then
			self:setState({
				absolutePosition = ref.AbsolutePosition,
				absoluteSize = ref.AbsoluteSize,
			})
		end
	end

	self.getPositionAndSize = function(pluginGui, width, offset)
		local state = self.state
		local props = self.props

		-- calculate the size and position of the dropdown
		local height = state.menuContentSize.Y

		local style
		if THEME_REFACTOR then
			style = props.Stylizer
		else
			style = props.Theme:getStyle("Framework", self)
		end
		local maxHeight = style.MaxHeight

		local sourcePosition = state.absolutePosition
		local sourceSize = state.absoluteSize
		local guiSize = pluginGui.AbsoluteSize

		local xPos, yPos
		local fitsAlignedRight = sourcePosition.X + offset.X + width <= guiSize.X
		if fitsAlignedRight then
			xPos = sourcePosition.X + offset.X
		else
			xPos = sourcePosition.X + sourceSize.X + offset.X - width
		end

		local enoughRoomOnBottom = sourcePosition.Y + sourceSize.Y + offset.Y + maxHeight < guiSize.Y
		local enoughRoomOnTop = sourcePosition.Y - offset.Y - maxHeight > 0

		-- Don't flip if there is not enough room on either side. This will just cause a spasm of
		-- flip-flopping every render
		local direction = Enum.VerticalAlignment.Bottom
		if enoughRoomOnBottom or enoughRoomOnTop then
			if direction == Enum.VerticalAlignment.Bottom and not enoughRoomOnBottom then
				direction = Enum.VerticalAlignment.Top
			elseif direction == Enum.VerticalAlignment.Top and not enoughRoomOnTop then
				direction = Enum.VerticalAlignment.Bottom
			end
		end

		local verticalAlignment
		if direction == Enum.VerticalAlignment.Bottom then
			yPos = sourcePosition.Y + sourceSize.Y + offset.Y
			verticalAlignment = Enum.VerticalAlignment.Top
		else
			local heightToSubtract = FlagsList:get("FFlagToolboxReplaceUILibraryComponentsPt2") and math.min(height, maxHeight) or maxHeight
			yPos = sourcePosition.Y - offset.Y - heightToSubtract
			verticalAlignment = Enum.VerticalAlignment.Bottom
		end
		local needsScrollingFrame = height > maxHeight

		return {
			X = xPos,
			Y = yPos,
			Height = math.min(height, maxHeight),
			NeedsScrollingFrame = needsScrollingFrame,
			VerticalAlignment = verticalAlignment,
		}
	end
	self.changeTokens = {}
end

function DropdownMenu:didMount()
	local parent = self.ref.current.Parent
	table.insert(self.changeTokens, parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(self.reposition))
	table.insert(self.changeTokens, parent:GetPropertyChangedSignal("AbsolutePosition"):Connect(self.reposition))
end

function DropdownMenu:willUnmount()
	for _, connection in ipairs(self.changeTokens) do
		connection:Disconnect()
	end
end

local function defaultOnRenderItem(item, index, activated)
	return Roact.createElement(Button, {
		Size = UDim2.new(1, 0, 0, 40),
		LayoutOrder = index,
		OnClick = activated,
	}, {
		Label = Roact.createElement(TextLabel, {
			Size = UDim2.new(1, 0, 1, 0),
			Text = item,
			TextXAlignment = Enum.TextXAlignment.Left
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
			}),
		})
	})
end

function DropdownMenu:renderMenu()
	local state = self.state
	local props = self.props
	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = props.Theme:getStyle("Framework", self)
	end

	local items = props.Items
	local onRenderItem = prioritize(props.OnRenderItem, defaultOnRenderItem)

	local onItemActivated = function(item, index)
		props.OnItemActivated(item, index)
		if props.OnFocusLost then
			props.OnFocusLost()
		end
	end
	local backgroundColor = style.BackgroundColor
	local width = props.Width or style.Width
	local offset = prioritize(style.Offset, Vector2.new(0, 0))

	local pluginGui = FlagsList:get("FFlagRefactorDevFrameworkContextItems") and props.Focus:get() or props.Focus:getTarget()

	local menuPositionAndSize = self.getPositionAndSize(pluginGui, width, offset)
	local x = menuPositionAndSize.X
	local y = menuPositionAndSize.Y
	local height = menuPositionAndSize.Height
	local needsScrollingFrame = menuPositionAndSize.NeedsScrollingFrame
	local verticalAlignment = menuPositionAndSize.VerticalAlignment

	local listElements = {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			VerticalAlignment = verticalAlignment,
			[Roact.Change.AbsoluteContentSize] = self.recalculateContentSize,
		}),
	}

	for index, item in ipairs(items) do
		listElements[tostring(index)] = onRenderItem(item, index, function()
			onItemActivated(item, index)
		end)
	end

	local backgroundStyle = style.BackgroundStyle
	return Roact.createElement(Container, {
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(width, height + BORDER_SIZE * 2),
		Background = RoundBox,
		BackgroundStyle = backgroundStyle,
	}, {
		ScrollingContainer = needsScrollingFrame and Roact.createElement(ScrollingFrame, {
			AutoSizeCanvas = false,
			-- These are needed because container lays out children relative to its outer size, not its inner size
			Size = UDim2.new(1, -BORDER_SIZE * 2, 1, -BORDER_SIZE * 2),
			Position = UDim2.fromOffset(1, 1),
			CanvasSize = UDim2.fromOffset(state.menuContentSize.X, state.menuContentSize.Y),
		}, listElements),

		Container = (needsScrollingFrame == false) and Roact.createElement("Frame", {
			BorderSizePixel = 0,
			-- These are needed because container lays out children relative to its outer size, not its inner size
			Size = UDim2.new(1, -BORDER_SIZE * 2, 1, -BORDER_SIZE * 2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = backgroundColor,
		}, listElements),
	})

end

function DropdownMenu:render()
	local props = self.props
	local state = self.state

	local isOpen = not props.Hide
	local canRender = state.absolutePosition ~= Vector2.new(0, 0)

	return Roact.createElement(Container, {
		[Roact.Ref] = self.ref,
	}, {
		PortalToRoot = isOpen and Roact.createElement(CaptureFocus, {
			OnFocusLost = props.OnFocusLost,
		}, {
			Menu = isOpen and canRender and self:renderMenu()
		})
	})
end

ContextServices.mapToProps(DropdownMenu, {
	Focus = ContextServices.Focus,
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return DropdownMenu
