local function deepJoin(t1, t2)
	local new = {}

	for key, value in pairs(t1) do
		if typeof(value) == "table" then
			if t2[key] and typeof(t2[key]) == "table" then
				new[key] = deepJoin(value, t2[key])
			else
				-- this essentially acts like a deepcopy to prevent
				-- references getting all tangled up
				new[key] = deepJoin(value, {})
			end
		else
			new[key] = value
		end
	end

	for key, value in pairs(t2) do
		if typeof(value) == "table" then
			if not t1[key] then
				new[key] = deepJoin(value, {})
			end
		else
			new[key] = value
		end
	end

	return new
end

return deepJoin
