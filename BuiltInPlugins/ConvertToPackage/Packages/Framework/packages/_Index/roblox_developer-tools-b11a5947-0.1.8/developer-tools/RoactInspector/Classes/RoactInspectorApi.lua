--[[
	The RoactInspectorApi class manages the interface used by the inspector to discover and get
	notified of changes to the Roact tree it is attached to.
]]
local Source = script.Parent.Parent.Parent

local EventName = require(Source.EventName)
local TargetApi = require(Source.Classes.TargetApi)

local RoactInspectorApi = TargetApi:extend("RoactInspectorApi")

type Path = Types.Array<any>

function RoactInspectorApi:_init()
	self.profileComponentsPageIndex = 1
	self.profileComponentsPageSize = 1
	self.profileEventsPageIndex = 1
	self.profileEventsPageSize = 1
end

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
	self:_connect({
		eventName = EventName.RoactInspector.ShowProfileData,
		onEvent = function(message)
			self.handlers.onUpdateProfileData(message.data)
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

function RoactInspectorApi:openPath(path: Path)
	self:_send({
		eventName = EventName.RoactInspector.OpenPath,
		path = path,
	})
end

function RoactInspectorApi:setProfiling(isProfiling: boolean)
	if isProfiling then
		local thread
		thread = coroutine.wrap(function()
			while thread == self.profileThread do
				self:getProfileData()
				wait(0.5)
			end
		end)
		self.profileThread = thread
		thread()
	else
		self.profileThread = nil
	end
	self:_send({
		eventName = EventName.RoactInspector.SetProfiling,
		isProfiling = isProfiling
	})
end

function RoactInspectorApi:clearProfileData()
	self:_send({
		eventName = EventName.RoactInspector.ClearProfileData,
	})
end

function RoactInspectorApi:sortProfileData(tableName: string, index: number, order: Enum.SortDirection)
	self:_send({
		eventName = EventName.RoactInspector.SortProfileData,
		tableName = tableName,
		index = index,
		order = order,
	})
end

function RoactInspectorApi:selectProfileInstance(instanceId: string)
	self:_send({
		eventName = EventName.RoactInspector.SelectProfileInstance,
		instanceId = instanceId,
	})
end

function RoactInspectorApi:setProfileFilter(filter: Types.Array<string>)
	self:_send({
		eventName = EventName.RoactInspector.SetProfileFilter,
		filter = filter,
	})
end

function RoactInspectorApi:setProfileSearchTerm(searchTerm: string)
	self:_send({
		eventName = EventName.RoactInspector.SetProfileSearchTerm,
		searchTerm = searchTerm,
	})
end

function RoactInspectorApi:selectProfileInstance(instanceId: string)
	self:_send({
		eventName = EventName.RoactInspector.SelectProfileInstance,
		instanceId = instanceId,
	})
end

function RoactInspectorApi:setProfileComponentsPageIndex(pageIndex: number)
	self.profileComponentsPageIndex = pageIndex
end

function RoactInspectorApi:setProfileComponentsPageSize(pageSize: number)
	self.profileComponentsPageSize = pageSize
end

function RoactInspectorApi:setProfileEventsPageIndex(pageIndex: number)
	self.profileEventsPageIndex = pageIndex
end

function RoactInspectorApi:setProfileEventsPageSize(pageSize: number)
	self.profileEventsPageSize = pageSize
end

function RoactInspectorApi:getProfileData()
	local componentSliceStart = (self.profileComponentsPageIndex - 1) * self.profileComponentsPageSize + 1
	local componentSliceEnd = componentSliceStart + self.profileComponentsPageSize - 1
	local eventSliceStart = (self.profileEventsPageIndex - 1) * self.profileEventsPageSize + 1
	local eventSliceEnd = eventSliceStart + self.profileEventsPageSize - 1
	self:_send({
		eventName = EventName.RoactInspector.GetProfileData,
		componentSliceStart = componentSliceStart,
		componentSliceEnd = componentSliceEnd,
		eventSliceStart = eventSliceStart,
		eventSliceEnd = eventSliceEnd,
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
