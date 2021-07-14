--[[
	Renders the DraggerToolComponent from the DraggerFramework.

	Props:
		Mouse Mouse: PluginMouse object.
		Enum DraggerType: What dragger should be displayed (translation/rotation/scale)
		table DraggerContext: DraggerContext object created via DraggerContext_PluginImpl.new
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local DraggerFramework = Plugin.Packages.DraggerFramework
local DraggerToolComponent = require(DraggerFramework.DraggerTools.DraggerToolComponent)
local MoveHandles = require(DraggerFramework.Handles.MoveHandles)
local RotateHandles = require(DraggerFramework.Handles.RotateHandles)
local ExtrudeHandles = require(DraggerFramework.Handles.ExtrudeHandles)
local DraggerSchema = require(Plugin.Src.Util.DraggerSchema.DraggerSchema)

local LayeredClothingDragger = Roact.PureComponent:extend("LayeredClothingDragger")

function LayeredClothingDragger:render()
	local props = self.props

	local mouse = props.Mouse
	local draggerType = props.DraggerType
	local context = props.Context

	local handles = {}
	if draggerType == Enum.RibbonTool.Move then
		table.insert(handles, MoveHandles.new(
			context,
			nil,
			DraggerSchema.TransformHandlesImplementation.new(context)))
	elseif draggerType == Enum.RibbonTool.Scale then
		table.insert(handles, ExtrudeHandles.new(
			context,
			nil,
			DraggerSchema.ExtrudeHandlesImplementation.new(context)))
	elseif draggerType == Enum.RibbonTool.Rotate then
		table.insert(handles, RotateHandles.new(
			context,
			nil,
			DraggerSchema.TransformHandlesImplementation.new(context)))
	end

	local draggerSettings = {
		AnalyticsName = draggerType.Name,
		AllowDragSelect = true,
		AllowFreeformDrag = false,
		HandlesList = handles,
	}

	return Roact.createElement(DraggerToolComponent, {
		Mouse = mouse,
		DraggerContext = context,
		DraggerSchema = DraggerSchema,
		DraggerSettings = draggerSettings,
	})
end

return LayeredClothingDragger