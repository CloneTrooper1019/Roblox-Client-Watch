--[[
	Represents the ephermal state used for building a TestPlan from some other
	representation.

	TestPlanBuilder keeps track of a stack of nodes that represents the current
	position in the hierarchy, allowing the consumer to move up and down the
	tree as new nodes are discovered.
]]

local TestPlan = require(script.Parent.TestPlan)
local TestEnum = require(script.Parent.TestEnum)

local TestPlanBuilder = {}

TestPlanBuilder.__index = TestPlanBuilder

--[[
	Create a new TestPlanBuilder, used for creating a TestPlan.
]]
function TestPlanBuilder.new()
	local self = {
		plan = TestPlan.new(),
		nodeStack = {},
		noXpcallByDefault = false,
		testNamePattern = nil,
	}

	setmetatable(self, TestPlanBuilder)

	return self
end

--[[
	Verify that the TestPlanBuilder's state is valid and get a TestPlan from it.
]]
function TestPlanBuilder:finalize()
	if #self.nodeStack ~= 0 then
		error("Cannot finalize a TestPlan with nodes still on the stack!", 2)
	end

	return self.plan
end

--[[
	Grab the current node being worked on by the TestPlanBuilder.
]]
function TestPlanBuilder:getCurrentNode()
	return self.nodeStack[#self.nodeStack] or self.plan
end

--[[
	Creates and pushes a node onto the navigation stack.
]]
function TestPlanBuilder:pushNode(phrase, nodeType, nodeModifier)
	local lastNode = self.nodeStack[#self.nodeStack] or self.plan

	-- Find an existing node with this phrase to use
	local useNode
	for _, child in ipairs(lastNode.children) do
		if child.phrase == phrase then
			useNode = child
			break
		end
	end

	-- Didn't find one, create a new node
	if not useNode then
		useNode = TestPlan.createNode(phrase, nodeType, nodeModifier)
		useNode.parent = lastNode

		table.insert(lastNode.children, useNode)
	end

	table.insert(self.nodeStack, useNode)

	local nodeModifierNotSet = useNode.modifier == nil or useNode.modifier == TestEnum.NodeModifier.None
	if self.testNamePattern and nodeModifierNotSet then
		local fullName = useNode:getFullName()
		if fullName:match(self.testNamePattern) then
			useNode.modifier = TestEnum.NodeModifier.Focus
		else
			useNode.modifier = TestEnum.NodeModifier.Skip
		end
	end
	useNode.HACK_NO_XPCALL = self.noXpcallByDefault

	return useNode
end

--[[
	Pops a node off of the node navigation stack.
]]
function TestPlanBuilder:popNode()
	assert(#self.nodeStack > 0, "Tried to pop from an empty node stack!")
	return table.remove(self.nodeStack, #self.nodeStack)
end

return TestPlanBuilder