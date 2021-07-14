local Framework = script.Parent.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)
local Util = require(Framework.Util)
local StyleModifier = Util.StyleModifier

local ColoredSquare = Roact.PureComponent:extend("ColoredSquare")

function ColoredSquare:init()
	self.state = {
		StyleModifier = nil,
	}

	self.mouseEnter = function()
		-- By setting the StyleModifier entry in the state table,
		-- we can index into the StyleModifier subset of the current
		-- style, if it exists.
		self:setState({
			StyleModifier = StyleModifier.Hover,
		})
	end

	self.mouseLeave = function()
		self:setState({
			StyleModifier = Roact.None,
		})
	end
end

-- Note that ColoredSquare never references a Style prop.
-- The Style prop is automatically handled by the Theme system.
function ColoredSquare:render()
	local props = self.props
	local theme = props.Theme

	-- Get the values in the Theme for the ColoredSquare
	-- The "Examples" namespace matches what we defined in init
	local style = theme:getStyle("Examples", self)

	-- The style for ColoredSquare has a Color entry, so we can use it here
	local backgroundColor = style.Color

	return Roact.createElement("Frame", {
		Size = UDim2.new(0, 100, 0, 100),
		BackgroundColor3 = backgroundColor,
		Position = props.Position,

		[Roact.Event.MouseEnter] = self.mouseEnter,
		[Roact.Event.MouseLeave] = self.mouseLeave,
	})
end

ContextServices.mapToProps(ColoredSquare, {
	Theme = ContextServices.Theme,
})

return ColoredSquare
