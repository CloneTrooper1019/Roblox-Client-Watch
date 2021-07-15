local Plugin = script.Parent.Parent.Parent
local AddThreadId = require(Plugin.Src.Actions.Callstack.AddThreadId)
local RequestCallstackThunk = require(Plugin.Src.Thunks.RequestCallstackThunk)

return function(pausedState, dataModel, debuggerStateToken)
	return function(store)
		pausedState:requestThreads()
		:andThen(function (threads : { [number] : ThreadState })
			for threadId, threadState in ipairs(threads) do
				store:dispatch(AddThreadId(threadId, threadState:getThreadName(), debuggerStateToken))
				store:dispatch(RequestCallstackThunk(threadState, dataModel, debuggerStateToken))
			end
		end)
		:catch(function (threads : { [number] : ThreadState })
			warn("Encountered an error during asynchronous execution.")
		end)
    end
end
