--[[
	The RoactProfiler aggregates events from Roact components as they mount, render and update.
]]
local Source = script.Parent.Parent.Parent
local Packages = Source.Parent

local Dash = require(Packages.Dash)
local class = Dash.class
local slice = Dash.slice
local filter = Dash.filter
local forEach = Dash.forEach
local keys = Dash.keys
local some = Dash.some
local values = Dash.values

local concat = table.concat
local insert = table.insert
local sort = table.sort

local getSymbol = require(Source.RoactInspector.Utils.getSymbol)
local sanitizeRoactLog = require(Source.RoactInspector.Utils.sanitizeRoactLog)

local Types = require(Source.Types)

local RoactProfiler = class("RoactProfiler", function(debugInterface, treeWatcher, tree: Types.RoactTree, roact: Types.Roact)
	local self = {
		active = false,
		-- A list of all events recorded but not yet processed
		events = {} :: Types.Array<Types.ProfileEvent>,
		-- Events are aggregated into rows, one per instance
		rows = {} :: Types.Array<Types.ProfileComponentRow>,
		-- A map of instances to its event list
		instanceEvents = {} :: Types.Record<Types.RoactInstance, Types.ProfileEvent>,
		-- The event list of the currently selected instance
		selectedEvents = {} :: Types.Array<Types.ProfileEventRow>,
		-- Stores the depth of the current render/update event relative to the original cause
		indent = 0,
		-- The total number of events processed since profiling began
		eventCount = 0,
		-- A reference to the parent debug interface
		debugInterface = debugInterface,
		-- Stores which fns that the proxy wraps so we can unwrap it when profiling stops
		registeredFnProxies = {},
		-- Stories which components have already been assigned an id for the profiler
		registeredComponents = {},
		-- Stores a map from instance to its index, a uniquely incrementing id
		instanceIndices = {},
		-- A uniquely incrementing id for each component
		nextInstanceIndex = 1,
		-- A uniquely incrementing id for each render/mount/update event
		nextEventId = 1,
		-- A map from indent level to the current total render time of components at this indent
		renderTimes = {},
		-- An array of strings to exclude components by a name substring
		filter = {},
		-- The search term to select component names by (case insensitive)
		searchTerm = nil,
		-- The current Roact library being used
		roact = roact,
		-- A reference to the RoactTreeWatcher instance
		treeWatcher = treeWatcher,
		tree = tree,
		-- When the current event started, measured by os.clock()
		startTime = 0,
		-- The TableData for the components table
		profileComponents = {
			sortIndex = nil,
			sortOrder = nil,
			columns = {"instanceName", "depth", "count", "renderTime", "time"},
		},
		-- The TableData for the events table
		profileEvents = {
			sortIndex = nil,
			sortOrder = nil,
			columns = {"startTime", "renderTime", "time", "cause", "details"}
		},
	}

	--[[
		A function that replaces the resolveUpdate method on components while a profiler session
		is in progress. The original function is called inside measurements have been taken.
	]]
	self.resolveUpdateProxy = function(component: Types.RoactComponent, ...)
		local updateTrace = debug.traceback()
		local startTime = os.clock()
		local args = {...}
		self.indent += 1
		local oldProps = component.props
		local oldState = component.state
		local ok, result = pcall(function()
			return component:__resolveUpdateHidden(unpack(args))
		end)
		if ok and result then
			local isPure = component.shouldUpdate == self.roact.PureComponent.shouldUpdate
			local stateChanged = oldState ~= component.state
			local propsChanged = oldProps ~= component.props
			local renderTime = self.renderTimes[self.indent] or 0
			local endTime = os.clock()
			insert(self.events, {
				instance = component,
				depth = self.indent,
				renderTime = renderTime,
				startTime = startTime,
				endTime = endTime,
				updateTrace = updateTrace,
				isPure = isPure,
				oldState = stateChanged and oldState or nil,
				newState = stateChanged and component.state or nil,
				oldProps = propsChanged and oldProps or nil,
				newProps = propsChanged and component.props or nil,
			})
		end
		self.renderTimes[self.indent] = nil
		self.indent -= 1
		if not ok then
			warn("Update error during profiling", result)
		end
		return result
	end
	
	--[[
		A function that replaces the mount method on components while a profiler session
		is in progress. The original function is called inside measurements have been taken.
	]]
	self.mountProxy = function(component: Types.RoactComponent, ...)
		local startTime = os.clock()
		local updateTrace = debug.traceback()
		local args = {...}
		self.indent += 1
		local ok, result = pcall(function()
			return component:__mountHidden(unpack(args))
		end)
		if ok then
			local renderTime = self.renderTimes[self.indent] or 0
			local endTime = os.clock()
			insert(self.events, {
				depth = self.indent,
				instance = component,
				renderTime = renderTime,
				startTime = startTime,
				endTime = endTime,
				isMount = true,
				updateTrace = updateTrace,
			})
		end
		self.renderTimes[self.indent] = nil
		self.indent -= 1
		if not ok then
			warn("Mount error during profiling", result)
			return false
		end
		return result
	end
	
	--[[
		A function that replaces the render method on components while a profiler session
		is in progress. The original function is called inside measurements have been taken.
	]]
	self.renderProxy = function(component: Types.RoactComponent, ...)
		local startTime = os.clock()
		local args = {...}
		local ok, result = pcall(function()
			return component:__renderHidden(unpack(args))
		end)
		if ok then
			local renderTime = (os.clock() - startTime) * 1000
			local prevTime = self.renderTimes[self.indent] or 0
			self.renderTimes[self.indent] = prevTime + renderTime
		end
		if not ok then
			warn("Render error during profiling", result)
			return false
		end
		return result
	end
	

	return self
end)

