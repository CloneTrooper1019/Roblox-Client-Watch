--[[
	A Roact component that wraps its children such that they will be rendered
	on top of all other components, and will block input to all other components.

	Required Props:
		callback OnFocusLost: A callback for when the user clicks outside of the focused element.
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

local CaptureFocus = Roact.PureComponent:extend("CaptureFocus")
Typecheck.wrap(CaptureFocus, script)

function CaptureFocus:render()
	local props = self.props
	local target = FlagsList:get("FFlagRefactorDevFrameworkContextItems") and props.Focus:get() or props.Focus:getTarget()
	local priority = props.Priority or 0
	return Roact.createElement(Roact.Portal, {
		target = target,
	}, {
		-- Consume all clicks outside the element to close it when it loses focus
		TopLevelDetector = Roact.createElement("ImageButton", {
			ZIndex = priority + FOCUSED_ZINDEX,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			[Roact.Event.Activated] = self.props.OnFocusLost,
		}, {
			-- Also block all scrolling events going through
			ScrollBlocker = Roact.createElement("ScrollingFrame", {
				Size = UDim2.new(1, 0, 1, 0),
				-- We need to have ScrollingEnabled = true for this frame for it to block
				-- But we don't want it to actually scroll, so its canvas must be same size as the frame
				ScrollingEnabled = true,
				CanvasSize = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				ScrollBarThickness = 0,
			}, self.props[Roact.Children]),
		}),
	})
end

ContextServices.mapToProps(CaptureFocus, {
	Focus = ContextServices.Focus,
})

return CaptureFocus
