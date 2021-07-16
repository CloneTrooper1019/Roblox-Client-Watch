--[[
	The RoactTreeWatcher class walks a roact tree and watches for any changes to the nodes.
]]
local Source = script.Parent.Parent.Parent
local Packages = Source.Parent
local getSymbol = require(Source.RoactInspector.Utils.getSymbol)
local getChildAtKey = require(Source.RoactInspector.Utils.getChildAtKey)

local Dash = require(Packages.Dash)
local Types = Dash.Types
local append = Dash.append
local class = Dash.class
local collectArray = Dash.collectArray
local pick = Dash.pick
local keys = Dash.keys
local last = Dash.last
local map = Dash.map
local mapOne = Dash.mapOne
local reduce = Dash.reduce
local reverse = Dash.reverse
local slice = Dash.slice

local insert = table.insert

type Path = Types.Array<any>

local RoactTreeWatcher = class("RoactTreeWatcher", function(debugInterface, tree, onPathChanged)
	return {
		debugInterface = debugInterface,
		tree = tree,
		onPathChanged = onPathChanged,
		cachedRoot = {
			branchData = {},
			childNodes = {}
		}
	}
end)

local POLL_DELAY = 0.25

function RoactTreeWatcher:_init()
	-- A periodic check for changes
	self.onPoll = function()
		if self.tree then
			self:_checkNodes()
			delay(POLL_DELAY, self.onPoll)
		end
	end
end

function RoactTreeWatcher:getRootNode()
	return getSymbol(self.tree, "InternalData").rootNode
end

-- Start polling for changes
function RoactTreeWatcher:monitor()
	spawn(self.onPoll)
end

function RoactTreeWatcher:_checkNodes()
	local root = self:getRootNode()
	self:_checkNode(root, self.cachedRoot, {})
end

function RoactTreeWatcher:_checkNode(node, cachedNode, path)
	local branch = self:_getBranchNodes(node)
	local updatedIndexes = collectArray(branch, function(index, branchNode)
		local nodeData = cachedNode.branchData[index]
		local container = branchNode.instance or branchNode.currentElement
		if not nodeData or container.props ~= nodeData.props or container.state ~= nodeData.state then
			cachedNode.branchData[index] = {
				props = container.props,
				state = container.state
			}
			return index
		end
	end)
	if #updatedIndexes > 0 then
		self.onPathChanged(path, updatedIndexes)
	end
	local hostNode = self:getHostNode(node)
	cachedNode.childNodes = pick(cachedNode.childNodes, function(cachedChildNode, key)
		local childPath = append({}, path, {key})
		local childNode = getChildAtKey(hostNode.children, key)
		if childNode then
			self:_checkNode(childNode, cachedChildNode, childPath)
			return true
		else
			-- The node has been removed
			return false
		end
	end)
end

function RoactTreeWatcher:getNode(path: Path)
	local root = self:getRootNode()
	local hostNode = self:getHostNode(root)
	-- Walk down the node tree by the path provided
	return reduce(path, function(node, key: any)
		if node and node.children then
			local childNode = getChildAtKey(node.children, key)
			return childNode and self:getHostNode(childNode) or nil
		else
			return nil
		end
	end, hostNode)
end

function RoactTreeWatcher:watchPath(path: Path)
	local node = self:getRootNode()
	-- Store references to the current nodes in the tree in a nested structure keyed by the path.
	-- If the data in these nodes change reference value in the source tree, we know that they
	-- have been updated and re-rendered.
	local cachedNode = self.cachedRoot
	cachedNode.branchData = self:_getBranchData(node)
	reduce(path, function(currentNode, key: any)
		if not currentNode then
			return nil
		end
		cachedNode.childNodes[key] = cachedNode.childNodes[key] or {
			childNodes = {}
		}
		cachedNode = cachedNode.childNodes[key]
		local childNode = getChildAtKey(currentNode.children, key)
		if not childNode then
			return nil
		end
		cachedNode.branchData = self:_getBranchData(childNode)
		return self:getHostNode(childNode)
	end, self:getHostNode(node))
end

function RoactTreeWatcher:_getBranchData(topNode)
	local branch = self:_getBranchNodes(topNode)
	return map(branch, function(node)
		local container = node.instance or node.currentElement
		return {
			props = container.props,
			state = container.state
		}
	end)
end

function RoactTreeWatcher:getChildren(path: Path, node, depth: number)
	-- Return nil to indicate the tree has been truncated, rather that there are 0 children.
	if depth == 0 then
		return nil
	end
	local hostNode  = self:getHostNode(node)
	if not hostNode then
		return nil
	end
	local children = map(hostNode.children, function(child, key)
		local childPath = append({}, path, {key})
		local hostObject = self:getHostNode(child).hostObject
		local icon = hostObject and hostObject.ClassName or "Branch"
		return {
			Name = typeof(key) == "number" and key or tostring(key),
			Icon = icon,
			Children = self:getChildren(childPath, child, depth - 1),
			Path = childPath
		}
	end)
	return children
end

-- Head to the bottom of the current branch, optionally moving through any fragments or portals.
function RoactTreeWatcher:getHostNode(node, jumpBranch: boolean?)
	local child = getSymbol(node.children, "UseParentKey")
	while child do
		node = child
		child = getSymbol(node.children, "UseParentKey")
		-- If node isn't in branch, try jumping to the next one
		if not child and jumpBranch then
			if self:isFragment(node) then
				child = node.children[1]
			elseif self:isPortal(node) then
				child = mapOne(node.children)
			end
		end
	end
	return node
