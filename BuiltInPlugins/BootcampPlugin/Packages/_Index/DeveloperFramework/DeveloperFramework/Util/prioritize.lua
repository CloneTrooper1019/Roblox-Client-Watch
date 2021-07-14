-- helper function to return : props > style > defaults
return function(prop, style, default)
	if prop ~= nil then
		return prop
	elseif style ~= nil then
		return style
	end

	return default
end