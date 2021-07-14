--[[
	Provides functions for comparing and printing lua tables.
]]

return {
	checkListConsistency = require(script.checkListConsistency),
	deepEqual = require(script.deepEqual),
	deepCopy = require(script.deepCopy),
	equalKey = require(script.equalKey),
	fieldCount = require(script.fieldCount),
	listDifferences = require(script.listDifferences),
	print = require(script.print)(print),
	shallowEqual = require(script.shallowEqual),
	tableDifference = require(script.tableDifference),
	toString = require(script.toString),
}
