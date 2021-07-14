--[[
	Performs a simple equality check and throws an error if _left_ is not equal to _right_.

	The formatted error message can be customized, which by default provides a serialization of
	both inputs using Dash.pretty.

	The `left` and `right` values are available to be referenced in the formatted message.
]]

local Dash = script.Parent

local function assertEqual(left: any, right: any, formattedErrorMessage: string?)
	if left ~= right then
		local Error = require(Dash.Error)
		local TypeError = Error.new("AssertError", formattedErrorMessage or [[Left {left:?} does not equal right {right:?}]])
		TypeError:throw({
			left = left,
			right = right
		})
	end
end

return assertEqual