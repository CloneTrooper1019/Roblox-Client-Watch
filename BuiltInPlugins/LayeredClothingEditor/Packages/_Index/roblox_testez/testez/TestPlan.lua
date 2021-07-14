--[[
	Represents a tree of tests that have been loaded but not necessarily
	executed yet.

	TestPlan objects are produced by TestPlanner and TestPlanBuilder.
]]

local TestEnum = require(script.Parent.TestEnum)

local TestPlan = {}

TestPlan.__index = TestPlan

--[[
	Create a new, empty TestPlan.
]]
function TestPlan.new()
	local self = {
		children = {}
	}

	setmetatable(self, TestPlan)

	return self
end

--[[
	Calls the given callback on all nodes in the tree, traversed depth-first.
]]
function TestPlan:visitAllNodes(callback, root)
	root = root or self

	for _, child in ipairs(root.children) do
		callback(child)

		self:visitAllNodes(callback, child)
	end
end

local function constructNodeFullName(node)
	if node.parent then
		local parentPhrase = constructNodeFullName(node.parent)
		if parentPhrase then
			return parentPhrase .. " " .. node.phrase
		end
	end
	return node.phrase
end

--[[
	Creates a new node that would be suitable to insert into the TestPlan.
]]
function TestPlan.createNode(phrase, nodeType, nodeModifier)
	nodeModifier = nodeModifier or TestEnum.NodeModifier.None

	local node = {
		phrase = phrase,
		type = nodeType,
		modifier = nodeModifier,
		children = {},
		callback = nil,
		getFullName = constructNodeFullName
	}

	return node
end

--[[
	Visualizes the test plan in a simple format, suitable for debugging the test
	plan's structure.
]]
function TestPlan:visualize(root, level)
	root = root or self
	level = level or 0

	local buffer = {}

	for _, child in ipairs(root.children) do
		if child.type == TestEnum.NodeType.It then
			table.insert(buffer, (" "):rep(3 * level) .. child.phrase)
		else
			table.insert(buffer, (" "):rep(3 * level) .. child.phrase)
		end

		if #child.children > 0 then
			local text = self:visualize(child, level + 1)
			table.insert(buffer, text)
		end
	end

	return table.concat(buffer, "\n")
end

--[[
	Gets a list of all nodes in the tree for which the given callback returns
	true.
]]
function TestPlan:findNodes(callback, results, node)
	node = node or self
	results = results or {}

	for _, childNode in ipairs(node.children) do
		if callback(childNode) then
			table.insert(results, childNode)
		end

		self:findNodes(callback, results, childNode)
	end

	return results
end

return TestPlan