function RoactProfiler:getRootNode()
	return getSymbol(self.tree, "InternalData").rootNode
end

--[[
	Store the sort request from the inspector plugin for future use when the data is re-fetched.
]]
function RoactProfiler:sortData(tableName: string, index: number, order: Enum.SortDirection)
	self[tableName].sortIndex = index
	self[tableName].sortOrder = order
end

--[[
	Return specific slices of the component & event rows for their respective tables.
]]
function RoactProfiler:getData(componentSliceStart: number, componentSliceEnd: number, eventSliceStart: number, eventSliceEnd: number): Types.ProfileData
	self:updateRows()
	local componentRows = self:getComponentRows()
	local eventRows = self:getEventRows()
	local eventRowsSlice = slice(eventRows, eventSliceStart, eventSliceEnd)
	forEach(eventRowsSlice, function(event)
		-- Defer computation of the sanitized log as computing it is intensive
		if not event.log then
			event.log = sanitizeRoactLog(event.updateTrace)
		end
	end)
	return {
		componentRows = slice(componentRows, componentSliceStart, componentSliceEnd),
		eventRows = eventRowsSlice,
		rowCount = #componentRows,
		eventCount = self.eventCount,
		instanceEventCount = #self.selectedEvents
	}
end

--[[
	Process all the events we recorded live in a delayed cycle. Perform some initial computation
	on each row to establish which component it belongs too, but leave more the more complex
	stuff (such as state/props change comparison) to when the plugin requests specific rows, as
	it only displays a fraction of the data.
]]
function RoactProfiler:updateRows()
	forEach(self.events, function(event: Types.ProfileEvent)
		local instanceIndex = self.instanceIndices[event.instance]
		if not self.instanceIndices[event.instance] then
			instanceIndex = self.nextInstanceIndex
			self.instanceIndices[event.instance] = self.nextInstanceIndex
			self.nextInstanceIndex += 1
		end
		local internalData = getSymbol(event.instance, "InternalData")
		local node = internalData and internalData.virtualNode
		local hostNode = node and self.treeWatcher:getHostNode(node)
		local path = hostNode and self.treeWatcher:getPath(hostNode.hostObject)
		local instanceId = tostring(instanceIndex)
		local row: Types.ProfileRow = self.rows[instanceId] or {
			instanceId = instanceId,
			count = 0,
			depth = event.depth,
			path = path,
			pathString = path and "Path: " .. concat(path, "."),
			instanceName = event.instance.__componentName,
			time = 0,
			renderTime = 0,
		}
		self.rows[instanceId] = row
		row.count += 1
		if not self.instanceEvents[instanceId] then
			self.instanceEvents[instanceId] = {}
		end
		insert(self.instanceEvents[instanceId], self:getEventInfo(event))
		row.time += (event.endTime - event.startTime) * 1000
		row.renderTime += event.renderTime
	end, {})
	self.eventCount += #self.events
	self.events = {}
