-- Helper to verify that 2 sets have exactly the same keys
return function(result, expected)
	for k in pairs(result) do
		if not expected[k] then
			return false
		end
	end

	for k in pairs(expected) do
		if not result[k] then
			return false
		end
	end

	return true
end
