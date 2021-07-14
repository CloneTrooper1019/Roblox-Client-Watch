local symbols = require(script.Parent.symbols)
local Spy = require(script.Parent.Spy)

local MagicMock = {}
local MetaMock = {}

function MetaMock:__index(key)
	-- Any access to an undefined member will return a new MagicMock.
	local meta = getmetatable(self)
	local child = meta[symbols.Children][key]
	if child == nil then
		child = MagicMock.new()
		meta[symbols.Children][key] = child
		return child
	elseif child == symbols.None then
		return nil
	else
		return child
	end
end

function MetaMock:__newindex(key, value)
	-- Store any assigned values for later recall.
	local meta = getmetatable(self)
	if type(value) == "function" then
		local _, wrapper = Spy.new(value)
		value = wrapper
	elseif value == nil then
		value = symbols.None
	end

	if key == symbols.ReturnValue then
		meta[symbols.ReturnValue] = { value, n=1 }
	else
		meta[symbols.Children][key] = value
	end
end

function MetaMock:__call(...)
	-- Any call to a MagicMock will store the args and then return the
	-- ReturnValue (or call that if it's a function). If no return
	-- value was set, this will create a new MagicMock.
	local meta = getmetatable(self)
	local call = {
		args = table.pack(...),
		result = meta[symbols.ReturnValue],
	}
	if call.result == nil then
		local child = MagicMock.new()
		call.result = { child, n=1 }
		meta[symbols.ReturnValue] = call.result
	elseif call.result == symbols.None then
		call.result = { n=1 }
	end

	table.insert(meta[symbols.Calls], call)
	return table.unpack(call.result)
end

function MagicMock.new(lock)
	local mock = {
		[symbols.Calls] = {},
		[symbols.Children] = {},
		[symbols.Lock] = lock,
		[symbols.ReturnValue] = nil,
	}

	-- Copy the Meta functions from MetaMock
	for k, v in pairs(MetaMock) do
		mock[k] = v
	end

	return setmetatable({}, mock)
end

return MagicMock
