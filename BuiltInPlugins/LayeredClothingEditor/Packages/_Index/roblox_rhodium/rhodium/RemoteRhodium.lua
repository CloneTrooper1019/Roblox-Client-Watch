local RemoteRhodium = {}
local HttpService = game:getService("HttpService")

local rootPath = nil

local function split(s, delimiter)
	local result = {};
	while(s:len()>0) do
		local pos, stop = string.find(s,delimiter,1,true)
		if pos == nil then
			table.insert(result,s)
			s = ""
		else
			table.insert(result,string.sub(s,1,pos-1))
			s = string.sub(s,stop+1)
			if s == "" then table.insert(result,"") end
		end
	end
	return result
end

function RemoteRhodium.setCommandPath(p)
	rootPath = p
end

local function onCommand(command)
	assert(type(command) == "string", "command should be a string")

	local op = command:find("(", 1, true)
	local cp = command:reverse():find(")", 1, true)
	if cp ~= nil then
		cp = #command - cp + 1
	end

	local args = {}
	if op then
		assert(cp, "invalid syntex, expecting \")\"")
		local argStr = command:sub(op+1, cp-1)
		if #argStr > 0 then
			args = HttpService:JSONDecode("["..argStr.."]")
		end
		command = command:sub(1, op-1)
	end

	local subPathTab = split(command, ".")

	local instance = rootPath
	for i = 1, #subPathTab do
		local p = subPathTab[i]
		instance = instance[p]
		if instance == nil then
			error("can not find " .. p)
		end
		if type(instance) == "userdata" and instance.ClassName == "ModuleScript" then
			instance = require(instance)
		end
	end
	if type(instance) ~= "function" then
		error("target is not a function")
	end
	return instance(unpack(args))
end

function RemoteRhodium.setCommandPath(p)
	rootPath = p
end

local success, RhodiumService = pcall(function()
		return game:getService("RhodiumService")
	end)

if success then
	RhodiumService.onCommand = onCommand
end

return RemoteRhodium