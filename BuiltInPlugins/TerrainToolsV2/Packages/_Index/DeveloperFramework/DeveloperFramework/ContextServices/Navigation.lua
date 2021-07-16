--[[
	Provides a global Navigation object to context.
	The Plugin constructor expects a navigation object.

	Example Usage with RoactNavigation:
		local navigationRoutes = {
			["MAIN_PAGE"] = RoactNavigation.withNavigation(
				function(navigation, focused)
					return ContextServices.provide({
						ContextServices.Navigation.new(navigation),
					}, {
						Roact.createElement("Frame")
					})
				end
			),
		}
		local rootNavigator = RoactNavigation.createStackNavigator({
			routes = navigationRoutes,
			initialRouteName = "MAIN_PAGE",
		})
		return RoactNavigation.createAppContainer(rootNavigator)

	Functions:
		get():
			Returns the navigation instance which was passed in Navigation.new.
]]

local Framework = script.Parent.Parent
local ContextItem = require(Framework.ContextServices.ContextItem)

return ContextItem:createSimple("Navigation")