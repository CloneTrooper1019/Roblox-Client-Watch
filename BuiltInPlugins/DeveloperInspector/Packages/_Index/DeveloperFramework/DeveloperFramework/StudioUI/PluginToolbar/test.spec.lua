return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local PluginToolbar = require(script.Parent)
	local ContextServices = require(Framework.ContextServices)

	local MockPlugin = require(Framework.TestHelpers.Instances.MockPlugin)

	local function mockPlugin()
		return ContextServices.Plugin.new(MockPlugin.new())
	end

	it("should create and destroy without errors", function()
		local element = ContextServices.provide({mockPlugin()}, {
			PluginToolbar = Roact.createElement(PluginToolbar, {
				Title = "Test",
				RenderButtons = function()
				end,
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should expect a Plugin ContextItem", function()
		local element = Roact.createElement(PluginToolbar, {
			Title = "Test",
			RenderButtons = function()
			end,
		})

		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should expect a Title prop", function()
		local element = ContextServices.provide({mockPlugin()}, {
			PluginToolbar = Roact.createElement(PluginToolbar, {
				RenderButtons = function()
				end,
			})
		})

		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should expect a RenderButtons prop", function()
		local element = ContextServices.provide({mockPlugin()}, {
			PluginToolbar = Roact.createElement(PluginToolbar, {})
		})

		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should render RenderButtons as children", function()
		local container = Instance.new("Folder")

		local element = ContextServices.provide({mockPlugin()}, {
			PluginToolbar = Roact.createElement(PluginToolbar, {
				Title = "Test",
				RenderButtons = function()
					return {
						Frame = Roact.createElement("Frame"),
						OtherFrame = Roact.createElement("Frame"),
					}
				end,
			})
		})

		local instance = Roact.mount(element, container)

		local frame = container:FindFirstChild("Frame")
		expect(frame).to.be.ok()
		local otherFrame = container:FindFirstChild("OtherFrame")
		expect(otherFrame).to.be.ok()

		Roact.unmount(instance)
	end)
end
