return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local ContextServices = require(Framework.ContextServices)
	local Theme = ContextServices.Theme
	local provide = ContextServices.provide
	local FrameworkStyles = require(Framework.UI.FrameworkStyles)
	local LoadingBar = require(script.Parent)
	local Box = require(Framework.UI.Box)

	local StudioTheme = require(Framework.Style.Themes.StudioTheme)

	local Util = require(Framework.Util)
	local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

	local function createTestLoadingBar(props, children)
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
			LoadingBar = Roact.createElement(LoadingBar, props, children),
		})
	end

	it("should expect a Progress prop", function()
		local element = createTestLoadingBar()
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should create and destroy without errors", function()
		local element = createTestLoadingBar({
			Progress = 0,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local folder = Instance.new("Folder")
		local element = createTestLoadingBar({
			Progress = 0,
		})
		local instance = Roact.mount(element, folder)

		local frame = folder:FindFirstChildOfClass("Frame")
		expect(frame).to.be.ok()
		expect(frame.Contents).to.be.ok()
		expect(frame.Contents.LoadingBar).to.be.ok()
		expect(frame.Contents.LoadingBar.Contents).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should render a background", function()
		local folder = Instance.new("Folder")
		local element = createTestLoadingBar({
			Progress = 0,
			Style = {
				Background = Box,
			},
		})
		local instance = Roact.mount(element, folder)

		local frame = folder:FindFirstChildOfClass("Frame")
		expect(frame.Decoration).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should render a foreground", function()
		local folder = Instance.new("Folder")
		local element = createTestLoadingBar({
			Progress = 0,
			Style = {
				Foreground = Box,
			},
		})
		local instance = Roact.mount(element, folder)

		local frame = folder:FindFirstChildOfClass("Frame")
		expect(frame.Contents.LoadingBar.Decoration).to.be.ok()

		Roact.unmount(instance)
	end)
end