local Stack = {}
Stack.__index = Stack

function Stack.new()
	local self = {}
	setmetatable(self, Stack)
	self.data = {}
	return self
end

function Stack:size()
	return #self.data
end

function Stack:push(obj)
	self.data[self:size()+1] = obj
	return self
end

function Stack:pop()
	local result = self:getBack()
	table.remove(self.data,self:size())
	return result
end

function Stack:getBack()
	if self:size() == 0 then error("stack is empty") end
	local result = self.data[self:size()]
	return result
end

function Stack:setBack(obj)
	if self:size() == 0 then error("stack is empty") end
	self.data[self:size()] = obj
	return self
end

return Stack