local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local provideMockContext = require(script.Parent.provideMockContext)
local ContextServices = require(Framework.ContextServices)
local Provider = require(Framework.ContextServices.Provider)
local ContextItem = require(Framework.ContextServices.ContextItem)
local Util = require(Framework.Util)
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
return function()
	it("should work without arguments", function()
		local element = provideMockContext({}, {
			frame = Roact.createElement("Frame"),
		})
		local handle = Roact.mount(element)
		expect(element).to.be.ok()
		expect(handle).to.be.ok()
		Roact.unmount(handle)

		local element2 = provideMockContext(nil, {
			frame = Roact.createElement("Frame"),
		})
		local handle2 = Roact.mount(element2)
		expect(element2).to.be.ok()
		expect(handle2).to.be.ok()
		Roact.unmount(handle2)
	end)

	it("should throw if it is missing children", function()
		expect(function()
			provideMockContext({}, nil)
		end).to.throw()
	end)

	it("should expose some common contextItems", function()
		local wasRendered = false

		local testComponent = Roact.Component:extend("Test")
		function testComponent:render()
			wasRendered = true

			local localization = self.props.Localization
			local plugin = self.props.Plugin:get()
			local mouse = self.props.Mouse:get()
			local theme
			if THEME_REFACTOR then
				theme = self.props.Stylizer
			else
				theme = self.props.Theme:get("Framework")
			end

			expect(theme).to.never.equal(nil)
			expect(localization).to.never.equal(nil)
			expect(plugin).to.never.equal(nil)
			expect(mouse).to.never.equal(nil)

			return Roact.createElement("Frame")
		end
		ContextServices.mapToProps(testComponent,
		{
			Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
			Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
			Localization = ContextServices.Localization,
			Mouse = ContextServices.Mouse,
			Plugin = ContextServices.Plugin,
		})

		local element = provideMockContext(nil, {
			test = Roact.createElement(testComponent)
		})
		local handle = Roact.mount(element)
		Roact.unmount(handle)

		expect(wasRendered).to.equal(true)
	end)

	it("should allow you to supply custom contextItems", function()
		local testContextItem = ContextItem:extend("MyFakeItem")
		function testContextItem.new(item)
			local self = {
				item = item,
			}
			setmetatable(self, testContextItem)
			return self
		end
		function testContextItem:createProvider(root)
			return Roact.createElement(Provider, {
				ContextItem = self,
			}, {root})
		end
		function testContextItem:get()
			return self.item
		end


		local didRender = false
		local testComponent = Roact.Component:extend("TestElement")
		function testComponent:render()
			didRender = true
			local testItem = self.props.Test:get()

			expect(testItem).to.be.ok()
			expect(testItem).to.equal("abc")

			return Roact.createElement("Frame")
		end
		ContextServices.mapToProps(testComponent, {
			Test = testContextItem,
		})


		local element = provideMockContext({
			testContextItem.new("abc")
		}, {
			frame = Roact.createElement(testComponent),
		})
		local handle = Roact.mount(element)
		expect(element).to.be.ok()
		expect(handle).to.be.ok()
		expect(didRender).to.equal(true)
		Roact.unmount(handle)
	end)

	it("should allow you to override contextItems", function()
		local didRender = false
		local function createElementWithExpectedCursor(cursorTexture)
			local testComponent = Roact.Component:extend("Test")
			function testComponent:render()
				didRender = true
				local mouse = self.props.Mouse:get()
				local icon = mouse.Icon

				expect(icon).to.equal(cursorTexture)
				return Roact.createElement("Frame")
			end
			ContextServices.mapToProps(testComponent, 
			{
				Mouse = ContextServices.Mouse
			})

			return Roact.createElement(testComponent)
		end


		-- test the default cursor
		local element = provideMockContext(nil, {
			frame = createElementWithExpectedCursor("rbxasset://SystemCursors/Arrow")
		})
		local handle = Roact.mount(element)
		expect(element).to.be.ok()
		expect(handle).to.be.ok()
		Roact.unmount(handle)
		expect(didRender).to.equal(true)


		-- override the mouse cursor
		didRender = false
		element = provideMockContext({
			ContextServices.Mouse.new({
				Icon = "rbxasset://explosion.png",
			})
		}, {
			frame = createElementWithExpectedCursor("rbxasset://explosion.png"),
		})
		handle = Roact.mount(element)
		expect(element).to.be.ok()
		expect(handle).to.be.ok()
		Roact.unmount(handle)
		expect(didRender).to.equal(true)
	end)
end