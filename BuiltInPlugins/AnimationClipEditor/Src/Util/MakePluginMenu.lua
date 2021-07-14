-- Importing HttpService only for GenerateGUID
local HttpService = game:GetService("HttpService")

local Plugin = script.Parent.Parent.Parent
local Constants = require(Plugin.Src.Util.Constants)

local function newId()
	return HttpService:GenerateGUID()
end

local function disconnectAll(connections)
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end
end

-- Callbacks can either be defined on each item (called with the value), or on the
-- parent menu (called with the item table).
local function connectAction(connections, action, parent, item)
	table.insert(connections, action.Triggered:Connect(function()
		disconnectAll(connections)

		if parent.ItemSelected then
			parent.ItemSelected(item)
		elseif item.ItemSelected then
			item.ItemSelected(item.Value ~= nil and item.Value or item.Name)
		end
	end))
end

local function makePluginMenuInternal(plugin, parent, connections)
	local items = parent.Items
	local label = parent.Name
	local currentValue = parent.CurrentValue

	local menu = plugin:CreatePluginMenu(newId(), label)
	for _, item in ipairs(items) do
		if typeof(item) == "table" then
			if item.Items then	-- item has items of its own, it's a submenu
				local subMenu = makePluginMenuInternal(plugin, item, connections)
				menu:AddMenu(subMenu)
			else
				local action = menu:AddNewAction(newId(), item.Name)
				action.Checked = currentValue ~= nil and item.Value == currentValue
				action.Enabled = (item.Enabled ~= false)

				connectAction(connections, action, parent, item)
			end
		elseif typeof(item) == "EnumItem" then
			local action = menu:AddNewAction(newId(), item)
			action.Checked = currentValue ~= nil and item.Value == currentValue
			connectAction(connections, action, parent, item)
		elseif typeof(item) == "Instance" and item.ClassName == "PluginAction" then
			menu:AddAction(item)
		elseif item == Constants.MENU_SEPARATOR then
			menu:AddSeparator()
		end
	end

	return menu
end

local function makePluginMenu(plugin, items)
	local rootItem = {Items = items}
	local connections = {}

	local menu = makePluginMenuInternal(plugin, rootItem, connections)
	menu:ShowAsync()

	disconnectAll(connections)
end

return makePluginMenu
