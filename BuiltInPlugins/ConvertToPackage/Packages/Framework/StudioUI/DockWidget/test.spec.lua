return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local DockWidget = require(script.Parent)
	local ContextServices = require(Framework.ContextServices)

	local function mockPlugin()
		local plugin = {
			CreateDockWidgetPluginGui = function()
				return Instance.new("ScreenGui")
			end,
		}

		return ContextServices.Plugin.new(plugin)
	end

	it("should create and destroy without errors", function()
		local element = ContextServices.provide({mockPlugin()}, {
			DockWidget = Roact.createElement(DockWidget, {
				CreateWidgetImmediately = true,
				Enabled = true,
				Title = "Test",
				Size = Vector2.new(),
				MinSize = Vector2.new(),
				InitialDockState = Enum.InitialDockState.Float,
				OnClose = function()
				end,
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should expect an OnClose prop", function()
		local element = ContextServices.provide({mockPlugin()}, {
			DockWidget = Roact.createElement(DockWidget, {
				CreateWidgetImmediately = true,
				Enabled = true,
				Title = "Test",
				Size = Vector2.new(),
				MinSize = Vector2.new(),
				InitialDockState = Enum.InitialDockState.Float,
			}),
		})

		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should expect an OnWidgetRestored prop if ShouldRestore is true", function()
		local element = ContextServices.provide({mockPlugin()}, {
			DockWidget = Roact.createElement(DockWidget, {
				CreateWidgetImmediately = true,
				Enabled = true,
				Title = "Test",
				Size = Vector2.new(),
				MinSize = Vector2.new(),
				InitialDockState = Enum.InitialDockState.Float,
				ShouldRestore = true,
				OnClose = function()
				end,
			}),
		})

		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()

		element = ContextServices.provide({mockPlugin()}, {
			DockWidget = Roact.createElement(DockWidget, {
				CreateWidgetImmediately = true,
				Enabled = true,
				Title = "Test",
				Size = Vector2.new(),
				MinSize = Vector2.new(),
				InitialDockState = Enum.InitialDockState.Float,
				ShouldRestore = true,
				OnClose = function()
				end,
				OnWidgetRestored = function()
				end,
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
