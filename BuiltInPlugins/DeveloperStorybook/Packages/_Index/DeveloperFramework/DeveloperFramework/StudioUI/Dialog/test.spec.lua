return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local Dialog = require(script.Parent)
	local ContextServices = require(Framework.ContextServices)

	local function mockPlugin()
		local plugin = {
			CreateQWidgetPluginGui = function()
				return Instance.new("ScreenGui")
			end,
		}

		return ContextServices.Plugin.new(plugin)
	end

	it("should create and destroy without errors", function()
		local element = ContextServices.provide({mockPlugin()}, {
			Dialog = Roact.createElement(Dialog, {
				CreateWidgetImmediately = true,
				Title = "Test",
				Size = Vector2.new(),
				OnClose = function()
				end,
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should expect an OnClose prop", function()
		local element = ContextServices.provide({mockPlugin()}, {
			Dialog = Roact.createElement(Dialog, {
				CreateWidgetImmediately = true,
			}),
		})

		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)
end
