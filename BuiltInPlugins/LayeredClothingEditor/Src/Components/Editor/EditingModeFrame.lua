--[[
	Frame with a text and radio button list to select Inner or Outer Cage

	Required Props:
		number LayoutOrder: render order of component in layout
		UDim2 Size: size of the frame
		table Localization: A Localization ContextItem, which is provided via mapToProps.
	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local UI = Framework.UI
local Pane = UI.Pane
local TextLabel = UI.Decoration.TextLabel

local EditingModeRadioButtonList = require(Plugin.Src.Components.Editor.EditingModeRadioButtonList)

local EditingModeFrame = Roact.PureComponent:extend("EditingModeFrame")

local Util = Framework.Util
local LayoutOrderIterator = Util.LayoutOrderIterator

local Typecheck = Util.Typecheck
Typecheck.wrap(EditingModeFrame, script)

function EditingModeFrame:render()
	local props = self.props
	local size = props.Size
	local layoutOrder = props.LayoutOrder
	local theme = props.Stylizer
	local localization = props.Localization
	local orderIterator = LayoutOrderIterator.new()
	return Roact.createElement(Pane, {
		Size = size,
		LayoutOrder = layoutOrder,
		BackgroundColor3 = theme.BackgroundColor,
		Layout = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
	}, {
		Text = Roact.createElement(TextLabel, {
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			Size = UDim2.new(theme.CageRowTextLabelSize, 0, 1, 0),
			Text = localization:getText("EditingMode", "Text") ..":",
			LayoutOrder = orderIterator:getNextOrder(),
		}),

		EditingModeRadioButtonList = Roact.createElement(EditingModeRadioButtonList, {
			LayoutOrder = orderIterator:getNextOrder(),
			Size = UDim2.new(1-theme.CageRowTextLabelSize, 0, 1, 0),
		}),
	})
end

ContextServices.mapToProps(EditingModeFrame,{
	Stylizer = ContextServices.Stylizer,
	Localization = ContextServices.Localization,
})

return EditingModeFrame
