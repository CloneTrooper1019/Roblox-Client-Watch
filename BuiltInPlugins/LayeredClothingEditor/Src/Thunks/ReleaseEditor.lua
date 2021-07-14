local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Packages.Cryo)

local SetPointData = require(Plugin.Src.Actions.SetPointData)
local SetOriginalPointData = require(Plugin.Src.Actions.SetOriginalPointData)
local SetAccessoryTypeInfo = require(Plugin.Src.Actions.SetAccessoryTypeInfo)
local SetAttachmentPoint = require(Plugin.Src.Actions.SetAttachmentPoint)
local SelectPreviewTab = require(Plugin.Src.Actions.SelectPreviewTab)
local SetPolyData = require(Plugin.Src.Actions.SetPolyData)
local ChangeTool = require(Plugin.Src.Thunks.ChangeTool)
local SetEditingCage = require(Plugin.Src.Actions.SetEditingCage)
local SetPast = require(Plugin.Src.Actions.SetPast)
local SetFuture = require(Plugin.Src.Actions.SetFuture)

local Constants = require(Plugin.Src.Util.Constants)
local PreviewConstants = require(Plugin.Src.Util.PreviewConstants)

local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

return function()
	return function(store)
		store:dispatch(SetAccessoryTypeInfo(Cryo.None))
		store:dispatch(SetAttachmentPoint({
			ItemCFrame = CFrame.new(),
			AttachmentCFrame = CFrame.new(),
		}))

		store:dispatch(SetPointData({}))
		store:dispatch(SetOriginalPointData({}))
		store:dispatch(SetPolyData({}))

		Selection:Set({})
		store:dispatch(SetEditingCage(Cryo.None))

		store:dispatch(SelectPreviewTab(PreviewConstants.TABS_KEYS.None))

		store:dispatch(ChangeTool(Constants.TOOL_MODE.None))

		store:dispatch(SetPast({}))
		store:dispatch(SetFuture({}))

		ChangeHistoryService:SetEnabled(true)
	end
end