local tableDifference = require(script.Parent.tableDifference)

--[[
	Takes a list and returns a table whose
	keys are elements of the list and whose
	values are all true
]]
local function membershipTable(list)
	local result = {}
	for i = 1, #list do
		result[list[i]] = true
	end
	return result
end


--[[
	Takes a table and returns a list of keys in that table
]]
local function listOfKeys(t)
	local result = {}
	for key,_ in pairs(t) do
		table.insert(result, key)
	end
	return result
end


--[[
	Takes two lists A and B, returns a new list of elements of A
	which are not in B
]]
return function(A, B)
	return listOfKeys(tableDifference(membershipTable(A), membershipTable(B)))
end