end

--[[
	Store the select request from the inspector plugin for future use when the data is re-fetched
]]
function RoactProfiler:selectInstance(instanceId: string)
	self.selectedEvents = self.instanceEvents[instanceId] or {}
end

--[[
	For the component data being recorded, filter out any excluded components & select on search
	criteria, before sorting & returning the data.
]]
function RoactProfiler:getComponentRows(): Types.Array<Types.ProfileComponentRow>
	local rowValues = values(self.rows)
	if self.filter or self.searchTerm then
		rowValues = filter(rowValues, function(row)
			if self.searchTerm and not row.instanceName:lower():find(self.searchTerm) then
				return false
			end
			return not some(self.filter, function(filterTerm: string)
				return row.instanceName:find(filterTerm)
			end)
		end)
	end
	return self:getSortedData(rowValues, self.profileComponents)
end

function RoactProfiler:getEventRows(): Types.Array<ProfileEventRow>
	return self:getSortedData(self.selectedEvents, self.profileEvents)
end

--[[
	Sort the data array that has been collected based on a particular column and order.
	TODO Luau - support generic functions
]]
function RoactProfiler:getSortedData(data: Types.Array<any>, tableSort: Types.TableSort): Types.Array<any>
	if tableSort.sortIndex then
		sort(data, function(a, b)
			local column = tableSort.columns[tableSort.sortIndex]
			if self.profileComponents.sortOrder == Enum.SortDirection.Descending then
				return a[column] < b[column]
			else
				return a[column] > b[column]
			end
		end)
	end
	return data
end

--[[
	From an event we've recorded, produce a simpler table that can be serialized and passed to the
	inspector. This method performs more of the heavy lifting than the event monitoring itself, so
	the performance times being measured are impacted as little as possible.
]]
function RoactProfiler:getEventInfo(event: Types.ProfileEvent): Types.ProfileEventInfo
	local cause = ""
	local details = ""
	local detailsTip = ""
	if event.isMount then
		cause = "Mount"
	end
	if event.oldState then
		cause = cause .. "State"
		details, detailsTip = self:getChangedKeys(event.oldState, event.newState)
	end
	if event.oldProps then
		cause = cause .. "Props"
		details, detailsTip = self:getChangedKeys(event.oldProps, event.newProps)
	end
	return {
		startTime = event.startTime - self.startTime,
		renderTime = event.renderTime,
		time = (event.endTime - event.startTime) * 1000,
		cause = cause,
		updateTrace = event.updateTrace,
		details = details,
		detailsTip = detailsTip,
	}
end

--[[
	Compare two different tables (like an old and new props table) and return:
	a) A list of the keys that are no longer equal
	b) A tooltip explaining the changes in a more detailed form
]]
function RoactProfiler:getChangedKeys(a: AnyRecord, b: AnyRecord)
	local keySet = {}
	forEach(a, function(aValue, key)
		local bValue = b[key]
		if aValue ~= bValue then
			keySet[tostring(key)] = true
		end
	end)
	forEach(b, function(bValue, key)
		local aValue = a[key]
		if bValue ~= aValue then
			keySet[tostring(key)] = true
		end
	end)
	local result = keys(keySet)
	local tip
	if #result == 0 then
		tip = "No values changed"
	else
		tip = ""
		forEach(result, function(key)
			tip = tip .. ("%s: %s -> %s\n"):format(tostring(key), tostring(a[key]), tostring(b[key]))
		end)
	end
	return concat(result, ", "), tip
end

--[[
	Reset all the profile data back to the initial state.
]]
function RoactProfiler:clearData()
	self.events = {}
	self.eventCount = 0
	self.nextInstanceIndex = 0
	self.instanceIndices = {}
	self.renderTimes = {}
	self.rows = {}
	self.instanceEvents = {}
	self.selectedEvents = {}
end

