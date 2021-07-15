return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local ContextServices = require(Framework.ContextServices)
	local FrameworkStyles = require(Framework.UI.FrameworkStyles)
	local Theme = ContextServices.Theme
	local provide = ContextServices.provide
	local Button = require(script.Parent)
	local Box = require(Framework.UI.Box)

	local StudioTheme = require(Framework.Style.Themes.StudioTheme)

	local Util = require(Framework.Util)
	local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

	local function createTestButton(props, children)
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
			Button = Roact.createElement(Button, props, children),
		})
	end

	it("should expect an OnClick function", function()
		local element = createTestButton()
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should create and destroy without errors", function()
		local element = createTestButton({
			OnClick = function()
			end,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local folder = Instance.new("Folder")
		local element = createTestButton({
			OnClick = function()
			end,
		})
		local instance = Roact.mount(element, folder)

		local button = folder:FindFirstChildOfClass("Frame")
		expect(button).to.be.ok()
		expect(button.Contents).to.be.ok()
		expect(button.Contents.TextButton).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should render its children", function()
		local folder = Instance.new("Folder")
		local element = createTestButton({
			OnClick = function()
			end,
		}, {
			ChildFrame = Roact.createElement("Frame")
		})
		local instance = Roact.mount(element, folder)

		local button = folder:FindFirstChildOfClass("Frame")
		expect(button.Contents.TextButton.ChildFrame).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should render a background", function()
		local folder = Instance.new("Folder")
		local element = createTestButton({
			Style = {
				Background = Box,
			},
			OnClick = function()
			end,
		})
		local instance = Roact.mount(element, folder)

		local button = folder:FindFirstChildOfClass("Frame")
		expect(button.Decoration).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should render a foreground", function()
		local folder = Instance.new("Folder")
		local element = createTestButton({
			Style = {
				Foreground = Box,
			},
			OnClick = function()
			end,
		})
		local instance = Roact.mount(element, folder)

		local button = folder:FindFirstChildOfClass("Frame")
		expect(button.Contents.Foreground).to.be.ok()
		expect(button.Contents.Foreground.Decoration).to.be.ok()

		Roact.unmount(instance)
	end)
end