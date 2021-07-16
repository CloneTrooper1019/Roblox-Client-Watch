return function(args)
	local msg = {}
	for i = 1, args.n do
		if type(args[i]) == "string" then
			table.insert(msg, '"' .. args[i] .. '"')
		else
			table.insert(msg, tostring(args[i]))
		end
	end
	return "{" .. table.concat(msg, ", ") .. "}"
end
