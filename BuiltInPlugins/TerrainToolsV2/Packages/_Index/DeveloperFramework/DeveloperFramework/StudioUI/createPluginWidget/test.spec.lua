return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local createPluginWidget = require(script.Parent)
	local ContextServices = require(Framework.ContextServices)
	local ShowOnTop = require(Framework.UI).ShowOnTop

	it("should return a Roact component", function()
		local plugin = ContextServices.Plugin.new()

		local widget = createPluginWidget("Test", function()
			return Instance.new("ScreenGui")
		end)

		local element = ContextServices.provide({plugin}, {
			Widget = Roact.createElement(widget, {
				CreateWidgetImmediately = true,
				OnClose = function()
				end,
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should call the createWidget function", function()
		local plugin = ContextServices.Plugin.new()
		local container = Instance.new("Folder")
		local screenGui = Instance.new("ScreenGui")

		local widget = createPluginWidget("Test", function()
			screenGui.Parent = container
			return screenGui
		end)
		local element = ContextServices.provide({plugin}, {
			Widget = Roact.createElement(widget, {
				CreateWidgetImmediately = true,
				OnClose = function()
				end,
			})
		})

		local instance = Roact.mount(element, container)

		local gui = container:FindFirstChildOfClass("ScreenGui")
		expect(gui).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should expect a Plugin ContextItem", function()
		local widget = createPluginWidget("Test", function()
			return Instance.new("ScreenGui")
		end)
		local element = Roact.createElement(widget, {
			CreateWidgetImmediately = true,
			OnClose = function()
			end,
		})

		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should expect an OnClose prop", function()
		local plugin = ContextServices.Plugin.new()

		local widget = createPluginWidget("Test", function()
			return Instance.new("ScreenGui")
		end)
		local element = ContextServices.provide({plugin}, {
			Widget = Roact.createElement(widget, {
				CreateWidgetImmediately = true,
			})
		})

		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should set the widget properties", function()
		local plugin = ContextServices.Plugin.new()
		local container = Instance.new("Folder")
		local screenGui = Instance.new("ScreenGui")

		local widget = createPluginWidget("Test", function()
			screenGui.Parent = container
			return screenGui
		end)
		local element = ContextServices.provide({plugin}, {
			Widget = Roact.createElement(widget, {
				CreateWidgetImmediately = true,
				Title = "TestTitle",
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				OnClose = function()
				end,
			})
		})

		local instance = Roact.mount(element, container)

		expect(screenGui.Name).to.equal("TestTitle")
		expect(screenGui.ZIndexBehavior).to.equal(Enum.ZIndexBehavior.Sibling)

		Roact.unmount(instance)
	end)

	it("should render its children inside the widget", function()
		local plugin = ContextServices.Plugin.new()
		local container = Instance.new("Folder")
		local screenGui = Instance.new("ScreenGui")

		local widget = createPluginWidget("Test", function()
			screenGui.Parent = container
			return screenGui
		end)
		local element = ContextServices.provide({plugin}, {
			Widget = Roact.createElement(widget, {
				CreateWidgetImmediately = true,
				OnClose = function()
				end,
			}, {
				ChildFrame = Roact.createElement("Frame"),
			})
		})

		local instance = Roact.mount(element, container)

		local gui = container:FindFirstChildOfClass("ScreenGui")
		expect(gui.ChildFrame).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should destroy the widget on unmount", function()
		local plugin = ContextServices.Plugin.new()
		local container = Instance.new("Folder")
		local screenGui = Instance.new("ScreenGui", container)

		local widget = createPluginWidget("Test", function()
			return screenGui
		end)
		local element = ContextServices.provide({plugin}, {
			Widget = Roact.createElement(widget, {
				CreateWidgetImmediately = true,
				OnClose = function()
				end,
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)

		expect(screenGui.Parent).to.equal(nil)
	end)

	it("should provide a Focus to the widget's children", function()
		local plugin = ContextServices.Plugin.new()
		local container = Instance.new("Folder")
		local screenGui = Instance.new("ScreenGui")

		local widget = createPluginWidget("Test", function()
			screenGui.Parent = container
			return screenGui
		end)
		local element = ContextServices.provide({plugin}, {
			Widget = Roact.createElement(widget, {
				CreateWidgetImmediately = true,
				OnClose = function()
				end,
			}, {
				ShowOnTop = Roact.createElement(ShowOnTop)
			})
		})

		local instance = Roact.mount(element, container)
		Roact.unmount(instance)
	end)
end
