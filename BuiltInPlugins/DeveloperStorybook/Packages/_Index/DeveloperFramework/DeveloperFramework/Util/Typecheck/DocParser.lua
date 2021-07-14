--[[
	Parses the header comment of a component to create a table of the component's
	documentation, which can be used to	validate the component's props.

	DocParser.new(component, script)
		Creates a new DocParser for parsing the comments for the given component.

	DocParser:parse()
		Parses the leading comment at the top of the component defined in script.
		This returns a table of documentation in plain text strings.
		Example returned table:
		{
			Summary = "A component with a size prop!", --Component summary
			Required = { --Required props
				{
					Name = "Size",
					Type = "UDim2",
					Comment = "The size of the component.",
				},
			},
			Optional = {}, --Optional props
			Style = {}, --Style values
		}

	DocParser.toInterface(docs)
		Generates a t StrictInterface for a component's props and style,
		based on the docs that were provided from a DocParser's parse function.

	Typecheck uses interfaces from Osyris's "t" library.
	For more info, see: https://github.com/osyrisrblx/t
]]

local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local Symbol = require(Framework.Util.Symbol)
local FrameworkTypes = require(script.Parent.FrameworkTypes)
local t = require(script.Parent.t)

local requiredHeader = "Required Props:"
local optionalHeader = "Optional Props:"
local styleHeader = "Style Values:"

local noCommentsError = [[
DocParser:parse expects a block comment at the beginning of the file.]]

local headerError = string.format([[
DocParser:parse expects headers to equal `%s`, `%s`, or `%s` only.]],
	requiredHeader, optionalHeader, styleHeader)

local formattingError = [[
DocParser:parse expects `typename Propname: comment` format for prop definitions.]]

local indentationError = [[
DocParser:parse expects 1 tab for headers, 2 tabs for prop definitions, and 3 tabs for multilined prop comments.]]

local missingHeaderError = [[
DocParser:parse expects a header before prop definitions.]]

local lineTraceback = [[%s
%s.lua, line %d]]

local ParseMode = {
	Summary = Symbol.named("Summary"),
	Required = Symbol.named("Required"),
	Optional = Symbol.named("Optional"),
	Style = Symbol.named("Style"),
}

local DocParser = {}
DocParser.__index = DocParser

function DocParser.new(component, script)
	local self = {
		name = tostring(component),
		script = script,
		line = 1,
	}

	setmetatable(self, DocParser)
	return self
end

-- Using a component's opening comment block, generate documentation for the component.
function DocParser:parse()
	local script = self.script
	assert(t.instanceIsA("LuaSourceContainer")(script))

	local source = script.Source
	local closing = source:find("]]")
	self:__assert(closing, noCommentsError)

	local opening = source:find("^%-%-")
	self:__assert(opening == 1, noCommentsError)

	-- "--[[\n" totals 5 characters, + 1 to start at comment start
	-- "\n]]" totals 3 characters
	local comments = source:sub(6, closing - 3)
	return self:parseComments(comments)
end

-- Parse the given comments string to generate documentation.
function DocParser:parseComments(comments)
	assert(t.string(comments))

	local result = {
		Required = {},
		Optional = {},
		Style = {},
		Summary = nil,
	}

	local parseMode = ParseMode.Summary

	local lines = comments:gsub("\r", ""):split("\n")
	for lineNum, line in ipairs(lines) do
		self.line = lineNum + 1
		local tabs = 0
		for _ in string.gmatch(line, "\t") do
			tabs = tabs + 1
		end
		local rawLine = line:sub(tabs + 1)
		if rawLine == requiredHeader then
			parseMode = ParseMode.Required
		elseif rawLine == optionalHeader then
			parseMode = ParseMode.Optional
		elseif rawLine == styleHeader then
			parseMode = ParseMode.Style
		elseif tabs == 1 and rawLine:find(":") then
			self:__assert(false, headerError)
		else
			if parseMode == ParseMode.Summary and #rawLine > 0 then
				self:__assert(not (tabs == 2 and rawLine:find(":")), missingHeaderError)
				self:__assert(tabs == 1, indentationError)
				result.Summary = result.Summary and string.format("%s\n%s", result.Summary, rawLine) or rawLine
			elseif parseMode == ParseMode.Required then
				self:__parseProp(result.Required, tabs, rawLine)
			elseif parseMode == ParseMode.Optional then
				self:__parseProp(result.Optional, tabs, rawLine)
			elseif parseMode == ParseMode.Style then
				self:__parseProp(result.Style, tabs, rawLine)
			end
		end
	end

	return result
end

-- Static function to convert a docs table into a t interface.
function DocParser.toInterface(docs)
	assert(t.strictInterface({
		Summary = t.optional(t.string),
		Required = t.table,
		Optional = t.table,
		Style = t.table,
	})(docs))

	local propsTable = {
		[Roact.Children] = t.optional(t.table),
		[Roact.Ref] = t.optional(FrameworkTypes.RoactRef),
		[Roact.Change.AbsoluteSize] = t.optional(t.callback),
	}
	local styleTable = {}

	for _, prop in pairs(docs.Required) do
		DocParser.__addCheckForProp(propsTable, prop, false)
	end

	for _, prop in pairs(docs.Optional) do
		DocParser.__addCheckForProp(propsTable, prop, true)
	end

	for _, prop in pairs(docs.Style) do
		DocParser.__addCheckForProp(styleTable, prop, true)
	end

	local propsInterface = t.strictInterface(propsTable)
	local styleInterface = next(styleTable) and t.interface(styleTable) or nil

	return propsInterface, styleInterface
end

-- Private helper function to print a traceback with a file name and line number
-- if the parser runs into a problem.
function DocParser:__assert(value, errorText)
	if not value then
		assert(false, lineTraceback:format(errorText, self.name, self.line))
	end
end

-- Private helper function to add a prop's info to the given addTable, as strings
function DocParser:__parseProp(addTable, tabs, line)
	if #line > 0 then
		if tabs == 2 then
			-- Add a new prop
			local separator = line:find(":")
			self:__assert(separator, formattingError)
			local prop = line:sub(1, separator - 1)
			local values = prop:split(" ")
			self:__assert(#values == 2, formattingError)
			local propName = values[2]
			local propType = values[1]
			local comment = line:sub(separator + 2)
			table.insert(addTable, {
				Name = propName,
				Type = propType,
				Comment = comment,
			})
		elseif tabs > 2 then
			-- Add additional comments to the current prop
			local currentComment = addTable[#addTable].Comment
			addTable[#addTable].Comment = currentComment and string.format("%s\n%s", currentComment, line) or line
		else
			self:__assert(false, indentationError)
		end
	end
end

-- Private helper function used by toInterface to create a t check from a prop.
function DocParser.__addCheckForProp(addTable, prop, isOptional)
	local propName = prop.Name
	local propType = prop.Type
	local existingProp = addTable[propName]
	local newProp
	local isEnum = string.find(propType, "Enum")
	local isArray = string.find(propType, "array[", nil, true)
	if isEnum then
		newProp = t.enum(Enum[propType:sub(isEnum + 5)])
	elseif isArray then
		local elementType = t[propType:sub(isArray + 6, propType:len() - 1)]
		if elementType then
			newProp = t.array(elementType)
		end
	else
		newProp = FrameworkTypes[propType] or t[propType]
	end
	assert(newProp, string.format("`%s` is not a valid t type.", propType))
	if isOptional then
		newProp = t.optional(newProp)
	end
	if existingProp ~= nil then
		addTable[propName] = t.union(existingProp, newProp)
	else
		addTable[propName] = newProp
	end
end

return DocParser
