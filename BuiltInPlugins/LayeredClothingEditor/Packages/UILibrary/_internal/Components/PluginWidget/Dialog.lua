--[[
	Creates a QWidgetPluginGui dialog.

	Props:
		table Options = An options table to pass to the Create function.

		bool Enabled = Whether the dialog is currently enabled.
		string Title = The title to display at the top of the dialog.
		string Name = The name of the dialog.
		ZIndexBehavior ZIndexBehavior = The ordering behavior of elements
			in the dialog based on ZIndex.

		function OnClose() = A callback for when the dialog closes.
]]

local Library = script.Parent.Parent.Parent

local HttpService = game:GetService("HttpService")

local Plugin = require(Library.Plugin)
local getPlugin = Plugin.getPlugin
local Roact = require(Library.Parent.Parent.Roact)

local Focus = require(Library.Focus)
local FocusProvider = Focus.Provider

local Dialog = Roact.PureComponent:extend("Dialog")

function Dialog:init(props)
	local options = props.Options
	local title = props.Title or ""
	local name = props.Name or title
	local id = title .. HttpService:GenerateGUID()
	local zIndexBehavior = props.ZIndexBehavior or Enum.ZIndexBehavior.Sibling

	local plugin = getPlugin(self)
	local widget = plugin:CreateQWidgetPluginGui(id, options)
	widget.Name = name
	widget.ZIndexBehavior = zIndexBehavior
	self.widget = widget

	if props.OnClose and widget:IsA("PluginGui") then
		widget:BindToClose(function()
			props.OnClose()
		end)
	end
end

function Dialog:updateWidget()
	local props = self.props
	local enabled = props.Enabled
	local title = props.Title

	local widget = self.widget
	if widget then
		if enabled ~= nil then
			widget.Enabled = enabled
		end

		if title ~= nil and widget:IsA("PluginGui") then
			widget.Title = title
		end
	end
end

function Dialog:didMount()
	self:updateWidget()
end

function Dialog:didUpdate()
	self:updateWidget()
end

function Dialog:render()
	return self.widget.Enabled and Roact.createElement(Roact.Portal, {
		target = self.widget,
	}, {
		FocusProvider = Roact.createElement(FocusProvider, {
			pluginGui = self.widget,
		}, self.props[Roact.Children]),
	})
end

function Dialog:willUnmount()
	if self.changedConnection then
		self.changedConnection:Disconnect()
	end
	if self.widget then
		self.widget:Destroy()
	end
end

return Dialog