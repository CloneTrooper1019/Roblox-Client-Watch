--[[
	The RoactInspectorApi class manages the interface used by the inspector to discover and get
	notified of changes to the Roact tree it is attached to.
]]
local Source = script.Parent.Parent.Parent
local Packages = Source.Parent

local EventName = require(Source.EventName)
local TargetApi = require(Source.Classes.TargetApi)

local Dash = require(Packages.Dash)
local append = Dash.append

local insert = table.insert

local RoactInspectorApi = TargetApi:extend("RoactInspectorApi")

type Path = Types.Array<any>

function RoactInspectorApi:attach(handlers)
	self.handlers = handlers
	TargetApi.attach(self)
	self:_connect({
		eventName = EventName.RoactInspector.ShowChildren,
		onEvent = function(message)
			self.handlers.onUpdateInstances(message.path, message.children, message.updatedIndexes)
		end
	})
	self:_connect({
		eventName = EventName.RoactInspector.ShowBranch,
		onEvent = function(message)
			self.handlers.onUpdateBranch(message.path, message.branch)
		end
	})
	self:_connect({
		eventName = EventName.RoactInspector.ShowFields,
		onEvent = function(message)
			self.handlers.onUpdateFields(message.path, message.nodeIndex, message.fieldPath, message.fields)
		end
	})
	self:_connect({
		eventName = EventName.RoactInspector.PickInstance,
		onEvent = function(message)
			self.handlers.onPickInstance(message.path)
		end
	})
end

function RoactInspectorApi:getChildren(path: Path)
	self:_send({
		eventName = EventName.RoactInspector.GetChildren,
		path = path
	})
end

function RoactInspectorApi:getRoot()
	self:getChildren({})
end

function RoactInspectorApi:getBranch(path: Path)
	self:_send({
		eventName = EventName.RoactInspector.GetBranch,
		path = path
	})
end

function RoactInspectorApi:getFields(path: Path, nodeIndex: number, fieldPath: Path)
	self:_send({
		eventName = EventName.RoactInspector.GetFields,
		path = path,
		nodeIndex = nodeIndex,
		fieldPath = fieldPath
	})
end

function RoactInspectorApi:setPicking(isPicking: boolean)
	self:_send({
		eventName = EventName.RoactInspector.SetPicking,
		isPicking = isPicking
	})
end

function RoactInspectorApi:highlight(path: Path)
	self:_send({
		eventName = EventName.RoactInspector.Highlight,
		path = path
	})
end

function RoactInspectorApi:dehighlight()
	self:_send({
		eventName = EventName.RoactInspector.Dehighlight,
	})
end

return RoactInspectorApi