--[[
	Enable/disable if the profiler is active.
]]
function RoactProfiler:setActive(active: boolean)
	if self.active == active then
		return
	end
	self.active = active
	local root = self:getRootNode()
	if active then
		self.startTime = os.clock()
		self:start(root)
	else
		self:stop(root)
	end
end

--[[
	Find all the components in the Roact tree beneath the node and ensure they proxy any render
	or update calls through the RoactProfiler.
]]
function RoactProfiler:start(node: Types.RoactNode)
	assert(self.createElementHidden == nil, "Roact Profiler already started")
	self.createElementHidden = self.roact.createElement
	self.roact.createElement = function(component, ...)
		local proxyComponent = self:registerComponent(component)
		return self.createElementHidden(proxyComponent, ...)
	end
	self:registerNode(node)
end

--[[
	Register each component in the node's tree hierarchy.
]]
function RoactProfiler:registerNode(node: Types.RoactNode)
	local component = node.currentElement and node.currentElement.component
	self:registerComponent(component)
	forEach(node.children, function(child)
		self:registerNode(child)
	end)
end

--[[
	Check if a Roact component is registered with the profiler, and register if it isn't.
]]
function RoactProfiler:registerComponent(component: Types.RoactComponent)
	if not self.registeredComponents[component] then	
		if typeof(component) == "table" then
			self:registerComponentClass(component)
		elseif typeof(component) == "function" then
			self:registerComponentFn(component)
		else
			return component
		end
	end
	return self.registeredComponents[component]
end

function RoactProfiler:registerComponentClass(component: Types.RoactComponent)
	-- A component proxy maps to itself
	self.registeredComponents[component] = component
	component.__resolveUpdateHidden = component.__resolveUpdate
	component.__resolveUpdate = self.resolveUpdateProxy
	component.__mountHidden = component.__mount
	component.__mount = self.mountProxy
	component.__renderHidden = component.render
	component.render = self.renderProxy
end

function RoactProfiler:registerComponentFn(fn)
	-- A function component maps to a wrapping proxy fn
	local function fnProxy(...)
		local startTime = os.clock()
		local args = {...}
		local ok, result = pcall(function()
			return fn(unpack(args))
		end)
		if not ok then
			warn("Render fn error during profiling", result)
			return false
		end
		local renderTime = (os.clock() - startTime) * 1000
		local prevTime = self.renderTimes[self.indent] or 0
		self.renderTimes[self.indent] = prevTime + renderTime
		return result
	end
	self.registeredComponents[fn] = fnProxy
	-- Also register the proxy, in case the target tree obtained a reference to it
	self.registeredComponents[fnProxy] = fnProxy
	-- Store which fn the proxy wraps so we can unwrap it when profiling stops
	self.registeredFnProxies[fnProxy] = fn
end

--[[
	Store the setFilter request from the inspector plugin for future use when the data is re-fetched.
]]
function RoactProfiler:setFilter(filter: Types.Array<string>)
	self.filter = filter
end

function RoactProfiler:setSearchTerm(searchTerm: string)
	-- Perform case insensitive search
	self.searchTerm = searchTerm:lower()
end

--[[
	Find all the components in the Roact tree beneath the node and ensure any proxy fns are
	removed so they no longer track events.
]]
function RoactProfiler:stop(node: Types.RoactNode)
	self.roact.createElement = self.createElementHidden
	self.createElementHidden = nil
	forEach(self.registeredComponents, function(_true, component)
		if typeof(component) == "table" then
			component.__mount = component.__mountHidden
			component.__mountHidden = nil
			component.__resolveUpdate = component.__resolveUpdateHidden
			component.__resolveUpdateHidden = nil
			component.render = component.__renderHidden
			component.__renderHidden = nil
		end
	end)
	self:unregisterNode(node)
	self.registeredComponents = {}
	self.registeredFnProxies = {}
	self.componentIds = {}
end

function RoactProfiler:unregisterNode(node: Types.RoactNode)
	local component = node.currentElement and node.currentElement.component
	if self.registeredFnProxies[component] then
		-- Map each proxy fn back to its original
		node.currentElement.component = self.registeredFnProxies[component]
	end
	forEach(node.children, function(child)
		self:unregisterNode(child)
	end)
end

return RoactProfiler
