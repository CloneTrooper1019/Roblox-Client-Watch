--[[
	The RoactInspectorWorker class manages the serialization of a roact tree across the bridge,
	notifies the inspector of any changes to the tree, and allows the inspector to make
	modifications to the tree.
]]
local Source = script.Parent.Parent.Parent
local Packages = Source.Parent

local getChildAtKey = require(Source.RoactInspector.Utils.getChildAtKey)

local TargetWorker = require(Source.Classes.TargetWorker)
local EventName = require(Source.EventName)
local RoactTreeWatcher = require(Source.RoactInspector.Classes.RoactTreeWatcher)
local InstancePicker = require(Source.RoactInspector.Classes.InstancePicker)
local FieldWatcher = require(Source.RoactInspector.Classes.FieldWatcher)

local Selection = game:GetService("Selection")

local Dash = require(Packages.Dash)
local Types = Dash.Types
local map = Dash.map
local forEach = Dash.forEach
local last = Dash.last
local pretty = Dash.pretty
local reduce = Dash.reduce

local insert = table.insert

type Path = Types.Array<any>

local RoactInspectorWorker = TargetWorker:extend("RoactInspectorWorker", function(debugInterface, targetId, toBridgeId, tree)
	local worker = TargetWorker.new(debugInterface, targetId, toBridgeId)
	worker.tree = tree
	return worker
end)

function RoactInspectorWorker:_init()
	self.treeWatcher = RoactTreeWatcher.new(self.debugInterface, self.tree, function(changedPath, changedIndexes)
		self:showChildren(changedPath, changedIndexes)
	end)
	self.treeWatcher:monitor()

	self.fieldWatcher = FieldWatcher.new(function(changedPaths)
		self:showFields({})
	end)

	self.picker = InstancePicker.new(self.debugInterface, function(instance)
		return self:pickInstance(instance)
	end)

	self:connectEvents()
end

function RoactInspectorWorker:connectEvents()
	TargetWorker.connectEvents(self)
	self:connect({
		eventName = EventName.RoactInspector.GetChildren,
		onEvent = function(message)
			self:showChildren(message.path)
		end
	})
	self:connect({
		eventName = EventName.RoactInspector.GetBranch,
		onEvent = function(message)
			self:showBranch(message.path)
		end
	})
	self:connect({
		eventName = EventName.RoactInspector.GetFields,
		onEvent = function(message)
			self.currentPath = message.path
			self.currentNodeIndex = message.nodeIndex
			self:showFields(message.fieldPath or {})
		end
	})
	self:connect({
		eventName = EventName.RoactInspector.Highlight,
		onEvent = function(message)
			local node = self.treeWatcher:getNode(message.path)
			if not node then
				return
			end
			local hostNode = self.treeWatcher:getHostNode(node)
			if hostNode and hostNode.hostObject then
				self.picker:highlight(hostNode.hostObject)
			else
				self.picker:dehighlight()
			end
		end
	})
	self:connect({
		eventName = EventName.RoactInspector.Dehighlight,
		onEvent = function(message)
			self.picker:dehighlight()
		end
	})
	self:connect({
		eventName = EventName.RoactInspector.SetPicking,
		onEvent = function(message)
			self.picker:setActive(message.isPicking)
		end
	})
end

function RoactInspectorWorker:getNodeInfo(node)
	local source = ""
	local link = ""
	if node.currentElement.source then
		local lines = node.currentElement.source:split("\n")
		if lines[1] then
			source = lines[1]
			link = lines[1]:match("[A-Za-z0-9_]+%.[A-Za-z0-9_]+:[0-9]+") or ""
		end
	end
	return {
		Name = self.treeWatcher:getNodeName(node),
		Source = source,
		Link = link,
		Icon = self.treeWatcher:getNodeIcon(node)
	}
end

function RoactInspectorWorker:pickInstance(instance: Instance)
	self.picker:setActive(false)

	local path = self.treeWatcher:getPath(instance)
	local currentPath = {}

	-- Gather all the children for these instances and update
	forEach(path, function(key)
		insert(currentPath, key)
		self:showChildren(currentPath)
	end)
	
	-- Pick the instance based on the id path to reach it
	self:send({
		eventName = EventName.RoactInspector.PickInstance,
		path = path
	})

	self:showBranch(path)
end

function RoactInspectorWorker:showChildren(path, updatedIndexes: Types.Array<number>?)
	local node = self.treeWatcher:getNode(path)
	if not node then
		warn("[DeveloperInspector - Roact] Missing path " .. pretty(path))
		return
	end
	self.treeWatcher:watchPath(path)
	-- Generate at depth two to get grandchildren, so tree rows with children
	-- display with a toggle arrow.
	local children = self.treeWatcher:getChildren(path, node, 2)
	self:send({
		eventName = EventName.RoactInspector.ShowChildren,
		path = path,
		children = children,
		updatedIndexes = updatedIndexes
	})
end

function RoactInspectorWorker:showBranch(path)
	local nodes = self.treeWatcher:getNodes(path)
	if not nodes then
		return
	end
	local hostNode = last(nodes)
	if hostNode and hostNode.hostObject then
		Selection:Set({hostNode.hostObject})
	end
	local branch = map(nodes, function(node)
		return self:getNodeInfo(node)
	end)
	self:send({
		eventName = EventName.RoactInspector.ShowBranch,
		path = path,
		branch = branch
	})
end

function RoactInspectorWorker:showFields(fieldPath: Path)
	local nodes = self.treeWatcher:getNodes(self.currentPath)
	if not nodes then
		return
	end
	local node = nodes[self.currentNodeIndex]
	if not node then
		return
	end
	local container = node.instance or node.currentElement

	self.fieldWatcher:setRoot(container)
	self.fieldWatcher:addPath(fieldPath)

	-- Safely walk through the container to the correct descendant
	local fieldRoot = reduce(fieldPath, function(table, key)
		local ok, child = pcall(function()
			return getChildAtKey(table, key)
		end)
		if ok then
			return child
		else
			return nil
		end
	end, container)

	if fieldRoot == nil then
		return
	end

	self:send({
		eventName = EventName.RoactInspector.ShowFields,
		path = self.currentPath,
		nodeIndex = self.currentNodeIndex,
		fieldPath = fieldPath,
		fields = self.fieldWatcher:collect(fieldRoot, 2, fieldPath)
	})
end

function RoactInspectorWorker:destroy()
	TargetWorker.destroy(self)
	self.picker:destroy()
	self.treeWatcher:destroy()
	self.fieldWatcher:destroy()
	self.treeWatcher = nil
end

return RoactInspectorWorker