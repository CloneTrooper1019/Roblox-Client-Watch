return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local ContextServices = require(Framework.ContextServices)
	local Theme = ContextServices.Theme
	local provide = ContextServices.provide
	local FrameworkStyles = require(Framework.UI.FrameworkStyles)
	local FakeLoadingBar = require(script.Parent)

	local StudioTheme = require(Framework.Style.Themes.StudioTheme)

	local Util = require(Framework.Util)
	local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

	local function createTestFakeLoadingBar(props, children)
		local theme
		if THEME_REFACTOR then
			theme = StudioTheme.mock()
		else
			theme = Theme.new(function()
				return {
					Framework = FrameworkStyles.new(),
				}
			end)
		end
		return provide({theme}, {
			FakeLoadingBar = Roact.createElement(FakeLoadingBar, props, children),
		})
	end

	it("should expect a LoadingTime prop", function()
		local element = createTestFakeLoadingBar()
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should expect LoadingTime to be greater than zero", function()
		local element = createTestFakeLoadingBar({
			LoadingTime = 0,
		})
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should expect HoldValue to be greater than zero", function()
		local element = createTestFakeLoadingBar({
			LoadingTime = 1,
			HoldValue = 0
		})
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should expect HoldValue to be less than 1", function()
		local element = createTestFakeLoadingBar({
			LoadingTime = 1,
			HoldValue = 2,
		})
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should create and destroy without errors", function()
		local element = createTestFakeLoadingBar({
			LoadingTime = 1,
			HoldValue = 0.75,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end