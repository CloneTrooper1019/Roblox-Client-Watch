local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent

local UIBlox = require(Packages.UIBlox)
local Roact = require(Packages.Roact)
local Cryo = require(Packages.Cryo)

local withStyle = UIBlox.Core.Style.withStyle
local InteractableList = UIBlox.Core.Control.InteractableList
local ControlState = UIBlox.Core.Control.Enum.ControlState
local SelectionMode = UIBlox.Core.Control.Enum.SelectionMode

local Story = Roact.Component:extend("Story")

local kItems = {"one", "two", "three", "four", "five"}

function Story:init()
	self:setState({
		selection = {},
		selectionMode = SelectionMode.Single,
		items = kItems,
	})
	self.dataInputRef = Roact.createRef()
end

function Story:renderControls(frameProps)
	return Roact.createElement("Frame", frameProps, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 5),
		}),
		DataLabel = Roact.createElement("TextLabel", {
			LayoutOrder = 3,
			Text = "Item list",
			Size = UDim2.new(0, 100, 0, 40),
			BorderSizePixel = 0,
		}, {}),
		DataInput = Roact.createElement("TextBox", {
			LayoutOrder = 4,
			Size = UDim2.new(0, 250, 0, 40),
			BackgroundColor3 = Color3.new(.9, .9, .9),
			Text = table.concat(self.state.items, ","),
			ClearTextOnFocus = false,
			[Roact.Ref] = self.dataInputRef,
		}, {}),
		DataButton = Roact.createElement("TextButton", {
			LayoutOrder = 5,
			Text = "Apply",
			Size = UDim2.new(0, 100, 0, 40),
			[Roact.Event.Activated] = function()
				local dataInput = self.dataInputRef:getValue()
				local dataInputText = dataInput and dataInput.Text or "N/A"
				self:setState({
					items = dataInputText:split(","),
				})
			end
		}, {}),
	})
end

function Story:renderOutput(frameProps)
	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme
		local fonts = stylePalette.Font

		return Roact.createElement("Frame", Cryo.Dictionary.join(frameProps, {
			BackgroundColor3 = theme.BackgroundUIDefault.Color,
			BackgroundTransparency = theme.BackgroundUIDefault.Transparency,
		}), {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 5),
			}),
			List = Roact.createElement(InteractableList, {
				layoutOrder = 1,
				size = UDim2.new(0, 150, 1, 0),
				itemList = self.state.items,
				itemSize = UDim2.new(1, 0, 0, 50),
				padding = UDim.new(0, 10),
				renderItem = function(item, state, selected)
					local bgStyle = theme.BackgroundUIDefault
					local textStyle = theme.UIDefault
					if state == ControlState.Hover then
						bgStyle = theme.BackgroundOnHover
						textStyle = theme.UIEmphasis
					elseif state == ControlState.Pressed then
						bgStyle = theme.BackgroundOnPress
						textStyle = theme.UIEmphasis
					end
					if selected then
						textStyle = theme.ContextualPrimaryDefault
					end
					return Roact.createElement("TextLabel", {
						Size = UDim2.fromScale(1, 1),
						BackgroundColor3 = bgStyle.Color,
						BackgroundTransparency = bgStyle.Transparency,
						Text = item,
						Font = fonts.Body.Font,
						TextSize = fonts.Body.RelativeSize * fonts.BaseSize,
						TextColor3 = textStyle.Color,
						TextTransparency = textStyle.Transparency,
						BorderSizePixel = 0,
					})
				end,
				onSelectionChanged = function(newSelection)
					self:setState({
						selection = newSelection,
					})
				end,
				selectionMode = self.props.controls.selectionMode,
			}),
			Selection = Roact.createElement("TextLabel", {
				LayoutOrder = 2,
				Size = UDim2.new(1, -160, 1, 0),
				BackgroundColor3 = theme.BackgroundUIDefault.Color,
				BackgroundTransparency = theme.BackgroundUIDefault.Transparency,
				Text = table.concat(Cryo.List.map(self.state.selection, function(selectedKey)
					return self.state.items[selectedKey] or "N/A"
				end), "\n"),
				Font = fonts.Body.Font,
				TextColor3 = theme.UIDefault.Color,
				TextTransparency = theme.UIDefault.Transparency,
				TextScaled = true,
				BorderSizePixel = 0,
			})
		})
	end)
end

function Story:render()
	return Roact.createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 5),
		}),
		ControlsFrame = self:renderControls({
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 50),
		}),
		OutputFrame = self:renderOutput({
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 1, -60),
		}),
	})
end

return {
	controls = {
		selectionMode = { SelectionMode.None, SelectionMode.Single, SelectionMode.Multiple },
	},
	summary = "Click to switch selection mode, or change contents and apply",
	story = Story
}
