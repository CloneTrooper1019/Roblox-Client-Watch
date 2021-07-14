--[[
	The withAbsoluteSize wrapper provides the current AbsoluteSize of the wrapped component
	as a prop in a way that minimizes re-render cycles.

	This is useful if you have a component that should be measured used AutomaticSize, but you also
	want to have children which are proportional to the final size of the component, such as a 100%
	sized decoration or overlay.

	The wrapper passes the WrapperProps table that defines the event handlers for the control,
	which should be merged with the props for the element that is rendered (using i.e. Dash.assign)

	CAUTION: Make sure no elements which depend on the AbsoluteSize exceed the automatic size of the
	component, as this will cause the component to grow indefinitely.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local Types = require(Framework.Types)
local wrapperShouldUpdate = require(script.Parent.wrapperShouldUpdate)

local Dash = require(Framework.packages.Dash)
local joinDeep = Dash.joinDeep

local Resizer = Roact.Component:extend("Resizer")

Resizer.shouldUpdate = wrapperShouldUpdate

function Resizer:init()
	self.ref = Roact.createRef()
	self.state = {
		absoluteSize = Vector2.new(0, 0)
	}
	self.onSizeChanged = function()
		self:resize()
	end
end

function Resizer:resize()
	local pane = self.ref.current
	self:setSize(pane.AbsoluteSize)
end

function Resizer:setSize(absoluteSize: Vector2)
	self:setState(function(prevState)
		if prevState.absoluteSize ~= absoluteSize then
			return {
				absoluteSize = Vector2.new(absoluteSize.X, absoluteSize.Y),
			}
		else
			return nil
		end
	end)
end

function Resizer:didMount()
	self:resize()
end

function Resizer:render()
	local props = self.props
	local state = self.state
	local component = props.Component
	local componentProps = props.ComponentProps
	-- Dash.joinDeep merges any WrapperProps from other wrappers into the component's props
	return Roact.createElement(component, joinDeep({
		AbsoluteSize = state.absoluteSize,
		WrapperProps = {
			[Roact.Change.AbsoluteSize] = self.onSizeChanged,
			[Roact.Ref] = self.ref,
		}
	}, componentProps))
end

local function withAbsoluteSize(component: Types.RoactComponent<any>)
	return function(componentProps)
		return Roact.createElement(Resizer, {
			Component = component,
			ComponentProps = componentProps,
		})
	end
end

return withAbsoluteSize
