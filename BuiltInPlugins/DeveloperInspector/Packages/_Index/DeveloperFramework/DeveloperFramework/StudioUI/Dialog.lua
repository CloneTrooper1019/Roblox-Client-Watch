--[[
	A PluginGui which floats as a subwindow, and can be modal.

	Required Props:
		string Title: The title text displayed at the top of the widget.
		Vector2 Size: The initial size of the widget, in pixels.
		callback OnClose: A function which is used to define the behavior
			when the user clicks the X button attached to this widget.
		Plugin Plugin: A Plugin ContextItem, which is provided via mapToProps.

	Optional Props:
		boolean Enabled: Whether the widget is currently visible.
		boolean Modal: Whether the widget blocks input to other windows.
		Enum.ZIndexBehavior ZIndexBehavior: The ZIndexBehavior of the widget.
		boolean Resizable: Whether the widget can be resized.
		Vector2 MinSize: The minimum size of the widget, in pixels.
			If the widget is not resizable, this property is not required.
		boolean CreateWidgetImmediately: C++ method for creating a widget yields, which can cause issues with Roact/Rodux.
			That method is run in its own thread, but that means creation of the widget is delayed.
			Set this to false to create the widget immediately instead. Mostly useful for unit tests.
]]
local HttpService = game:GetService("HttpService")

local Framework = script.Parent.Parent
local Typecheck = require(Framework.Util).Typecheck
local createPluginWidget = require(Framework.StudioUI.createPluginWidget)

local Dialog = createPluginWidget("Dialog", function(props)
	local plugin = props.Plugin:get()

	local options = {
		Title = props.Title,
		Size = props.Size,
		MinSize = props.MinSize,
		Resizable = props.Resizable,
		Modal = props.Modal,
	}
	local id = props.Title .. HttpService:GenerateGUID()
	local widget = plugin:CreateQWidgetPluginGui(id, options)
	widget.Name = props.Title
	if props.ZIndexBehavior then
		widget.ZIndexBehavior = props.ZIndexBehavior
	end
	return widget
end)

Typecheck.wrap(Dialog, script)

return Dialog
