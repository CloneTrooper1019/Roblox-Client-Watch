local function join(...)
	local result = {}

	for i = 1, select("#", ...) do
		local source = select(i, ...)

		if source ~= nil then
			for key, value in pairs(source) do
				result[key] = value
			end
		end
	end

	return result
end

return join