--[[
	Shows the Editor setting view

	Required Props:
		UDim2 Size: size of the component frame
		number LayoutOrder: render order of component in layout
		string ToolMode: what tool is being used by the editor (Constants.TOOL_MODE enum)
	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local PointToolSettings = require(Plugin.Src.Components.PointTool.PointToolSettings)
local LatticeToolSettings = require(Plugin.Src.Components.LatticeTool.LatticeToolSettings)
local ResetSettings = require(Plugin.Src.Components.ResetSettings)

local Constants = require(Plugin.Src.Util.Constants)

local EditorSettingView = Roact.PureComponent:extend("EditorSettingView")

local Util = Framework.Util
local Typecheck = Util.Typecheck
Typecheck.wrap(EditorSettingView, script)

function EditorSettingView:render()
	local props = self.props

	local size = props.Size
	local toolMode = props.ToolMode
	local layoutOrder = props.LayoutOrder
	local theme = props.Stylizer

	return Roact.createElement("Frame", {
		BackgroundColor3 = theme.BackgroundColor,
		Size = size,
		LayoutOrder = layoutOrder,
		BorderSizePixel = 0,
		BorderColor3 = theme.BorderColor,
	}, {
		PointToolSettings = toolMode == Constants.TOOL_MODE.Point and Roact.createElement(PointToolSettings, {
			Size = UDim2.new(1, 0, 1, 0),
		}),

		LatticeToolSettings = toolMode == Constants.TOOL_MODE.Lattice and Roact.createElement(LatticeToolSettings, {
			Size = UDim2.new(1, 0, 1, 0),
		}),

		ResetSettings = toolMode == Constants.TOOL_MODE.Reset and Roact.createElement(ResetSettings, {
			Size = UDim2.new(1, 0, 1, 0),
		}),
	})
end

ContextServices.mapToProps(EditorSettingView,{
	Stylizer = ContextServices.Stylizer,
})

return EditorSettingView