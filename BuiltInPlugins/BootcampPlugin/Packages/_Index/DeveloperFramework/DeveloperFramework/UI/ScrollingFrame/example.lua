return function(plugin)
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local ContextServices = require(Framework.ContextServices)
	local Plugin = ContextServices.Plugin
	local Theme = ContextServices.Theme

	local UI = require(Framework.UI)
	local ScrollingFrame = UI.ScrollingFrame

	local StudioUI = require(Framework.StudioUI)
	local Dialog = StudioUI.Dialog
	local StudioFrameworkStyles = StudioUI.StudioFrameworkStyles

	local pluginItem = Plugin.new(plugin)

	local Util = require(Framework.Util)
	local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
	local StudioTheme = require(Framework.Style.Themes.StudioTheme)

	local theme
	if THEME_REFACTOR then
		theme = StudioTheme.new()
	else
		theme = Theme.new(function(theme, getColor)
			return {
				Framework = StudioFrameworkStyles.new(theme, getColor)
			}
		end)
	end

	local ExampleButton = Roact.PureComponent:extend("ExampleButton")

	function ExampleButton:init()
		self.state = {
			enabled = true,
		}

		self.close = function()
			self:setState({
				enabled = false,
			})
		end
	end

	function ExampleButton:render()
		if self.state.enabled == false then
			return nil
		end

		local children = {
			Layout = Roact.createElement("UIListLayout"),
		}
		for i = 1, 10, 1 do
			children[tostring(i)] = Roact.createElement("TextLabel", {
				Text = "I'm an example child!",
				Size = UDim2.new(1, 0, 0, 30),
				LayoutOrder = i,
			})
		end

		return ContextServices.provide({pluginItem, theme}, {
			Main = Roact.createElement(Dialog, {
				Enabled = self.state.enabled,
				Title = "ToggleButton Example",
				Size = Vector2.new(200, 200),
				Resizable = false,
				OnClose = self.close,
			}, {

				-- TO DO : update example to be an infinite scroller
				Scroller = Roact.createElement(ScrollingFrame, {
					Size = UDim2.new(1, 0, 1, 0),
				}, children)
			})
		})
	end

	local element = Roact.createElement(ExampleButton)
	local handle = Roact.mount(element)

	local function stop()
		Roact.unmount(handle)
	end

	return stop
end
