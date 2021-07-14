--[[
	pollUntil repeatedly runs a function on render step until it returns a truthy value.
]]
local Promise = require(script.Parent.Promise)

export type Poller = () -> boolean

local function pollUntil(fn: Poller, stopAfterSeconds: number?)
	-- Stop after the specified amount of time
	local endTime = time() + (stopAfterSeconds or 1)
	local doFulfil, doReject
	-- A promise encapsulates the eventual result or timeout
	local promise = Promise.new(function(fulfil, reject)
		doFulfil = fulfil
		doReject = reject
	end)
	spawn(function()
		local result = fn()
		while time() < endTime and not result do
			wait()
			result = fn()
		end
		if result then
			doFulfil(result)
		else
			doReject()
		end
	end)
	return promise
end

return pollUntil
