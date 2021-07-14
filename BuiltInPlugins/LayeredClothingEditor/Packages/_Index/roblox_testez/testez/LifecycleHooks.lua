local TestEnum = require(script.Parent.TestEnum)

local LifecycleHooks = {}
LifecycleHooks.__index = LifecycleHooks

function LifecycleHooks.new()
	local self = {
		_stack = {},
	}
	setmetatable(self, LifecycleHooks)
	return self
end

--[[
	Returns an array of `beforeEach` hooks in FIFO order
]]
function LifecycleHooks:getBeforeEachHooks()
	local key = TestEnum.NodeType.BeforeEach
	local hooks = {}

	for _, level in ipairs(self._stack) do
		for _, hook in ipairs(level[key]) do
			table.insert(hooks, hook)
		end
	end

	return hooks
end

--[[
	Returns an array of `afterEach` hooks in FILO order
]]
function LifecycleHooks:getAfterEachHooks()
	local key = TestEnum.NodeType.AfterEach
	local hooks = {}
	for _, level in ipairs(self._stack) do
		for _, hook in ipairs(level[key]) do
			table.insert(hooks, 1, hook)
		end
	end

	return hooks
end

--[[
	Pushes uncalled beforeAll and afterAll hooks back up the stack
]]
function LifecycleHooks:popHooks()
	local popped = self._stack[#self._stack]
	table.remove(self._stack, #self._stack)

	local function pushHooksUp(type)

		local back = self:_getBackOfStack()

		if not back then
			return
		end

		back[type] = popped[type]
	end

	pushHooksUp(TestEnum.NodeType.BeforeAll)
	pushHooksUp(TestEnum.NodeType.AfterAll)
end

function LifecycleHooks:pushHooksFrom(planNode)
	assert(planNode ~= nil)

	table.insert(self._stack, {
		[TestEnum.NodeType.BeforeAll] = self:_getBeforeAllHooksUncalledAtCurrentLevel(planNode.children),
		[TestEnum.NodeType.AfterAll] = self:_getAfterAllHooksUncalledAtCurrentLevel(planNode.children),
		[TestEnum.NodeType.BeforeEach] = self:_getHooksOfType(planNode.children, TestEnum.NodeType.BeforeEach),
		[TestEnum.NodeType.AfterEach] = self:_getHooksOfType(planNode.children, TestEnum.NodeType.AfterEach),
	})
end

function LifecycleHooks:getPendingBeforeAllHooks()
	return self:_getAndClearPendingHooks(TestEnum.NodeType.BeforeAll)
end

function LifecycleHooks:getAfterAllHooks()
	if #self._stack > 0 then
		return self:_getAndClearPendingHooks(TestEnum.NodeType.AfterAll)
	else
		return {}
	end
end

--[[
	Return any hooks that have not yet been returned for this key and clear those hooks
]]
function LifecycleHooks:_getAndClearPendingHooks(key)
	assert(key ~= nil)

	if #self._stack > 0 then

		local back = self._stack[#self._stack]

		local hooks = back[key]

		back[key] = {}

		return hooks
	else
		return {}
	end
end

--[[
	Transfers uncalled beforeAll and afterAll hooks down the stack
]]
function LifecycleHooks:_getBeforeAllHooksUncalledAtCurrentLevel(childNodes)
	local hookType = TestEnum.NodeType.BeforeAll
	local hooks = self:_getHooksOfTypeFromBackOfStack(hookType)

	for _, hook in pairs(self:_getHooksOfType(childNodes, hookType)) do
		table.insert(hooks, hook)
	end

	return hooks
end

function LifecycleHooks:_getAfterAllHooksUncalledAtCurrentLevel(childNodes)
	local hookType = TestEnum.NodeType.AfterAll
	local hooks = self:_getHooksOfTypeFromBackOfStack(hookType)

	for _, hook in pairs(self:_getHooksOfType(childNodes, hookType)) do
		table.insert(hooks, 1, hook)
	end

	return hooks
end

function LifecycleHooks:_getHooksOfTypeFromBackOfStack(hookType)
	assert(hookType, "Expected hookType to be an argument")

	local currentBack = self:_getBackOfStack()

	local hooks = {}

	if currentBack then
		for _, hook in pairs(currentBack[hookType]) do
			table.insert(hooks, hook)
		end

		currentBack[hookType] = {}
	end

	return hooks
end

function LifecycleHooks:_getBackOfStack()
	return self._stack[#self._stack] or nil
end

function LifecycleHooks:_getHooksOfType(nodes, type)
	local hooks = {}

	for _, node in pairs(nodes) do
		if node.type == type then
			table.insert(hooks, node.callback)
		end
	end

	return hooks
end

return LifecycleHooks
