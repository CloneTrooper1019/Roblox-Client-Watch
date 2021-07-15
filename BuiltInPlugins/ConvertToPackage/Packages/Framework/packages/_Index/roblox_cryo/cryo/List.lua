--[[
	Defines utilities for working with 'list-like' tables.
]]

return {
	filter = require(script.filter),
	filterMap = require(script.filterMap),
	find = require(script.find),
	findWhere = require(script.findWhere),
	foldLeft = require(script.foldLeft),
	foldRight = require(script.foldRight),
	getRange = require(script.getRange),
	join = require(script.join),
	map = require(script.map),
	removeIndex = require(script.removeIndex),
	removeRange = require(script.removeRange),
	removeValue = require(script.removeValue),
	replaceIndex = require(script.replaceIndex),
	reverse = require(script.reverse),
	sort = require(script.sort),
	toSet = require(script.toSet),
}