--[[
	A Roact component that wraps its children such that they will be rendered
	on top of all other components.

	Required Props:
		Focus Focus: A Focus ContextItem, which is provided via mapToProps.

	Optional Props:
		number Priority: The ZIndex of this component relative to other focused elements.
]]

local FOCUSED_ZINDEX = 1000000

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)
local Typecheck = require(Framework.Util).Typecheck
local Util = require(Framework.Util)
local FlagsList = Util.Flags.new({
	FFlagRefactorDevFrameworkContextItems = {"RefactorDevFrameworkContextItems"},
})

local ShowOnTop = Roact.PureComponent:extend("ShowOnTop")
Typecheck.wrap(ShowOnTop, script)

function ShowOnTop:render()
	local props = self.props
	local target = FlagsList:get("FFlagRefactorDevFrameworkContextItems") and props.Focus:get() or props.Focus:getTarget()
	local priority = self.props.Priority or 0
	return Roact.createElement(Roact.Portal, {
		target = target,
	}, {
		TopLevelFrame = Roact.createElement("Frame", {
			ZIndex = priority + FOCUSED_ZINDEX,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}, self.props[Roact.Children]),
	})
end

ContextServices.mapToProps(ShowOnTop, {
	Focus = ContextServices.Focus,
})

return ShowOnTop
