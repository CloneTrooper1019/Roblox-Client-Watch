local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local StudioUI = require(Framework.StudioUI)
local PluginToolbar = StudioUI.PluginToolbar
local PluginButton = StudioUI.PluginButton

local didRun = false
local ranAgainWarning = [[
This example can only be run once, due to a bug with PluginToolbar and PluginToolbarButton.
The bug is filed under CLISTUDIO-20687.]]

return function()
	if didRun then
		warn(ranAgainWarning)
		return
	end
	didRun = true

	local ExampleToolbar = Roact.PureComponent:extend("ExampleToolbar")

	function ExampleToolbar:init()
		self.state = {
			activeButton = 1,
		}

		self.toggleActiveButton = function(button)
			print(string.format("Button %s was clicked.", button))
			self:setState({
				activeButton = button,
			})
		end
	end

	function ExampleToolbar:render()
		local activeButton = self.state.activeButton
		return Roact.createElement(PluginToolbar, {
			Title = "Test Toolbar",
			RenderButtons = function(toolbar)
				return {
					Button1 = Roact.createElement(PluginButton, {
						Toolbar = toolbar,
						Title = "Button 1",
						Active = activeButton == 1,
						OnClick = function()
							self.toggleActiveButton(1)
						end,
					}),

					Button2 = Roact.createElement(PluginButton, {
						Toolbar = toolbar,
						Title = "Button 2",
						Active = activeButton == 2,
						OnClick = function()
							self.toggleActiveButton(2)
						end,
					}),
				}
			end,
		})
	end
	
	return Roact.createElement(ExampleToolbar)
end
