local MockPluginToolbarButton = require(script.Parent.MockPluginToolbarButton)

local MockPluginToolbar = {}
MockPluginToolbar.__index = MockPluginToolbar

function MockPluginToolbar.new(plugin, id)
	local self = {
		_plugin = plugin,
		_id = id,

		Name = id,
		Text = id,

		_buttons = {},
	}

	setmetatable(self, MockPluginToolbar)
	return self
end

function MockPluginToolbar:Destroy()
	self._plugin = nil
	for _, button in pairs(self._buttons) do
		button:Destroy()
	end
	self._buttons = {}
end

function MockPluginToolbar:CreateButton(id, tooltip, icon, text)
	local hasId = id and #id > 0
	local hasTooltip = tooltip and #tooltip > 0
	local hasIcon = icon and #icon > 0
	local hasText = text and #text > 0

	local useLegacyBehavior = hasTooltip or hasIcon or hasText

	local finalId
	local finalText

	if useLegacyBehavior then
		finalId = hasId and id or tooltip
		finalText = hasText and text or (hasId and id or tooltip)
	else
		finalId = id
		finalText = id

		assert(#finalId > 0, ("Toolbar %s tried to create a button with empty id"):format(self._id))
	end

	assert(not self._buttons[finalId], ("Toolbar %s already has a button with id %s"):format(self._id, finalId))
	local button = MockPluginToolbarButton.new(self._plugin, self, finalId)
	self._buttons[finalId] = button

	button.Text = finalText
	if useLegacyBehavior then
		button.Tooltip = tooltip or ""
		button.Icon = icon or ""
	end

	return button
end

return MockPluginToolbar
