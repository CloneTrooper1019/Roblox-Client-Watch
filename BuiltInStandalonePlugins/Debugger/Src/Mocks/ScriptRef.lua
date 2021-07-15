--!strict
--[[
ScriptRef:
]]--

local ScriptRef = {}

function ScriptRef.new()		
	local scriptInstance = {
		name = "TestScript"
	}
	local find = function (dataModel : string)
		return scriptInstance
	end

	return {
		find = find,
	}
end

export type ScriptRef = typeof(ScriptRef.new())
return ScriptRef
