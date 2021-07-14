local Animation = script.Parent
local Core = Animation.Parent
local UIBlox = Core.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)
local Otter = require(Packages.Otter)
local t = require(Packages.t)

--[[
	A convenient animation wrapper
	provides the same features as SpringAnimatedItem, with a simpler API

	withAnimation({
		option1 = targetValue,
		option2 = target2,
	}, function(values)
		local currentOption = values.option1
		return Roact.createComponent(.....)
	end)
]]

local AnimatedComponent = Roact.PureComponent:extend("AnimatedComponent")

AnimatedComponent.validateProps = t.strictInterface({
	-- target values to animate to
	values = t.table,
	-- function(actualValues: table) called to render components at the current values
	render = t.callback,
	-- otter spring options
	options = t.optional(t.table),
})

function AnimatedComponent:init()
	self:setState({
		values = self.props.values,
	})
	self.motor = Otter.createGroupMotor(self.props.values)
	self.motor:onStep(function(values)
		self:setState({
			values = values,
		})
	end)
end

function AnimatedComponent:willUpdate(nextProps)
	local values = nextProps.values
	local options = nextProps.options

	local valuesChanged = values ~= self.props.values
	local optionsChanged = options ~= self.props.options

	if valuesChanged or optionsChanged then
		local goals = {}
		for key, targetValue in pairs(values) do
			goals[key] = Otter.spring(targetValue, options)
		end
		self.motor:setGoal(goals)
	end
end

function AnimatedComponent:render()
	local values = self.state.values
	return self.props.render(values)
end

function AnimatedComponent:willUnmount()
	if self.motor then
		self.motor:destroy()
		self.motor = nil
	end
end

return function(goals, callback, options)
	return Roact.createElement(AnimatedComponent, {
		values = goals,
		options = options,
		render = callback,
	})
end
