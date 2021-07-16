--[[
	A component that can listen to change in mouse position while active,
	and then has a callback for removal once the user is done dragging.
	From a stateful component, hold on to a dragging state. When the user
	presses the mouse on a draggable element, set the dragging state to
	true. When dragging is true, render this element. Hook up this element's
	OnDragEnded function to setting the dragging state to false.

	Optional Props:
		callback OnDragMoved: A callback for when the user drags
			the mouse. The input param is the InputObject from the InputChanged event.
		callback OnDragEnded: A callback for when the user has stopped dragging.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local Typecheck = require(Framework.Util).Typecheck
local CaptureFocus = require(Framework.UI.CaptureFocus)

local DragListener = Roact.PureComponent:extend("DragListener")
Typecheck.wrap(DragListener, script)

function DragListener:init()
	self.inputChanged = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if self.props.OnDragMoved then
				self.props.OnDragMoved(input)
			end
		end
	end

	self.inputEnded = function()
		if self.props.OnDragEnded then
			self.props.OnDragEnded()
		end
	end
end

function DragListener:render()
	return Roact.createElement(CaptureFocus, {
		OnFocusLost = self.inputEnded,
	}, {
		Listener = Roact.createElement("ImageButton", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),

			[Roact.Event.InputChanged] = self.inputChanged,
			[Roact.Event.InputEnded] = self.inputEnded,
			[Roact.Event.MouseButton1Up] = self.inputEnded,
			[Roact.Event.MouseButton2Up] = self.inputEnded,
		}, self.props[Roact.Children])
	})
end

return DragListener
