--[[
	Creates the actions used by the plugin.
]]

local ACTION_KEYS = {
	CycleHandles = "T",
	LockControl = "R",

	-- History
	Undo = "Ctrl+Z",
	Redo = "Ctrl+Y",
}

local function makeAction(plugin, localization, key, shortcut)
	shortcut = shortcut ~= "" and shortcut or nil
	return {
		id = key,
		text = localization:getText("Actions", key),
		defaultShortcut = shortcut,
		allowBinding = false,
	}
end

return function(plugin, localization)
	local actions = {}
	for key, shortcut in pairs(ACTION_KEYS) do
		actions[key] = makeAction(plugin, localization, key, shortcut)
	end

	return actions
end