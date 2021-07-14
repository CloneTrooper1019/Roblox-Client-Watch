
--[[
	Creates a PluginMenu made up of PluginActions

	Parameters:
		plugin = The Roblox plugin instance that this menu belongs to
		name = unique name for this PluginMenu
		actions = an array of PluginActions and/or SubMenus in the following expected format:
		{
			[pluginAction],
			...,
		}
]]

-- Importing HttpService only for GenerateGUID
local HttpService = game:GetService("HttpService")

local function newId()
	return HttpService:GenerateGUID()
end

local function connectAction(connections, action, entry, item)
	table.insert(connections, action.Triggered:Connect(function()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
		entry.ItemSelected(item)
	end))
end

local function makePluginMenu(plugin, name, entries)
	local menu = plugin:CreatePluginMenu(name)
	local connections = {}

	for _, entry in ipairs(entries) do
		if type(entry) == "table" then
				local action = menu:AddNewAction(newId(), entry.Name)
				action.Checked = entry.IsEnabled
				connectAction(connections, action, entry, entry.Name)
		end
	end

	menu:ShowAsync()
	menu:Destroy()
end

return makePluginMenu