--!strict
--[[
PausedState:
- threadCount : number
- reason : Enum.DebuggerPauseReason (temporarily string)
- isValid : boolean
- threadMap : { [ThreadState.ThreadId] : ThreadState}
]]--

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Promise = Framework.Util.Promise

local ThreadState = require(script.Parent.ThreadState)

local PausedState = {}

function PausedState.new(reason : string, isValid : boolean, threadMap : { [ThreadState.ThreadId] : ThreadState.ThreadState })	
	local self = {
		reason = reason,
		isValid = isValid,
		threadMap = threadMap,
	}

	local requestThreads = function ()
		return Promise.new(function(resolve, reject, onCancel)
			if (self.isValid) then
				resolve(self.threadMap)
			else
				reject(self.threadMap)
			end
		end)
	end
	
	local getThread = function (state : PausedState, index : ThreadState.ThreadId) : ThreadState.ThreadState
		return self.threadMap[index]
	end

	local getThreadCount = function () : number
		local count = 0
		for _ in pairs(self.threadMap) do 
			count = count + 1 
		end
		return count
	end
	
	local getReason = function () : string
		return self.reason
	end
	
	local getIsValid = function () : boolean
		return self.isValid
	end
	
	local getThreadMap = function () : { [ThreadState.ThreadId] : ThreadState.ThreadState }
		return self.threadMap
	end

	return {
		requestThreads = requestThreads,
		getThread = getThread,
		getThreadCount = getThreadCount,
		getReason = getReason,
		getIsValid = getIsValid,
		getThreadMap = getThreadMap,
	}
end

export type PausedState = typeof(PausedState.new("DefaultReason", true, {}))
return PausedState
