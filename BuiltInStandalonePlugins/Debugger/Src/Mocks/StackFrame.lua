--!strict
--[[
StackFrame:
- line : number
- scriptRef : ScriptRef 
- frameName : string
- frameType : Enum.DebuggerFrameType (temporarily string)
]]--

local ScriptRef = require(script.Parent.ScriptRef)

local StackFrame = {}

function StackFrame.new(line : number, scriptRef : ScriptRef.ScriptRef, frameName : string, frameType)
	local self = {
		line = line,
		scriptRef = scriptRef,
		frameName = frameName,
		frameType = frameType,
	}

	local getLine = function () : number
		return self.line
	end

	local getScriptRef = function () : ScriptRef.ScriptRef
		return self.scriptRef
	end

	local getFrameName = function () : string
		return self.frameName
	end
	
	local getFrameType = function ()
		return self.frameType
	end

	return {
		getLine = getLine,
		getScriptRef = getScriptRef,
		getFrameName = getFrameName,
		getFrameType = getFrameType,
	}
end

export type StackFrame = typeof(StackFrame.new(0, ScriptRef.new(), "DefaultFrameName", nil))
return StackFrame
