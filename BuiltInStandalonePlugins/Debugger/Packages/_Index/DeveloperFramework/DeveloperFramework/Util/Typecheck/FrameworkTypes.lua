--[[
	Definitions for special t-compatible checks for Framework lua objects.
	These functions can be used like any other t functions.
]]

local Framework = script.Parent.Parent.Parent
local StyleModifier = require(Framework.Util.StyleModifier)
local t = require(script.Parent.t)
local FrameworkTypes = {}
local Flags = require(Framework.Util.Flags)
local FlagsList = Flags.new({
	FFlagRefactorDevFrameworkContextItems = {"RefactorDevFrameworkContextItems"},
})

function FrameworkTypes.Component(value)
	local errMsg = "Component expected, got %s."
	if not t.table(value) or not t.callback(value.render) then
		return false, errMsg:format(type(value))
	end
	return true
end

function FrameworkTypes.ContextItem(value)
	local errMsg = "ContextItem expected, got %s."
	if not t.table(value) or not t.callback(value.createProvider) then
		return false, errMsg:format(type(value))
	end
	return true
end

function FrameworkTypes.Theme(value)
	local errMsg = "Theme expected, got %s."
	if not t.table(value) or not t.callback(value.getStyle) then
		return false, errMsg:format(type(value))
	end
	return true
end

function FrameworkTypes.Stylizer(value)
	local errMsg = "Stylizer expected, got %s."
	if not t.table(value) or not t.callback(value.getConsumerItem) then
		return false, errMsg:format(type(value))
	end
	return true
end

function FrameworkTypes.Plugin(value)
	local errMsg = "Plugin expected, got %s."
	if not t.table(value) or not t.callback(value.get) then
		return false, errMsg:format(type(value))
	end
	return true
end

function FrameworkTypes.Mouse(value)
	local errMsg = "Mouse expected, got %s."
	if not t.table(value) or not t.callback(value.get) then
		return false, errMsg:format(type(value))
	end
	return true
end

function FrameworkTypes.Focus(value)
	local errMsg = "Focus expected, got %s."
	local getFunction = FlagsList:get("FFlagRefactorDevFrameworkContextItems") and value.get or value.getTarget
	if not t.table(value) or not t.callback(getFunction) then
		return false, errMsg:format(type(value))
	end
	return true
end

function FrameworkTypes.RoactRef(value)
	return t.table(value) and tostring(value):find("RoactRef")
end

function FrameworkTypes.Symbol(value)
	return t.userdata(value)
end

function FrameworkTypes.Signal(value)
	local errMsg = "Signal expected, got %s."
	if not t.table(value) or not t.table(value._listeners) then
		return false, errMsg:format(type(value))
	end
	return true
end

function FrameworkTypes.StyleModifier(value)
	local errMsg = "StyleModifier expected, got %s."

	if StyleModifier.isEnumValue(value) then
		return true
	end

	return false, errMsg:format(type(value))
end

local stringOrTable = t.union(t.string, t.table)
function FrameworkTypes.Style(value)
	return stringOrTable(value)
end

local instanceOrTable = t.union(t.Instance, t.table)
function FrameworkTypes.Instance(value)
	return instanceOrTable(value)
end

function FrameworkTypes.Voting(value)
	return t.strictInterface({
		UpVotes = t.integer,
		DownVotes = t.integer,
		CanVote = t.optional(t.boolean),
		UserVote = t.optional(t.boolean),
	})
end

return FrameworkTypes
