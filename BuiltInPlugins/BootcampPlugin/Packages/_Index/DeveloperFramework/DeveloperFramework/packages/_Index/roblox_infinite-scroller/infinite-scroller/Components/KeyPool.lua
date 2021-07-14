--[[
	KeyPool provides a pool of objects suitable for use as map keys.

	Create a new KeyPool, then call pool:get() to get a new key. Once you're done with it, call key:release().

	Example:
		local pool = KeyPool.new("foo")
		...
		local key1 = pool:get()
		local key2 = pool:get()
		map[key1] = thing1
		map[key2] = thing2
		...
		map[key1] = nil
		key1:release()
		key1 = nil
]]
local Root = script:FindFirstAncestor("infinite-scroller").Parent
local t = require(Root.t)

-- Forward declarations
local KeyPool = {}
KeyPool.__index = KeyPool

local Key = {}
Key.__index = Key

-- This is Key.new, but we don't want to expose that publicly.
local function newkey(pool: KeyPool, index)
	local key = {
		pool = pool,
		index = index,
	}

	setmetatable(key, Key)
	return key
end

-- KeyPool functions

function KeyPool.new(class: string)
	assert(t.string(class))

	local pool = {
		class = class,
		available = {},
		limit = 0,
		count = 0,
	}

	setmetatable(pool, KeyPool)
	return pool
end

export type KeyPool = typeof(KeyPool.new(""))
export type Key = typeof(newkey(KeyPool.new(""), 1))

-- Get a currently unused key, or create a new one if everything is in use.
function KeyPool.get(self: KeyPool): Key
	if self.count == 0 then
		self.limit = self.limit + 1
		return newkey(self, self.limit)
	end

	local key = self.available[self.count]
	self.count = self.count - 1
	return key
end

-- Key functions

function Key.__tostring(self: Key)
	return self.pool.class .. "_" .. string.format("%02d", self.index)
end

-- Return this key to the pool it came from. Whatever previously held this key should not keep the reference after
-- calling this.
function Key.release(self: Key)
	self.pool.count = self.pool.count + 1
	self.pool.available[self.pool.count] = self
end

return KeyPool
