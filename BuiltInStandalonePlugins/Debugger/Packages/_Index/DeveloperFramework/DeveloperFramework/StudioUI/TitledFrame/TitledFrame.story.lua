local Framework = script.Parent.Parent.Parent
local ContextServices = require(Framework.ContextServices)
local Roact = require(Framework.Parent.Roact)
local StudioUI = require(Framework.StudioUI)
local TitledFrame = StudioUI.TitledFrame

local Util = require(Framework.Util)
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local Example = Roact.PureComponent:extend("StyledDialogExample")

function Example:render()
	return Roact.createElement(TitledFrame, {
		Title = "Title",
		LayoutOrder = 1,
	}, {
		Child = Roact.createElement("TextLabel", {
			Text = "Child component",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 12,
			Size = UDim2.fromOffset(150, 24)
		}),
	})
end

ContextServices.mapToProps(Example, {
	Plugin = ContextServices.Plugin,
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return Example