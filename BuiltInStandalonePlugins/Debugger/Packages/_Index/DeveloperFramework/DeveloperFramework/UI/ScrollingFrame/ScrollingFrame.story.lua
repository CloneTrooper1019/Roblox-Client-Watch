local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local Button = UI.Button
local ScrollingFrame = UI.ScrollingFrame
local Util = require(Framework.Util)
local LayoutOrderIterator = Util.LayoutOrderIterator

local itr = LayoutOrderIterator.new()

local function createButton(text)
	return Roact.createElement(Button, {
		LayoutOrder = itr:getNextOrder(),
		Style = "Round",
		Text = text,
		Size = UDim2.new(1, -8, 0, 32),
		OnClick = function() 
			print(text)
		end,
	})
end
return Roact.createElement(ScrollingFrame, {
	Size = UDim2.fromOffset(300, 100),
}, {
	ButtonA = createButton("Cat"),
	ButtonB = createButton("Dog"),
	ButtonC = createButton("Mouse"),
	ButtonD = createButton("Horse"),
	ButtonE = createButton("Bird"),
	ButtonF = createButton("Jellyfish"),
	ButtonG = createButton("Caterpiller"),
	ButtonH = createButton("Badger"),
	ButtonI = createButton("Catfish"),
})
