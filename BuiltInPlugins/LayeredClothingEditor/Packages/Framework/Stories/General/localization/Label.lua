local Framework = script.Parent.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Label = Roact.PureComponent:extend("Label")

function Label:render()
	local props = self.props
	local localization = props.Localization

	local displayText = localization:getText("Example", "Hello", {
		Name = props.Name,
	})

	return Roact.createElement("TextLabel", {
		Size = UDim2.new(0, 100, 0, 60),
		Text = displayText,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
	})
end

ContextServices.mapToProps(Label, {
	Localization = ContextServices.Localization,
})

return Label
