
local DraggerFramework = script.Parent.Parent

-- For now use the DeveloperFramework Lua Signal implementation. I want to
-- fix my implementation and return to using it later when I have time.
if true then
	--[[
		A limited, simple implementation of a Signal.

		Handlers are fired in order, and (dis)connections are properly handled when
		executing an event.

		Signal uses Immutable to avoid invalidating the 'Fire' loop iteration.
	]]

	local function RemoveFromDictionary(dictionary, ...)
		local result = {}

		for key, value in pairs(dictionary) do
			local found = false
			for listKey = 1, select("#", ...) do
				if key == select(listKey, ...) then
					found = true
					break
				end
			end
			if not found then
				result[key] = value
			end
		end

		return result
	end

	local function Append(list, ...)
		local new = {}
		local len = #list

		for key = 1, len do
			new[key] = list[key]
		end

		for i = 1, select("#", ...) do
			new[len + i] = select(i, ...)
		end

		return new
	end

	local Signal = {}

	Signal.__index = Signal

	function Signal.new()
		local self = {
			_listeners = {}
		}

		setmetatable(self, Signal)

		return self
	end

	function Signal:Connect(callback)
		local listener = {
			callback = callback,
			isConnected = true,
		}
		self._listeners = Append(self._listeners, listener)

		local function disconnect()
			listener.isConnected = false
			self._listeners = RemoveFromDictionary(self._listeners, listener)
		end

		return {
			Disconnect = disconnect,
		}
	end

	function Signal:Fire(...)
		for _, listener in ipairs(self._listeners) do
			if listener.isConnected then
				listener.callback(...)
			end
		end
	end


	return Signal
else
	--------------------------------------------------------------------------------
	--               Batched Yield-Safe Signal Implementation                     --
	-- This is a signal class which has almost identical behavior to the          --
	-- RBXScriptSignal.                                                           --
	-- * The first way it differs from RBXScriptSignal is that it passes event    --
	-- arguments by reference instead of by value, so if you fire it with a table --
	-- argument the argument won't be serialized or copied, it will be passed by  --
	-- reference.                                                                 --
	-- * The second way it differs from RBXScriptSignal is that the fire() method --
	-- will raise an exception if an exception is raised synchonously within one  --
	-- of the connected event handlers. This gives you a full stack trace of the  --
	-- code that caused the exception unlike with RBXScriptSignal.                --
	-- * It allows you to yield in event handlers without blocking the fire call, --
	-- fire events with nils in the middle of the event argument list, and        --
	-- connect / disconnect events safely during event handlers.                  --
	-- It also uses efficient batching and flags to avoid creating extra threads. --
	--------------------------------------------------------------------------------

	-- Helper to unpack and call a variable argument list with a function to call
	-- as the first argument in the list.
	local function callPacked(fn, ...)
		fn(...)
	end

	-- Coroutine runner to batch non-yielding event handlers together
	local isCoRunnerReady = true
	local function fnCoRunner(fn, ...)
		fn(...)
		isCoRunnerReady = true
		while true do
			callPacked(coroutine.yield())
			isCoRunnerReady = true
		end
	end
	local coRunnerThread = coroutine.create(fnCoRunner)

	-- Connection class
	local Connection = {}
	Connection.__index = Connection

	function Connection.new(signal, fn)
		return setmetatable({
			_connected = true,
			_signal = signal,
			_fn = fn,
			_next = false
		}, Connection)
	end

	function Connection:Disconnect()
		assert(self._connected, "Can't disconnect a connection twice.", 2)
		self._connected = false

		-- Unhook the node, but DON'T clear it. That way any fire calls that are
		-- currently sitting on this node will be able to iterate forwards off of
		-- it, but any subsequent fire calls will not hit it, and it will be GCed
		-- when no more fire calls are sitting on it.
		if self._signal._handlerListHead == self then
			self._signal._handlerListHead = self._next
		else
			local prev = self._signal._handlerListHead
			while prev and prev._next ~= self do
				prev = prev._next
			end
			if prev then
				prev._next = self._next
			end
		end
	end

	-- Make Connection strict
	setmetatable(Connection, {
		__index = function(key)
			error(("Attempt to get Connection::%s (not a valid member)"):format(key), 2)
		end,
		__newindex = function(key, value)
			error(("Attempt to set Connection::%s (not a valid member)"):format(key), 2)
		end
	})

	-- Signal class
	local Signal = {}
	Signal.__index = Signal

	function Signal.new()
		return setmetatable({
			_handlerListHead = false
		}, Signal)
	end

	function Signal:Connect(fn)
		local connection = Connection.new(self, fn)
		if self._handlerListHead then
			connection._next = self._handlerListHead
			self._handlerListHead = connection
		else
			self._handlerListHead = connection
		end
		return connection
	end

	-- Signal::Fire(...) implemented by running the handler functions on the
	-- coRunnerThread, and any time the resulting thread yielded without returning
	-- to us, that means that it yielded to the Roblox scheduler and has been taken
	-- over by Roblox scheduling, meaning we have to make a new coroutine runner.
	function Signal:Fire(...)
		local item = self._handlerListHead
		while item do
			if item._connected then
				isCoRunnerReady = false
				local st, err = coroutine.resume(coRunnerThread, item._fn, ...)
				if not isCoRunnerReady then
					-- The call handler yielded in Roblox yields, so the Roblox
					-- thread scheduler will have "stolen" it. We need a new runner.
					coRunnerThread = coroutine.create(fnCoRunner)
					isCoRunnerReady = true

					-- Check if we encountered an error in the handler, the error
					-- case will cause isCoRunnerReady to definitely be false, so
					-- we can do the check in this if body.
					-- If we did, throw from here. This is a deviation from what
					-- RBXScriptSignal does but it vastily improves debuggability
					-- by giving us a stack trace of the code that caused the error.
					-- NOTE: We have to do this _after_ creating a new CoRunner
					-- because the user may handle the error with pcall and continue
					-- using the Signal afterwards.
					if not st then
						error("Error in event handler: "..err, 2)
					end
				end
			end
			item = item._next
		end
	end

	-- Implement Signal::wait() in terms of a temporary connection using
	-- a Signal::connect() which disconnects itself.
	function Signal:Wait()
		local coCurrentlyRunning = coroutine.running()
		local cn;
		cn = self:connect(function(...)
			cn:Disconnect()
			coroutine.resume(coCurrentlyRunning, ...)
		end)
		return coroutine.yield()
	end

	-- Make signal strict
	setmetatable(Signal, {
		__index = function(key)
			error(("Attempt to get Signal::%s (not a valid member)"):format(key), 2)
		end,
		__newindex = function(key, value)
			error(("Attempt to set Signal::%s (not a valid member)"):format(key), 2)
		end
	})

	return Signal
end
