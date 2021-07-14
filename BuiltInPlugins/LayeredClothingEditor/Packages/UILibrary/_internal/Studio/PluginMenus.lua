--[[
	Returns a Separator constant and makePluginMenu. makePluginMenu creates a PluginMenu made up of 
	PluginActions, or SubMenus of PluginActions.

	Parameters:
		plugin = The Roblox plugin instance that this menu belongs to
		entries = a list of actions to be displayed in the menu. Actions can be a PluginAction instance
			created externally, the SEPARATOR constant, or a dictionary containing action information that
			will be used to create a new action. Action dictionaries have the following fields:

			Text = the action text displayed in the menu
			ItemSelected = a callback that is invoked whenever the action is clicked
			[Key] = an optional value provided as an argument to the ItemSelected callback. Can be nil if you
				aren't sharing ItemSelected callbacks between actions
			[Icon] =  an optional icon displayed next to the action in the menu
			[Checked] optionally show a check mark next to the action in the menu. Ignored if the action is in
				a selection	submenu (see below)
			[Enabled] optionally control whether an action is selectable or not. Defaults to true

			If you insert one or more actions into the dictionary, the dictionary it was inserted into will
			become a submenu. Submenus have the same properties as actions since the submenu is an action,
			but ItemSelected will never be invoked.

			There is also a special kind of selection submenu that will automatically display a checkmark next
			to a selected action. If you include a CurrentKey field in the submenu, any action whose Key field
			equals CurrentKey will have a checkmark displayed. It is the responsibility of the consumer to use
			the actions' ItemSelected callback to update the CurrentKey field of the submenu.

	Examples:

	Explorer context menu:
	{
		-- Ordinary actions
		{ Text = "Cut", Icon = "rbxasset://textures/cutIcon.png", ItemSelected = function() cutSelection() end },
		{ Text = "Copy", Icon = "rbxasset://textures/copyIcon.png", ItemSelected = function() copySelection() end },
		{ Text = "Paste Into", Enabled = false, ItemSelected = function() pasteIntoSelection() end },
		...
		PluginMenus.Separator,
		...
		-- A submenu action with two inner items (the inner items can also be submenus)
		{
			Text = "Insert Object", Icon = "insertObjects.png", Enabled = true,
			{ Text = "Part", Key = partKey, Icon = "part.png", ItemSelected = function(key) insertObject(key) end },
			{ Text = "Wedge", Key = wedgeKey, Icon = "wedge.png", ItemSelected = function(key) insertObject(key) end },
			...
		},
	}

	Tools Context Menu
	{
		{ Text = "Collisions Enabled", Checked = true, ItemSelected = function(text) toggleCollisions() end },
		{ Text = "Constraints Enabled", Checked = false, ItemSelected = function(text) toggleConstraints() end },
		{
			CurrentKey = alwaysKey, Text = "Join Mode", Icon = "rbxasset://textures/joinMode.png",
			{ Text = "Always", Key = alwaysKey, ItemSelected = function(key) joinModeSelected(key) end },
			{ Text = "None", Key = noneKey, ItemSelected = function(key) joinModeSelected(key) end },
		}
	}
]]

-- Importing HttpService only for GenerateGUID
local HttpService = game:GetService("HttpService")

local Library = script.Parent.Parent
local Symbol = require(Library.Utils.Symbol)

local SEPARATOR = Symbol.named("(PluginMenuSeparator)")

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

local function createPluginMenu(plugin, entries, subMenus, connections)
	local menu = plugin:CreatePluginMenu(newId(), entries.Text, entries.Icon)

	for _, entry in ipairs(entries) do
		if entry == SEPARATOR then
			menu:AddSeparator()
		elseif typeof(entry) == "Instance" and entry:IsA("PluginAction") then
			menu:AddAction(entry)
		elseif typeof(entry) == "table" then
			if #entry > 0 then
				local subMenu = createPluginMenu(plugin, entry, subMenus, connections)
				table.insert(subMenus, subMenu)
				menu:AddMenu(subMenu)
			else
				local action = menu:AddNewAction(newId(), entry.Text, entry.Icon)
				action.Enabled = (entry.Enabled == nil) and true or entry.Enabled

				if entries.CurrentKey then
					action.Checked = entries.CurrentKey == entry.Key
				else
					action.Checked = entry.Checked
				end

				connectAction(connections, action, entry, entry.Key)
			end
		elseif entry then -- Ignore false/nil for when plugins do {xyz, fflag and abc, ...}
			error("Unsupported action "..tostring(entry))
		end
	end

	return menu
end

local function makePluginMenu(plugin, entries)
	local subMenus = {}
	local connections = {}

	local menu = createPluginMenu(plugin, entries, subMenus, connections)

	menu:ShowAsync()
	for _, subMenu in ipairs(subMenus) do
		subMenu:Destroy()
	end
	menu:Destroy()
end

return {
	makePluginMenu = makePluginMenu,
	Separator = SEPARATOR,
}