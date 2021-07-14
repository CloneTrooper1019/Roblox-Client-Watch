-- Functions to check if a mock was ever called with given arguments.

local getCalls = require(script.Parent.getCalls)
local cmpLiteralArgs = require(script.Parent.cmpLiteralArgs)
local cmpPredicateArgs = require(script.Parent.cmpPredicateArgs)
local fmtArgs = require(script.Parent.fmtArgs)

local AnyCallMatches = {}

function AnyCallMatches.args(mock, test)
	local callList = getCalls(mock)
	local size = #callList
	if size == 0 then
		return false, "mock was not called"
	end

	local msg
	for i = 1, size do
		local result
		result, msg = test(callList[i].args)
		if result then
			return true
		end
	end

	if not msg then
		msg = fmtArgs(callList[size].args) .. " did not match"
	end
	if size > 1 then
		msg = msg .. " (+" .. (size - 1) .. " other calls)"
	end

	return false, msg
end

function AnyCallMatches.literals(mock, ...)
	local expected = table.pack(...)
	return AnyCallMatches.args(mock, function(actual)
		return cmpLiteralArgs(expected, actual)
	end)
end

function AnyCallMatches.predicates(mock, ...)
	local predicates = table.pack(...)
	return AnyCallMatches.args(mock, function(actual)
		return cmpPredicateArgs(predicates, actual)
	end)
end

return AnyCallMatches
