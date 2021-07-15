--[[
	Format a specific _value_ using the specified _displayString_.
	@example
		formatValue(255, "06X") --> "0000FF"
	@example
		formatValue(255.5) --> "255.5"
	@see `format` - for a full description of valid display strings.
]]

local Dash = script.Parent
local assertEqual = require(Dash.assertEqual)

local function formatValue(value: any, displayString: string): string
	displayString = displayString or ""
	assertEqual(typeof(displayString), "string", [[Attempted to call Dash.formatValue with argument #2 of type {left:?} not {right:?}]])
	-- Inline require to prevent infinite require cycle
	local displayTypeStart, displayTypeEnd = displayString:find("[A-Za-z#?]+")
	if displayTypeStart then
		local displayType = displayString:sub(displayTypeStart, displayTypeEnd)
		local formatAsString =
		"%" .. displayString:sub(1, displayTypeStart - 1) .. displayString:sub(displayTypeEnd + 1) .. "s"
		-- Pretty print values
		local pretty = require(Dash.pretty)
		if displayType == "#?" then
			-- Multiline print a value
			return formatAsString:format(pretty(value, {multiline = true}))
		elseif displayType == "?" then
			-- Inspect a value
			return formatAsString:format(pretty(value))
		end
		return ("%" .. displayString):format(value)
	else
		local displayType = "s"
		if type(value) == "number" then
			-- Correctly display floats or integers
			local _, fraction = math.modf(value)
			displayType = fraction == 0 and "d" or "f"
		end
		return ("%" .. displayString .. displayType):format(tostring(value))
	end
end

return formatValue