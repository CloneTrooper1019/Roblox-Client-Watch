--[[
	Create an error object with a specified name and message.

	In native Lua, errors can only be string values. At Roblox, we can take advantage of throwing
	error objects to provide structured information about problems that occur.

	The tags table stores serializable information about an error which can be provided when it is
	thrown, and later passed to a logging endpoint.

	Throwing an error instance captures its stack trace, avoiding the need to explicitly use xpcall.
	
	@usage In general, errors should not be used during normal control flow.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local class = require(Dash.class)
local format = require(Dash.format)
local join = require(Dash.join)

--[[
	Create a new Error instance.
	@param name The name of the error
	@param string A message for the error which will be formatted using Dash.format
	@param tags Any fixed tags 
]]
local Error = class("Error", function(name: string, message: string, tags: Types.Table?)
	return {
		name = name,
		message = message or "An error occurred",
		tags = tags or {}
	}
end)

function Error:toString(): string
	return format("{}: {}\n{}", self.name, format(self.message, self.tags), self.stack)
end

--[[
	Return a new error instance containing the tags provided joined to any existing tags of the
	current error instance.
]]
function Error:joinTags(tags: Types.Table?): Error
	return Error.new(self.name, self.message, join(self.tags, tags))
end

--[[
	Throw an error.

	The stack of the error is captured and stored.

	If additional tags are provided, a new error is created with the joined tags of
	this instance.
]]
function Error:throw(tags: Types.Table?)
	local instance = self:joinTags(tags)
	instance.stack = debug.traceback()
	error(instance)
end

-- TODO Luau: Define class types automatically
export type Error = typeof(Error.new("", ""))

return Error