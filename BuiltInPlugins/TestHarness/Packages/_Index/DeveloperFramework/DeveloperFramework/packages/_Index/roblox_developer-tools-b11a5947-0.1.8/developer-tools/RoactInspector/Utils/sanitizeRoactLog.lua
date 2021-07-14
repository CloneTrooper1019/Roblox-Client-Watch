local Source = script.Parent.Parent.Parent
local Packages = Source.Parent

local Dash = require(Packages.Dash)
local some = Dash.some
local collectArray = Dash.collectArray
local forEach = Dash.forEach
local endsWith = Dash.endsWith

local concat = table.concat

local ignorePhrases = {
	"RoactInspector%.Classes",
	"Roact%.createReconciler",
	"Roact%.Component",
	"Roact%.SingleEventManager",
	"Roact%.RobloxRenderer",
	"Libs%.RoactRodux",
	"Rodux%.Signal",
	"Rodux%.Store",
}

local function sanitizeRoactLog(log: string)
	local lines = log:split("\n")
	local updateCount = 0
	forEach(lines, function(line: string)
		if line:match("Roact.Component") and endsWith(line, "function __update") then
			updateCount += 1
		end
	end)
	lines = collectArray(lines, function(_index: number, line: string)
		local ignore = some(ignorePhrases, function(phrase: string)
			return line:match(phrase)
		end)
		if ignore then
			if line:match("Roact%.Component") and endsWith(line, "function setState") then
				return "Roact.Component setState"
			elseif line:match("RoactRodux%.connect") then
				return "Rodux Store updated"
			elseif line:match("Roact%.SingleEventManager") then
				return "Roact event"
			end
		end
		return not ignore and line or nil
	end)
	local result = concat(lines, "\n")
	if updateCount > 0 then
		return ("Update chain: %d component(s)\nTrigger:\n%s"):format(updateCount, result)
	else
		return result
	end
end

return sanitizeRoactLog