end

function RoactTreeWatcher:getRootPath()
	local node = self:getRootNode()
	local child = getSymbol(node.children, "UseParentKey")
	local path = {}
	while child do
		node = child
		child = getSymbol(node.children, "UseParentKey")
		-- If node isn't in branch, try jumping to the next one
		if not child then
			if self:isFragment(node) then
				child = node.children[1]
				insert(path, 1)
			elseif self:isPortal(node) then
				local childKeys = keys(node.children)
				insert(path, childKeys[1])
				child = node.children[childKeys[1]]
			end
		end
	end
	return slice(path, 0, -1)
end

function RoactTreeWatcher:isFragment(node)
	return node.currentElement and node.currentElement.elements
end

function RoactTreeWatcher:isPortal(node)
	return node.currentElement and tostring(node.currentElement.component) == "Symbol(Portal)"
end

function RoactTreeWatcher:isFunction(node)
	return node.currentElement and typeof(node.currentElement.component) == "function"
end

function RoactTreeWatcher:isHost(node)
	return node.currentElement and typeof(node.currentElement.component) == "string"
end

function RoactTreeWatcher:getNodes(path: Path)
	-- Split last key off from path
	local frontPath = slice(path, 1, -1)
	local lastKey = last(path)
	-- Get the parent of the path provided
	local node = self:getNode(frontPath)
	if not node then
		return nil
	end
	local currentChild = getChildAtKey(node.children, lastKey)
	return self:_getBranchNodes(currentChild)
end

function RoactTreeWatcher:_getBranchNodes(node)
	-- Build up the node branch by walking through elements which use the parent key
	local branch = {}
	while node do
		insert(branch, node)
		node = getSymbol(node.children, "UseParentKey")
	end
	return branch
end

function RoactTreeWatcher:getNodeName(node)
	if self:isFragment(node) then
		return "Fragment"
	elseif self:isPortal(node) then
		return "Portal"
	elseif self:isFunction(node) then
		return tostring(node.currentElement.component)
	elseif self:isHost(node) then
		return node.currentElement.component
	else
		return node.currentElement.component.__componentName
	end
end

function RoactTreeWatcher:getNodeIcon(node)
	if self:isFragment(node) then
		return "Fragment"
	elseif self:isPortal(node) then
		return "Portal"
	elseif self:isFunction(node) then
		return "Functional"
	elseif self:isHost(node) then
		return node.hostObject.ClassName
	else
		local componentName = node.currentElement.component.__componentName
		if componentName:find("Provider") then
			return "Provider"
		elseif componentName:find("Consumer") or componentName:find("RoduxConnection") then
			return "Consumer"
		elseif node.currentElement.component.shouldUpdate then
			return "Pure"
		else
			return "Stateful"
		end
	end
end

function RoactTreeWatcher:getPath(instance: Instance)
	local instancePath = self:_getInstancePath(instance)
	local fullPath = self:_getFullPath(instancePath)
	return fullPath
end

function RoactTreeWatcher:_getInstancePath(instance: Instance)
	local reversePath = {}
	while instance and instance ~= self.debugInterface.rootInstance do
		-- Always prefer a number if there is a representation, as it is easier to convert back
		-- later on if need be.
		local numberName = tonumber(instance.Name)
		insert(reversePath, numberName or instance.Name)
		instance = instance.Parent
	end
	local fullPath = append({}, self.debugInterface.rootPath or self:getRootPath(), reverse(reversePath))
	if self.debugInterface.rootPrefix then
		-- Remove the prefix from the computed path
		local strippedPath = slice(fullPath, #self.debugInterface.rootPrefix + 1)
		return strippedPath
	else
		return fullPath
	end
end

-- Returns the full path including virutal nodes given a path
-- that includes only the nodes with Roblox Instances
function RoactTreeWatcher:_getFullPath(instancePath: Path)
	local fullPath = {}
	local root = self:getRootNode()
	local hostNode = self:getHostNode(root)

	local found = reduce(instancePath, function(node, key: any)
		return self:_dfsFindNextChildNode(node, key, fullPath)
	end, hostNode)

	if found ~= nil then
		return fullPath
	else
		return instancePath
	end
end

function RoactTreeWatcher:_dfsFindNextChildNode(node, key: any, fullPath: Path)
	if node == nil or node.children == nil then
		return nil
	end

	local childNode = getChildAtKey(node.children, key)
	if childNode then
		local hostNode = self:getHostNode(childNode)
		if hostNode ~= nil then
			insert(fullPath, key)
			return hostNode
		end
	end

	for childKey, childNode in pairs(node.children) do
		local useParentKey = tostring(childKey) == "Symbol(UseParentKey)"
		if not useParentKey then
			insert(fullPath, childKey)
		end
		local found = self:_dfsFindNextChildNode(childNode, key, fullPath)
		if found ~= nil then
			return found
		end
		if not useParentKey then
			table.remove(fullPath)
		end
	end
end

function RoactTreeWatcher:destroy()
	self.tree = nil
end

return RoactTreeWatcher
