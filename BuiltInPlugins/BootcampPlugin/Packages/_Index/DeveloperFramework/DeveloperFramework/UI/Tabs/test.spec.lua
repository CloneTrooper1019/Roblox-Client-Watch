return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local provideMockContext = require(Framework.TestHelpers.provideMockContext)
	local TabsTypes = require(Framework.UI.Tabs.types)

	local Tabs = require(script.Parent)

	local function createTabs(props: TabsTypes.Props)
		return provideMockContext(nil, {
			Tabs = Roact.createElement(Tabs, props),
		})
	end

	it("should create and destroy without errors", function()
		local tabs = {
			{
				Name = "Left"
			},
			{
				Name = "Middle"
			},
			{
				Name = "Right"
			}
		}
		local element = createTabs({
			SelectedTab = tabs[1],
			Tabs = tabs,
			OnTabSelected = function() end,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
