--[[
	A PluginGui which can be docked to the corners of the Studio window,
	or float as a subwindow.

	Required Props:
		string Title: The title text displayed at the top of the widget.
		boolean Enabled: Whether the widget is currently visible.
		Vector2 Size: The initial size of the widget, in pixels.
		Enum.InitialDockState InitialDockState: The initial dock position of the widget.
		callback OnClose: A function which is used to define the behavior
			when the user clicks the X button attached to this widget.
		Plugin Plugin: A Plugin ContextItem, which is provided via mapToProps.

	Optional Props:
		Vector2 MinSize: The minimum size of the widget, in pixels.
		Enum.ZIndexBehavior ZIndexBehavior: The ZIndexBehavior of the widget.

		boolean ShouldRestore: Whether the widget should restore to its previous
			enabled state and position on creation, if the widget was created before.

		callback OnWidgetRestored: A callback for when the widget
			is restored to its previous position and enabled state. Passes the
			new enabled state as a parameter.

		boolean CreateWidgetImmediately: C++ method for creating a widget yields, which can cause issues with Roact/Rodux.
			That method is run in its own thread, but that means creation of the widget is delayed.
			Set this to true to create the widget immediately instead. Mostly useful for unit tests.
]]

local expectsRestoredMessage = [[
DockWidget expects an OnWidgetRestored function if ShouldRestore is true.
This DockWidget may restore as enabled, so we need to listen for that!]]

local Framework = script.Parent.Parent
local Typecheck = require(Framework.Util).Typecheck
local createPluginWidget = require(Framework.StudioUI.createPluginWidget)

local DockWidget = createPluginWidget("DockWidget", function(props)
	local plugin = props.Plugin:get()

	local minSize = props.MinSize or Vector2.new(0, 0)

	local shouldRestore = props.ShouldRestore or false

	if shouldRestore then
		assert(props.OnWidgetRestored, expectsRestoredMessage)
	end

	local disregardRestoredEnabledState = not shouldRestore

	local info = DockWidgetPluginGuiInfo.new(
		props.InitialDockState,
		props.Enabled or false,
		disregardRestoredEnabledState,
		props.Size.X,
		props.Size.Y,
		minSize.X,
		minSize.Y)

	return plugin:CreateDockWidgetPluginGui(props.Title, info)
end)

Typecheck.wrap(DockWidget, script)

return DockWidget
