--[[
	Frame for any settings related to Reset Tab.

	Required Props:
		UDim2 Size: size of the frame
	Optional Props:
		table Localization: A Localization ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		number LayoutOrder: render order of component in layout
		callback ResetPoints: Resets RbfPoint data to default, provided via mapDispatchToProps.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local UI = Framework.UI
local Button = UI.Button
local StringUtil = require(Plugin.Src.Util.StringUtil)

local AddWaypoint = require(Plugin.Src.Thunks.AddWaypoint)
local ResetPoints = require(Plugin.Src.Thunks.ResetPoints)

local Util = Framework.Util
local Typecheck = Util.Typecheck

local ResetSettings = Roact.PureComponent:extend("ResetSettings")
Typecheck.wrap(ResetSettings, script)

function ResetSettings:render()
	local props = self.props

	local size = props.Size
	local layoutOrder = props.LayoutOrder
	local editingCage = props.EditingCage
	local resetPoints = props.ResetPoints
	local localization = props.Localization
	local theme = props.Stylizer

	local text = ""
	if editingCage == Enum.CageType.Inner then
		text = localization:getText("Reset", "InnerCage")
	elseif editingCage == Enum.CageType.Outer then
		text = localization:getText("Reset", "OuterCage")
	end

	local textWidth = StringUtil.getTextWidth(text, theme.TextSize, theme.Font)

	return Roact.createElement("Frame", {
		LayoutOrder = layoutOrder,
		Size = size,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Button = Roact.createElement(Button, {
			Size = UDim2.new(0, textWidth + theme.MainPadding, 0, theme.ButtonHeight),
			Text = text,
			Style = "Round",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			OnClick = resetPoints,
		}),
	})
end

ContextServices.mapToProps(ResetSettings,{
	Localization = ContextServices.Localization,
	Stylizer = ContextServices.Stylizer,
})

local function mapStateToProps(state, props)
	local selectItem = state.selectItem
	return {
		EditingCage = selectItem.editingCage,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		ResetPoints = function()
			dispatch(AddWaypoint())
			dispatch(ResetPoints())
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(ResetSettings)