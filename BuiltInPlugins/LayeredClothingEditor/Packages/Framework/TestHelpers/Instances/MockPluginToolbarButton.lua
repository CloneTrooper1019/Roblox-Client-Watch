local DevFrameworkRoot = script.Parent.Parent.Parent
local Signal = require(DevFrameworkRoot.Util.Signal)

local MockPluginToolbarButton = {}
MockPluginToolbarButton.__index = MockPluginToolbarButton

function MockPluginToolbarButton.new(plugin, toolbar, id)
	local self = {
		_plugin = plugin,
		_toolbar = toolbar,
		_id = id,

		Name = id,
		Tooltip = "",
		Icon = "",
		Text = "",
		Enabled = true,
		Active = false,
		ClickableWhenViewportHidden = true,

		Click = Signal.new(),
	}
	setmetatable(self, MockPluginToolbarButton)

	return self
end

function MockPluginToolbarButton:Destroy()
	self._toolbar = nil
	self._plugin = nil
end

function MockPluginToolbarButton:SetActive(newActive)
	if self._plugin and self.Active and not newActive then
		self._plugin:Deactivate()
	end

	self.Active = newActive
end

return MockPluginToolbarButton

