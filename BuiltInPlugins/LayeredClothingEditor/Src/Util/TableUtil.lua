local TableUtil = {}

function TableUtil:initNested(tab, keys, value)
	local current = tab
	for index, key in ipairs(keys) do
		if index < #keys then
			if not current[key] then
				current[key] = {}
			end
			current = current[key]
		end
	end
	if current[keys[#keys]] == nil then
		current[keys[#keys]] = value
	end
end

function TableUtil:setNested(tab, keys, value)
	local current = tab
	for index, key in ipairs(keys) do
		if index < #keys then
			if not current[key] then
				current[key] = {}
			end
			current = current[key]
		end
	end
	current[keys[#keys]] = value
end

function TableUtil:insertNested(tab, keys, value)
	local current = tab
	for _, key in ipairs(keys) do
		if not current[key] then
			current[key] = {}
		end
		current = current[key]
	end

	table.insert(current, value)
end

function TableUtil:getNested(tab, keys)
	local current = tab
	for _, key in ipairs(keys) do
		if current[key] then
			current = current[key]
		else
			return nil
		end
	end

	return current
end

return TableUtil