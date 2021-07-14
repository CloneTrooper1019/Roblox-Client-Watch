return function()
	local Framework = script.Parent.Parent
	local Util = require(Framework.Util)
	local FlagsList = Util.Flags.new({
		FFlagStudioDevFrameworkPackage = {"StudioDevFrameworkPackage"},
	})

	local mock
	local isUsedAsPackage = require(Framework.Util.isUsedAsPackage)
	if FlagsList:get("FFlagStudioDevFrameworkPackage") and isUsedAsPackage() then
		mock = require(Framework.Parent.mock)
	else
		mock = require(Framework.packages.Dev.mock)
	end

	local Spy = mock.Spy
	local getCalls = mock.getCalls
	local Roact = require(Framework.Parent.Roact)
	local provide = require(Framework.ContextServices.provide)
	local mapToProps = require(Framework.ContextServices.mapToProps)
	local MockPlugin = require(Framework.TestHelpers.Instances.MockPlugin)

	local PluginActions = require(script.Parent.PluginActions)

	it("should be providable as a ContextItem and call CreatePluginAction", function()
		local plugin = MockPlugin.new()

		local spy, wrapped = Spy.new(function(self, id)

			return {
				id = id
			}
		end)

		plugin.CreatePluginAction = wrapped

		local dummyActionId = 'dummy'
		local namespacedDummyActionId = "MockPlugin_" .. dummyActionId
		local text = 'My action description'

		local dummyAction = {
			id = dummyActionId,
			text = text
		}

		local pluginActions = PluginActions.new(plugin, {
			dummyAction
		})

		local didRender = false
		local TestElement = Roact.Component:extend("TestElement")
		function TestElement:render()
			didRender = true

			local action = self.props.PluginActions:get(dummyActionId)
			expect(action.id).to.equal(namespacedDummyActionId)

			return Roact.createElement("Frame")
		end
		mapToProps(TestElement, {
			PluginActions = PluginActions,
		})

		local element = provide({pluginActions}, {
			Frame = Roact.createElement(TestElement),
		})

		local instance = Roact.mount(element)

		expect(didRender).to.equal(true);

		local calls = getCalls(spy)
		expect(#calls).to.equal(1)

		local args = calls[1].args

		expect(args[2]).to.equal(namespacedDummyActionId)
		expect(args[3]).to.equal(text)
		expect(args[4]).to.equal("")
		expect(args[5]).to.equal("")
		expect(args[6]).to.equal(true)

		Roact.unmount(instance)
	end)
end
