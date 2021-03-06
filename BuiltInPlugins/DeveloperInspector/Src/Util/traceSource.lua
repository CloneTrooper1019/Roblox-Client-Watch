--[[ 
	Uses a path generated by Roact.enableElementTraceback to find location of
	a specific component.

	Outputs parameters for plugin:OpenScript
--]]
local BUILTIN_PLUGIN_PREFIX = "builtin"
local PLUGIN_DEBUG_PREFIX = "plugindebugservice"
local CORE_GUI_PREFIX = "coregui"
local WARN_DISABLED_SETTING = "Traceback unavailable: %s is disabled."
local WARN_PLUGIN_DEBUG = "Traceback unavailable: %s is not in PluginDebugService"
local ERROR_INSTANCE_NOT_FOUND = "Unable to find traceback. Does the path %s exist in the explorer?"

local TAIL_INDEX = 2

local DebugFlags = require(script.Parent.DebugFlags)
local isCLI = DebugFlags.RunningUnderCLI

local showCoreGui, showPluginDebug
if isCLI then
	showCoreGui = true
	showPluginDebug = true
else
	showCoreGui = settings().Studio["Show Core GUI in Explorer while Playing"]
	showPluginDebug = settings().Studio["PluginDebuggingEnabled"]
end

return function (source)
	local instance = nil
	local lineNumber = 0
	local parts = string.split(source, ":")

	-- parts[2] is something like "123 function render" or "123".
	lineNumber = string.split(parts[2], " ")
	lineNumber = tonumber(lineNumber[1])

	local pathArray = string.split(parts[1], ".")
	local root = string.lower(pathArray[1])

	if root:find(BUILTIN_PLUGIN_PREFIX) then
		local pluginName = pathArray[1] .. ".rbxm"
		if not game:GetService("PluginDebugService"):FindFirstChild(pluginName) then
			warn(WARN_PLUGIN_DEBUG:format(pluginName))
			return nil, nil
		end

		-- Inserts correct value for preprocessing in next case
		table.insert(pathArray, 1, "PluginDebugService")
		root = string.lower(pathArray[1])
	end

	if root:find(PLUGIN_DEBUG_PREFIX) then
		-- splitting on '.' causes builtin plugin's names to be split
		-- (something like builtin_PluginName.rbxm)
		if pathArray[3] == "rbxm" then
			pathArray[2] = pathArray[2] .. ".rbxm"
			table.remove(pathArray, 3)
		end
		if not showPluginDebug then
			warn(WARN_DISABLED_SETTING:format(root))
		end
	end

	if root:find(CORE_GUI_PREFIX) and not showCoreGui then
		warn(WARN_DISABLED_SETTING:format(root))
	end

	instance = game:GetService(pathArray[1])

	if not instance then
		warn((ERROR_INSTANCE_NOT_FOUND):format(source))
		return nil, nil
	end

	for i=TAIL_INDEX, #pathArray do
		instance = instance:FindFirstChild(pathArray[i], true)
	end

	return instance, lineNumber
end
