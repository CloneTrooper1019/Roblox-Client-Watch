--[[
	Represents the state relevant while executing a test plan.

	Used by TestRunner to produce a TestResults object.

	Uses the same tree building structure as TestPlanBuilder; TestSession keeps
	track of a stack of nodes that represent the current path through the tree.
]]

local TestEnum = require(script.Parent.TestEnum)
local TestResults = require(script.Parent.TestResults)

local TestSession = {}

TestSession.__index = TestSession

--[[
	Create a TestSession related to the given TestPlan.

	The resulting TestResults object will be linked to this TestPlan.
]]
function TestSession.new(plan)
	local self = {
		results = TestResults.new(plan),
		nodeStack = {},
		hasFocusNodes = false
	}

	setmetatable(self, TestSession)

	return self
end

--[[
	Calculate success, failure, and skipped test counts in the tree at the
	current point in the execution.
]]
function TestSession:calculateTotals()
	local results = self.results

	results.successCount = 0
	results.failureCount = 0
	results.skippedCount = 0

	results:visitAllNodes(function(node)
		local status = node.status
		local nodeType = node.planNode.type

		if nodeType == TestEnum.NodeType.It then
			if status == TestEnum.TestStatus.Success then
				results.successCount = results.successCount + 1
			elseif status == TestEnum.TestStatus.Failure then
				results.failureCount = results.failureCount + 1
			elseif status == TestEnum.TestStatus.Skipped then
				results.skippedCount = results.skippedCount + 1
			end
		end
	end)
end

--[[
	Gathers all of the errors reported by tests and puts them at the top level
	of the TestResults object.
]]
function TestSession:gatherErrors()
	local results = self.results

	results.errors = {}

	results:visitAllNodes(function(node)
		if #node.errors > 0 then
			for _, message in ipairs(node.errors) do
				table.insert(results.errors, message)
			end
		end
	end)
end

--[[
	Calculates test totals, verifies the tree is valid, and returns results.
]]
function TestSession:finalize()
	if #self.nodeStack ~= 0 then
		error("Cannot finalize TestResults with nodes still on the stack!", 2)
	end

	self:calculateTotals()
	self:gatherErrors()

	return self.results
end

--[[
	Create a new test result node and push it onto the navigation stack.
]]
function TestSession:pushNode(planNode)
	local node = TestResults.createNode(planNode)

	local lastNode = self.nodeStack[#self.nodeStack] or self.results

	table.insert(lastNode.children, node)
	table.insert(self.nodeStack, node)

	return node
end

--[[
	Pops a node off of the navigation stack.
]]
function TestSession:popNode()
	assert(#self.nodeStack > 0, "Tried to pop from an empty node stack!")
	return table.remove(self.nodeStack, #self.nodeStack)
end

--[[
	Tells whether the current test we're in should be skipped.
]]
function TestSession:shouldSkip()
	-- If our test tree had any exclusive tests, then normal tests are skipped!
	if self.hasFocusNodes then
		for i = #self.nodeStack, 1, -1 do
			local node = self.nodeStack[i]

			-- Skipped tests are still skipped
			if node.planNode.modifier == TestEnum.NodeModifier.Skip then
				return true
			end

			-- Focused tests are the only ones that aren't skipped
			if node.planNode.modifier == TestEnum.NodeModifier.Focus then
				return false
			end
		end

		return true
	else
		for i = #self.nodeStack, 1, -1 do
			local node = self.nodeStack[i]

			if node.planNode.modifier == TestEnum.NodeModifier.Skip then
				return true
			end
		end
	end

	return false
end

return TestSession