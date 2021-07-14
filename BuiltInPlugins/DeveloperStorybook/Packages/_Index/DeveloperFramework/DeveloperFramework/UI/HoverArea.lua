--[[
	A Roact component used to change the mouse cursor on hover when the mouse
	enters the area, and has optional callbacks for when the hover state changed.

	Required Props:
		string Cursor: The mouse cursor which is set when the mouse hovers in this area.
			Cursor allows you to either directly specify an asset, such as
			"rbxasset://textures/advDragIcon.png", or use the string of a SystemCursor,
			such as "PointingHand".
		Mouse Mouse: A Mouse ContextItem, which is provided via mapToProps.

	Optional Props:
		number Priority: The priority of this area in relation to other HoverAreas.
			Higher Priority areas will show their cursor if the mouse hovers over multiple areas.
		UDim2 Size: The size of the component. Defaults to the size of the parent component.
		UDim2 Position: The position of the component. Defaults to zero.
		callback MouseEnter: A callback for when the mouse enters the area.
		callback MouseLeave: A callback for when the mouse leaves the area.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)
local Typecheck = require(Framework.Util).Typecheck

local HoverArea = Roact.PureComponent:extend("HoverArea")
Typecheck.wrap(HoverArea, script)

function HoverArea:init(initialProps)
	local priority = initialProps.Priority
	local cursor = initialProps.Cursor

	self.mouseEnter = function()
		local props = self.props
		props.Mouse:__pushCursor(cursor, priority)
		if props.MouseEnter then
			props.MouseEnter()
		end
	end

	self.mouseLeave = function()
		local props = self.props
		props.Mouse:__popCursor(priority)
		if props.MouseLeave then
			props.MouseLeave()
		end
	end
end

function HoverArea:willUnmount()
	local props = self.props
	props.Mouse:__resetCursor()
end

function HoverArea:render()
	local props = self.props
	local size = props.Size or UDim2.new(1, 0, 1, 0)
	local position = props.Position

	return Roact.createElement("Frame", {
		Size = size,
		Position = position,
		BackgroundTransparency = 1,

		[Roact.Event.MouseEnter] = self.mouseEnter,
		[Roact.Event.MouseLeave] = self.mouseLeave,
	})
end

ContextServices.mapToProps(HoverArea, {
	Mouse = ContextServices.Mouse,
})

return HoverArea
