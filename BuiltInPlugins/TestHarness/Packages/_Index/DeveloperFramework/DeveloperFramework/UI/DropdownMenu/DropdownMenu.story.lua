local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local DropdownMenu = UI.DropdownMenu

local Example = Roact.PureComponent:extend(script.Parent.Name .. "Example")

function Example:init()
	self.state = {
		isOpen = false
	}
	self.selectItem = function(value, index)
		print("Selected option", index, "value", value)
		self:setState({
			isOpen = false
		})
	end
	self.openMenu = function()
		self:setState({
			isOpen = true
		})
	end
	self.closeMenu = function()
		self:setState({
			isOpen = false
		})
	end
end

function Example:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(0, 240, 0, 32)
	}, {
		Menu = Roact.createElement(DropdownMenu, {
			Hide = not self.state.isOpen,
			Items = {
				"The first element",
				"The second",
				"A really long element",
				"A tiny one",
				"The fifth one",
				"The last one",
			},
			OnItemActivated = self.selectItem,
			OnFocusLost = self.closeMenu
		}),
		Button = Roact.createElement("TextButton", {
			Text = "Open",
			Position = UDim2.new(0, 250, 0, 0),
			Size = UDim2.new(0, 40, 1, 0),
			[Roact.Event.Activated] = self.openMenu,
		})
	})
end

return Example