local Plugin = script.Parent.Parent.Parent
local Models = Plugin.Src.Models
local CallstackRow = require(Models.CallstackRow)
local AddCallstack = require(Plugin.Src.Actions.Callstack.AddCallstack)

return function(threadState, dataModel, debuggerStateToken)
	return function(store)
		threadState:requestCallstack()
		:andThen(function (callstack : { StackFrame })
			local callstackRows = {}
			for stackFrameId, stackFrame in ipairs(callstack) do
				local arrowColumnValue = {}
				if (stackFrameId == 1) then
					arrowColumnValue = {
						Value = "",
						LeftIcon = {
							Image = CallstackRow.ICON_PATH,
							Size = CallstackRow.ICON_SIZE
						},
					}
				end

				local scriptInstance = stackFrame:getScriptRef():find(dataModel)
				if (scriptInstance == nil) then
					warn("The script instance was returned as nil.")
				end
				
				local sourceName = scriptInstance.name

				local data = {
					arrowColumn = arrowColumnValue,
					frameColumn = stackFrameId,
					whatColumn = stackFrame:getFrameType(),
					functionNameColumn = stackFrame:getFrameName(),
					lineNumberColumn = stackFrame:getLine(),
					sourceColumn = sourceName,
				}
				table.insert(callstackRows, CallstackRow.fromData(data))
			end
			store:dispatch(AddCallstack(threadState:getThreadId(), callstackRows, debuggerStateToken))
		end)
		:catch(function (callstack : { StackFrame })
			warn("Encountered an error during asynchronous execution.")
		end)
    end
end
