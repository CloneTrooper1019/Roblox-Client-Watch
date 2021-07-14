return function(tab, keyPath)
	local currentNode = tab
	for _, key in ipairs(keyPath:split(".")) do
		if not currentNode[key] then
			return nil
		end

		currentNode = currentNode[key]
	end

	return currentNode
end
