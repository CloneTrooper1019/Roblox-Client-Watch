--[[
	Returns false if the given table has any of the following:
		- a key that is neither a number or a string
		- a mix of number and string keys
		- number keys which are not exactly 1..#t
]]
return function(t)
	local containsNumberKey = false
	local containsStringKey = false
	local numberConsistency = true

	local index = 1
	for x, _ in pairs(t) do
		if type(x) == 'string' then
			containsStringKey = true
		elseif type(x) == 'number' then
			if index ~= x then
				numberConsistency = false
			end
			containsNumberKey = true
		else
			return false
		end

		if containsStringKey and containsNumberKey then
			return false
		end

		index = index + 1
	end

	if containsNumberKey then
		return numberConsistency
	end

	return true
end