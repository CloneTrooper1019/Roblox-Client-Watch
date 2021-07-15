--[[
	Main frame containing Editor/Tool components

	Props:
		UDim2 Size: size of the frame
		number LayoutOrder: render order of component in layout
		string ToolMode: Determines what tool (Point, Lattice, etc) the plugin is using. Comes from mapStateToProps
		callback ChangeTool: function to change tool, provided via mapDispatchToProps
		table Signals: A Signals ContextItem, which is provided via mapToProps.
		table Localization: A Localization ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		EnumItem EditingCage: Is the current cage being edited the Inner/Outer cage, or neither. Comes from mapStateToProps
		table PointData: Rbf point data for current cages being edited, provided via mapStateToProps.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local Pane = Framework.UI.Pane

local SignalsContext = require(Plugin.Src.Context.Signals)

local Wireframe = require(Plugin.Src.Components.ToolShared.Wireframe)
local PointTool = require(Plugin.Src.Components.PointTool.PointTool)
local LatticeTool = require(Plugin.Src.Components.LatticeTool.LatticeTool)
local MeshPartTool = require(Plugin.Src.Components.MeshPartTool)
local DraggerWrapper = require(Plugin.Src.Components.Draggers.DraggerWrapper)
local EditTransparencyView = require(Plugin.Src.Components.Editor.EditTransparencyView)
local EditingModeFrame = require(Plugin.Src.Components.Editor.EditingModeFrame)

local ChangeTool = require(Plugin.Src.Thunks.ChangeTool)

local Constants = require(Plugin.Src.Util.Constants)
local DebugFlags = require(Plugin.Src.Util.DebugFlags)

local EditorFrame = Roact.PureComponent:extend("EditorFrame")

local TabsRibbon = require(Plugin.Src.Components.Editor.EditorTabsRibbon)
local SettingView = require(Plugin.Src.Components.Editor.EditorSettingView)

local Util = Framework.Util
local LayoutOrderIterator = Util.LayoutOrderIterator

function EditorFrame:init()
	self.editorFrameRef = Roact.createRef()

	self.onToolChange = function(toolMode)
		self.props.ChangeTool(toolMode)
		self.props.Signals:get(Constants.SIGNAL_KEYS.SelectionChanged):Fire()
		self.props.Signals:get(Constants.SIGNAL_KEYS.ToolChanged):Fire()
	end
end

function EditorFrame:render()
	local props = self.props
	local toolMode = props.ToolMode
	local size = props.Size
	local editingCage = props.EditingCage
	local layoutOrder = props.LayoutOrder
	local theme = props.Stylizer
	local orderIterator = LayoutOrderIterator.new()

	local meshPartMode = editingCage == Constants.EDIT_MODE.Mesh
	local isEditing = (editingCage and not meshPartMode and props.PointData and next(props.PointData)) ~= nil

	local meshPartModeText = props.Localization:getText("Editor", "MeshPartMode")

	local isTesting = DebugFlags.RunRhodiumTests() or DebugFlags.RunTests()
	local dragger = not isTesting and isEditing and (toolMode == Constants.TOOL_MODE.Lattice or toolMode == Constants.TOOL_MODE.Point) and Roact.createElement(DraggerWrapper) or nil

	return Roact.createElement(Pane, {
		BackgroundColor3 = theme.BackgroundColor,
		Size = size,
		LayoutOrder = layoutOrder,
		Layout = Enum.FillDirection.Vertical,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Spacing = theme.MainPadding,
	}, {
		EditingModeFrame = Roact.createElement(EditingModeFrame, {
			LayoutOrder = orderIterator:getNextOrder(),
			Size = UDim2.new(1, -theme.MainPadding, 0, theme.EditingModeHeight),
		}),
		TransparencyView = Roact.createElement(EditTransparencyView, {
			LayoutOrder = orderIterator:getNextOrder(),
		}),
		TabsRibbon = not meshPartMode and Roact.createElement(TabsRibbon, {
			LayoutOrder = orderIterator:getNextOrder(),
			HasEditingCage = isEditing,
			ToolMode = toolMode,
			SetToolMode = self.onToolChange,
		}),
		MeshPartModeText = meshPartMode and Roact.createElement("TextLabel", {
			BackgroundTransparency = 1,
			Font = theme.Font,
			TextSize = theme.TextSize,
			TextColor3 = theme.TextColor,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			Size = UDim2.new(1, 0, 0, theme.Height),
			Text = meshPartModeText,
			TextWrapped = true,
			LayoutOrder = orderIterator:getNextOrder(),
		}, {
			UIPadding = Roact.createElement("UIPadding", {
				PaddingRight = UDim.new(0, theme.MainPadding),
				PaddingLeft = UDim.new(0, theme.MainPadding),
			})
		}),
		SettingView = isEditing and Roact.createElement(SettingView, {
			Size = UDim2.new(1, -theme.MainPadding, 0, theme.Height),
			ToolMode = toolMode,
			LayoutOrder = orderIterator:getNextOrder(),
		}),
		Wireframe = isEditing and Roact.createElement(Wireframe),
		PointTool = isEditing and toolMode == Constants.TOOL_MODE.Point and Roact.createElement(PointTool),
		LatticeTool = isEditing and toolMode == Constants.TOOL_MODE.Lattice and Roact.createElement(LatticeTool),
		MeshPartTool = meshPartMode and Roact.createElement(MeshPartTool),
		Dragger = dragger,
	})
end

ContextServices.mapToProps(EditorFrame,{
	Stylizer = ContextServices.Stylizer,
	Localization = ContextServices.Localization,
	Signals = SignalsContext,
})

local function mapStateToProps(state, props)
	local status = state.status
	local cageData = state.cageData
	local selectItem = state.selectItem

	return {
		ToolMode = status.toolMode,
		EditingCage = selectItem.editingCage,
		PointData = cageData.pointData
	}
end

local function mapDispatchToProps(dispatch)
	return {
		ChangeTool = function(toolMode)
			dispatch(ChangeTool(toolMode))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(EditorFrame)