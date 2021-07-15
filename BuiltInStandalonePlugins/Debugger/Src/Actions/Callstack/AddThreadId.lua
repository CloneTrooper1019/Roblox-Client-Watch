local Plugin = script.Parent.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Util = Framework.Util
local Action = Util.Action
local DebuggerStateToken = require(Plugin.Src.Models.DebuggerStateToken)

export type Props = {
	threadId : number,
	displayString : string,
	debuggerStateToken : DebuggerStateToken.DebuggerStateToken,
}
return Action(script.Name, function(threadId : number, displayString : string, debuggerStateToken : DebuggerStateToken.DebuggerStateToken) : Props
	return {
		threadId = threadId,
		displayString = displayString,
		debuggerStateToken = debuggerStateToken,
	}
end)
