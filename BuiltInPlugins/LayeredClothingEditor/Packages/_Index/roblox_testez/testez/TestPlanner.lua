--[[
	Turns a series of specification functions into a test plan.

	Uses a TestPlanBuilder to keep track of the state of the tree being built.
]]

local TestEnum = require(script.Parent.TestEnum)
local TestPlanBuilder = require(script.Parent.TestPlanBuilder)

local TestPlanner = {}

local function buildPlan(builder, module, env)
	local currentEnv = getfenv(module.method)

	for key, value in pairs(env) do
		currentEnv[key] = value
	end

	local nodeCount = #module.path

	-- Dive into auto-named nodes for this module
	for i = nodeCount, 1, -1 do
		local name = module.path[i]
		builder:pushNode(name, TestEnum.NodeType.Describe)
	end

	local ok, err = xpcall(module.method, function(err)
		return err .. "\n" .. debug.traceback()
	end)

	-- This is an error outside of any describe/it blocks.
	-- We attach it to the node we generate automatically per-file.
	if not ok then
		local node = builder:getCurrentNode()
		node.loadError = err
	end

	-- Back out of auto-named nodes
	for _ = 1, nodeCount do
		builder:popNode()
	end
end

--[[
	Create a new environment with functions for defining the test plan structure
	using the given TestPlanBuilder.

	These functions illustrate the advantage of the stack-style tree navigation
	as state doesn't need to be passed around between functions or explicitly
	global.
]]
function TestPlanner.createEnvironment(builder, extraEnvironment)
	local env = {}

	if extraEnvironment then
		if type(extraEnvironment) ~= "table" then
			error(("Bad argument #2 to TestPlanner.createEnvironment. Expected table, got %s"):format(
				typeof(extraEnvironment)), 2)
		end

		for key, value in pairs(extraEnvironment) do
			env[key] = value
		end
	end

	function env.describeFOCUS(phrase, callback)
		return env.describe(phrase, callback, TestEnum.NodeModifier.Focus)
	end

	function env.describeSKIP(phrase, callback)
		return env.describe(phrase, callback, TestEnum.NodeModifier.Skip)
	end

	function env.describe(phrase, callback, nodeModifier)
		local node = builder:pushNode(phrase, TestEnum.NodeType.Describe, nodeModifier)

		local ok, err = pcall(callback)

		-- loadError on a TestPlan node is an automatic failure
		if not ok then
			node.loadError = err
		end

		builder:popNode()
	end

	function env.try(phrase, callback)
		local node = builder:pushNode(phrase, TestEnum.NodeType.Try)

		local ok, err = pcall(callback)

		-- loadError on a TestPlan node is an automatic failure
		if not ok then
			node.loadError = err
		end

		builder:popNode()
	end

	function env.it(phrase, callback)
		local node = builder:pushNode(phrase, TestEnum.NodeType.It)

		node.callback = callback

		builder:popNode()
	end

	-- Incrementing counter used to ensure that beforeAll, afterAll, beforeEach, afterEach have unique phrases
	local lifecyclePhaseId = 0

	local lifecycleHooks = {
		[TestEnum.NodeType.BeforeAll] = "beforeAll",
		[TestEnum.NodeType.AfterAll] = "afterAll",
		[TestEnum.NodeType.BeforeEach] = "beforeEach",
		[TestEnum.NodeType.AfterEach] = "afterEach"
	}

	for nodeType, name in pairs(lifecycleHooks) do
		env[name] = function(callback)
			local node = builder:pushNode(name .. "_" .. tostring(lifecyclePhaseId), nodeType)
			lifecyclePhaseId = lifecyclePhaseId + 1

			node.callback = callback

			builder:popNode()
		end
	end

	function env.itFOCUS(phrase, callback)
		local node = builder:pushNode(phrase, TestEnum.NodeType.It, TestEnum.NodeModifier.Focus)

		node.callback = callback

		builder:popNode()
	end

	function env.itSKIP(phrase, callback)
		local node = builder:pushNode(phrase, TestEnum.NodeType.It, TestEnum.NodeModifier.Skip)

		node.callback = callback

		builder:popNode()
	end

	function env.itFIXME(phrase, callback)
		local node = builder:pushNode(phrase, TestEnum.NodeType.It, TestEnum.NodeModifier.Skip)

		warn("FIXME: broken test", node:getFullName())
		node.callback = callback

		builder:popNode()
	end

	function env.FIXME(optionalMessage)
		local currentNode = builder:getCurrentNode()
		warn("FIXME: broken test", currentNode:getFullName(), optionalMessage or "")

		currentNode.modifier = TestEnum.NodeModifier.Skip
	end

	function env.FOCUS()
		local currentNode = builder:getCurrentNode()

		currentNode.modifier = TestEnum.NodeModifier.Focus
	end

	function env.SKIP()
		local currentNode = builder:getCurrentNode()

		currentNode.modifier = TestEnum.NodeModifier.Skip
	end

	--[[
		These method is intended to disable the use of xpcall when running
		nodes contained in the same node that this function is called in.
		This is because xpcall breaks badly if the method passed yields.

		This function is intended to be hideous and seldom called.

		Once xpcall is able to yield, this function is obsolete.
	]]
	function env.HACK_NO_XPCALL()
		local currentNode = builder:getCurrentNode()

		currentNode.HACK_NO_XPCALL = true
	end

	env.step = env.it

	env.fit = env.itFOCUS
	env.xit = env.itSKIP
	env.fdescribe = env.describeFOCUS
	env.xdescribe = env.describeSKIP

	function env.include(...)
		local args = {...}
		local method, path
		if #args == 1 then
			method = args[1]
			path = {}
		elseif #args == 2 then
			method = args[2]
			path = {args[1]}
		end
		buildPlan(builder, {path = path, method = method}, env)
	end

	return env
end

--[[
	Create a new TestPlan from a list of specification functions.

	These functions should call a combination of `describe` and `it` (and their
	variants), which will be turned into a test plan to be executed.
]]
function TestPlanner.createPlan(specFunctions, noXpcallByDefault, testNamePattern, extraEnvironment)
	local builder = TestPlanBuilder.new()
	builder.noXpcallByDefault = noXpcallByDefault
	builder.testNamePattern = testNamePattern
	local env = TestPlanner.createEnvironment(builder, extraEnvironment)

	for _, module in ipairs(specFunctions) do
		buildPlan(builder, module, env)
	end

	return builder:finalize()
end

return TestPlanner