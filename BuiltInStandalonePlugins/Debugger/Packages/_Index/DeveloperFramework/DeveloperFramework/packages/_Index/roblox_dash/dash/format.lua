--[[
	Returns the _format_ string with placeholders `{...}` substituted with readable representations
	of the subsequent arguments.
	This function is a simpler & more powerful version of `string.format`, inspired by `format!`
	in Rust.
	
	* `{}` formats and prints the next argument using `:format()` if available, or a suitable
		default representation depending on its type.
	* `{blah}` formats and prints the key "blah" of the 1st argument
	* `{2}` formats and prints the 2nd argument.
	* `{#2}` prints the length of the 2nd argument.
	Display parameters can be combined after a `:` in the curly braces. Any format parameters used
	in `string.format` can be used here, along with these extras:
	* `{:?}` formats any value using `pretty`.
	* `{:#?}` formats any value using multiline `pretty`.
	@example
		local props = {"teeth", "claws", "whiskers", "tail"}
		format("{:?} is in {:#?}", "whiskers", props)
		-> '"whiskers" is in {"teeth", "claws", "whiskers", "tail"}'
	@example
		format("The time is {:02}:{:02}", 2, 4) -> "The time is 02:04"
	@example
		format("The color blue is #{:06X}", 255) -> "The color blue is #0000FF"
	@usage Escape `{` with `{{` and `}` similarly with `}}`.
	@usage See [https://developer.roblox.com/articles/Format-String](https://developer.roblox.com/articles/Format-String)
		for complete list of formating options and further use cases.
]]

local Dash = script.Parent
local assertEqual = require(Dash.assertEqual)
local formatValue = require(Dash.formatValue)
local splitOn = require(Dash.splitOn)
local startsWith = require(Dash.startsWith)

local concat = table.concat
local insert = table.insert

local function format(formatString: string, ...)
	assertEqual(typeof(formatString), "string", [[Attempted to call Dash.format with argument #1 of type {left:?} not {right:?}]])
	local args = {...}
	local argIndex = 1
	local texts, subs = splitOn(formatString, "{[^{}]*}")
	local result = {}
	-- Iterate through possible curly-brace matches, ignoring escaped and substituting valid ones
	for i, text in pairs(texts) do
		local unescaped = text:gsub("{{", "{"):gsub("}}", "}")
		insert(result, unescaped)
		local placeholder = subs[i] and subs[i]:sub(2, -2)
		if placeholder then
			-- Ensure that the curly braces have not been escaped
			local escapeMatch = text:gmatch("{+$")()
			local isEscaped = escapeMatch and #escapeMatch % 2 == 1
			if not isEscaped then
				-- Split the placeholder into left & right parts pivoting on the central ":"
				local placeholderSplit = splitOn(placeholder, ":")
				local isLength = startsWith(placeholderSplit[1], "#")
				local argString = isLength and placeholderSplit[1]:sub(2) or placeholderSplit[1]
				local nextIndex = tonumber(argString)
				local displayString = placeholderSplit[2]
				local arg = "nil"
				if nextIndex then
					-- Return the next argument
					arg = args[nextIndex]
				elseif argString:len() > 0 then
					-- Print a child key of the 1st argument
					local argChild = args[1] and args[1][argString]
					if argChild ~= nil then
						arg = argChild
					end
				else
					arg = args[argIndex]
					argIndex = argIndex + 1
				end
				if isLength then
					arg = #arg
				end
				-- Format the selected value
				insert(result, formatValue(arg, displayString or ""))
			else
				local unescapedSub = placeholder
				insert(result, unescapedSub)
			end
		end
	end
	return concat(result, "")
end

return format