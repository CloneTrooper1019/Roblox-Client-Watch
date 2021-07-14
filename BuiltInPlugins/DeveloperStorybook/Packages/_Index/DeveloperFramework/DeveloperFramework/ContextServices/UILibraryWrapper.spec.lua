return function()
	local Framework = script.Parent.Parent

	local Util = require(Framework.Util)
	local Signal = Util.Signal
	local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
	local FlagsList = Util.Flags.new({
		FFlagStudioDevFrameworkPackage = {"StudioDevFrameworkPackage"},
	})

	local isUsedAsPackage = require(Framework.Util.isUsedAsPackage)

	if not FlagsList:get("FFlagStudioDevFrameworkPackage") or not isUsedAsPackage() then
		return
	end

	local Roact = require(Framework.Parent.Roact)
	local provide = require(Framework.ContextServices.provide)
	local Plugin = require(Framework.ContextServices.Plugin)
	local Focus = require(Framework.ContextServices.Focus)
	local Theme = require(Framework.ContextServices.Theme)
	local UILibraryWrapper = require(script.Parent.UILibraryWrapper)
	local StudioTheme = require(Framework.Style.Themes.StudioTheme)

	local WrapperStub = Roact.PureComponent:extend("UILibraryWrapper")

	function WrapperStub:render()
		-- NOOP
	end

	local UILibraryStub = {
		Wrapper = WrapperStub
	}

	local function createThemeMock()

		if THEME_REFACTOR then
			return StudioTheme.mock()
		else
			local createStyles = function()
				return {}
			end
			local getTheme = function()
				return "Light"
			end
			local themeChanged = Signal.new()
			return Theme.mock(createStyles, getTheme, themeChanged)
		end
	end

	it("should expect a Plugin ContextItem provided above", function()
		local focus = Focus.new(Instance.new("ScreenGui"))
		local wrapper = UILibraryWrapper.new(UILibraryStub)
		local theme = createThemeMock()
		function theme:getUILibraryTheme()
			return {}
		end

		local element = provide({
			focus,
			theme,
			wrapper,
		}, {
			Frame = Roact.createElement("Frame"),
		})
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should expect a Focus ContextItem provided above", function()
		local plugin = Plugin.new({})
		local wrapper = UILibraryWrapper.new(UILibraryStub)
		local theme = createThemeMock()
		function theme:getUILibraryTheme()
			return {}
		end

		local element = provide({
			plugin,
			theme,
			wrapper,
		}, {
			Frame = Roact.createElement("Frame"),
		})
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should expect a Theme ContextItem provided above", function()
		local plugin = Plugin.new({})
		local focus = Focus.new(Instance.new("ScreenGui"))
		local wrapper = UILibraryWrapper.new(UILibraryStub)

		local element = provide({
			plugin,
			focus,
			wrapper,
		}, {
			Frame = Roact.createElement("Frame"),
		})
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should expect a getUILibraryTheme function on Theme", function()
		local plugin = Plugin.new({})
		local focus = Focus.new(Instance.new("ScreenGui"))
		local wrapper = UILibraryWrapper.new(UILibraryStub)
		local theme = createThemeMock()

		local element = provide({
			plugin,
			focus,
			theme,
			wrapper,
		}, {
			Frame = Roact.createElement("Frame"),
		})
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should be providable as a ContextItem", function()
		local plugin = Plugin.new({})
		local focus = Focus.new(Instance.new("ScreenGui"))
		local wrapper = UILibraryWrapper.new(UILibraryStub)
		local theme = createThemeMock()
		function theme:getUILibraryTheme()
			return {}
		end

		local element = provide({
			plugin,
			focus,
			theme,
			wrapper,
		}, {
			Frame = Roact.createElement("Frame"),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
