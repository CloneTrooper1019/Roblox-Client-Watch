--[[
	Module for splitting the errorStack string to a list.

	Currently works with:
	Pattern of error from ScriptContext.Error:
		see ScriptContext.extractCallStack

	Pattern of error from ScriptContext.Error: (luau)
		see ScriptContext.extractCallStack

	Pattern of error from debug.traceback:
		see ScriptContext.printCallStack

	Pattern of error from debug.traceback: (luau)
		see luau_backtrace


	Returns:
	stack = {
		[1] = {
			line = "100",
			funcName = "field testError",
			sourceCode = "1",
		},
		[2] = {
			line = "111",
			funcName = "field ?",
			sourceCode = "1",
		},
		[3] = {
			line = "83",
			funcName = "SingleEventManager",
			sourceCode = "2",
		},
	}
	sourceCodeOutput = {
		["1"] = {
			path = "CoreGui.RobloxGui.Modules.LuaApp.Components.Home.HomePageWithAvatarViewportFrame",
		},
		["2"] = {
			path = "CorePackages.Packages._Index.roact.roact.SingleEventManager",
		},
	},
]]

local splitStringWithMarks = require(script.Parent.splitStringWithMarks)
local findFileNameFromPath = require(script.Parent.findFileNameFromPath)

local function processErrorStack(errorStack)
	local stack = {}
	local sourceCodeDict = {}
	local numOfSourceCode = 0

	if type(errorStack) ~= "string" then
		return stack, sourceCodeDict
	end

	for line in errorStack:gmatch("[^\r\n]+") do
		local newLine
		local source
		local funcName
		local lineNumber

		source, newLine = splitStringWithMarks(line, {", line ", ", Line ", ":"})
		lineNumber, funcName = splitStringWithMarks(newLine, {" - "})

		if lineNumber ~= "" and source ~= "" then
			-- Convert "Script 'filePath'" to filePath
			local _, _, matchedSource = string.find(source, "Script '(.*)'")
			if matchedSource ~= nil then
				source = matchedSource
			end

			local index = sourceCodeDict[source]
			if index == nil then
				numOfSourceCode = numOfSourceCode + 1
				index = numOfSourceCode
				sourceCodeDict[source] = index
			end

			-- If no funcName is provided, Backtrace has difficulty differentiating the error
			-- stacks apart. So we want to have something.
			if funcName == "" then
				funcName = findFileNameFromPath(source)
			end

			table.insert(stack, {
				line = lineNumber,
				funcName = funcName,
				sourceCode = tostring(index),
			})
		end
	end

	local sourceCodeOutput = {}
	for path, index in pairs(sourceCodeDict) do
		sourceCodeOutput[tostring(index)] = {
			path = path,
		}
	end

	return stack, sourceCodeOutput
end

return processErrorStack