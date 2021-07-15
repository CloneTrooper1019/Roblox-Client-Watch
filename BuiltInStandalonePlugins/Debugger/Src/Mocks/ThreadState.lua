--!strict
--[[
ThreadState:
- threadId : number
- threadName : string
- isValid : boolean
- callstack : { StackFrame }
]]--

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Promise = Framework.Util.Promise

local StackFrame = require(script.Parent.StackFrame)

local ThreadState = {}

function ThreadState.new(threadId : number, threadName : string, isValid : boolean, callstack : { StackFrame.StackFrame })
	local self = {
		threadId = threadId,
		threadName = threadName,
		isValid = isValid,
		callstack = callstack,
	}
	
	local requestCallstack = function ()
		return Promise.new(function(resolve, reject, onCancel)
			if (self.isValid) then
				resolve(self.callstack)
			else
				reject(self.callstack)
			end
		end)
	end
	
	local getCallstackSize = function () : number
		local count = 0
		for _ in pairs(self.callstack) do 
			count = count + 1
		end
		return count
	end

	local getThreadId = function () : number
		return self.threadId
	end
	
	local getThreadName = function () : string
		return self.threadName
	end
	
	local getIsValid = function () : boolean
		return self.isValid
	end
	
	local getCallstack = function () : { StackFrame.StackFrame }
		return self.callstack
	end

	return {
		requestCallstack = requestCallstack,
		getCallstackSize = getCallstackSize,
		getThreadId = getThreadId,
		getThreadName = getThreadName,
		getIsValid = getIsValid,
		getCallstack = getCallstack,
	}
end

export type ThreadState = typeof(ThreadState.new(0, "DefaultThread", true, {}))
export type ThreadId = number
return ThreadState
