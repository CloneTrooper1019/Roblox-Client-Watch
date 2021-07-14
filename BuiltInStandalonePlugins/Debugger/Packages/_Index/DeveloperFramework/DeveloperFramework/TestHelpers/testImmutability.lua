--[[
	A function that every reducer should use to check that valid actions do not mutate the previous state.

	This function takes a snapshot of the state before and after an action is applied.
	Then it checks if any fields from the original data have been mutated.

	The final output of the reducer is ultimately irrelevant for this test.
	All that matters is that the original data is preserved and unmodified.
]]
local DevFrameworkRoot = script.Parent.Parent
local deepJoin = require(DevFrameworkRoot.Util.deepJoin)

local function allFieldsAreUnchanged(tableA, tableB)
	-- if there's some mistake, escape
	if type(tableA) ~= "table" or type(tableB) ~= "table" then
		if not tableA then
			tableA = "nil"
		end
		if not tableB then
			tableB = "nil"
		end
		error(string.format("Expected to compare two tables, got %s and %s", tostring(tableA), tostring(tableB)))
	end

	-- count all the keys in B
	local expectedNumKeysB = 0
	for _, _ in pairs(tableB) do
		expectedNumKeysB = expectedNumKeysB + 1
	end

	-- check that all keys are equal in type and value
	local expectedNumKeysA = 0
	for key, vA in pairs(tableA) do
		expectedNumKeysA = expectedNumKeysA + 1
		local vB = tableB[key]

		if type(vA) == "table" then
			-- if there's a child, verify that all its values are unmutated
			allFieldsAreUnchanged(vA, vB)
		else
			if vA ~= vB then
				error(string.format("the field \"%s\" no longer matches", key))
			end
		end
	end

	-- make sure that no keys haven't gone missing
	if expectedNumKeysA ~= expectedNumKeysB then
		return error(string.format("Number of keys mismatch : %d vs %d", expectedNumKeysA, expectedNumKeysB))
	end

	-- if we've made it here, these tables are separate yet equal matches
	return true
end


return function(reducer, action, previousState)
	assert(type(reducer) == "function", "Expected a reducer to test")
	assert(type(action) == "table", "Expected an action to test")
	if previousState ~= nil then
		assert(type(previousState) == "table", "Expected previousState to be a table")
	end

	-- copy the originalState
	local originalState = reducer(previousState, { type = "__nil__" })
	local originalStateCopy = deepJoin(originalState, {})
	assert(allFieldsAreUnchanged(originalState, originalStateCopy), "deepJoin mutates fields")

	-- run the state through a reducer, disregard the output
	reducer(originalState, action)

	-- check that originalState still matches the originalStateCopy
	return allFieldsAreUnchanged(originalState, originalStateCopy)
end
