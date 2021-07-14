--[[
	Frame for any settings related to Point Tool

	Props:
		UDim2 Size = size of the frame
		number LayoutOrder = render order of component in layout
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local SliderSetting = require(Plugin.Src.Components.SliderSetting)

local SetFalloff = require(Plugin.Src.Actions.SetFalloff)
local SoftSelectRbfPoints = require(Plugin.Src.Thunks.SoftSelectRbfPoints)

local Constants = require(Plugin.Src.Util.Constants)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local UI = Framework.UI
local Pane = UI.Pane

local PointToolSettings = Roact.PureComponent:extend("PointToolSettings")

function PointToolSettings:render()
	local props = self.props

	local falloff = props.Falloff
	local size = props.Size
	local layoutOrder = props.LayoutOrder
	local setFalloff = props.SetFalloff

	local localization = props.Localization

	local theme = props.Stylizer

	return Roact.createElement(Pane, {
		LayoutOrder = layoutOrder,
		Size = size,
		Layout = Enum.FillDirection.Vertical,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = {
			Top = theme.MainPadding,
			Left = theme.MainPadding,
			Right = theme.MainPadding,
		}
	}, {
		FalloffSetting = Roact.createElement(SliderSetting, {
			Title = localization:getText("ToolSettings", "FalloffDistance"),
			Value = falloff,
			MaxValue = Constants.MAX_FALLOFF,
			SnapIncrement = 0.1,
			Size = UDim2.new(1, 0, 0, theme.SliderHeight),
			UsePercentage = false,
			LayoutOrder = 1,
			SetValue = setFalloff,
			IsDisabled = false,
		}),
	})
end

ContextServices.mapToProps(PointToolSettings,{
	Localization = ContextServices.Localization,
	Stylizer = ContextServices.Stylizer,
})

local function mapStateToProps(state, props)
	local pointTool = state.pointTool
	return {
		Falloff = pointTool.falloff,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		SetFalloff = function(falloff)
			dispatch(SetFalloff(falloff))
			dispatch(SoftSelectRbfPoints())
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(PointToolSettings)