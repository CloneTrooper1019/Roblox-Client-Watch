--[[
	A shouldUpdate implementation for all wrapper components.
]]
local Framework = script.Parent.Parent
local Types = require(Framework.Types)

local Dash = require(Framework.packages.Dash)
local shallowEqual = Dash.shallowEqual

local function wrapperShouldUpdate(self: Types.RoactComponent<any>, nextProps: Types.AnyRecord, nextState: Types.AnyRecord)
	local props = self.props
	local state = self.state
	return props.Component ~= nextProps.Component
		or not shallowEqual(state, nextState)
		or not shallowEqual(props.ComponentProps, nextProps.ComponentProps)
end

return wrapperShouldUpdate
