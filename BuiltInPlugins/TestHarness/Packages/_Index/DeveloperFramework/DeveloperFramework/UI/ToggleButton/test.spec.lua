return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)

	local FrameworkStyles = require(Framework.UI.FrameworkStyles)
	local ContextServices = require(Framework.ContextServices)

	local Mouse = ContextServices.Mouse
	local Theme = ContextServices.Theme
	local provide = ContextServices.provide

	local ToggleButton = require(script.Parent)
	local Box = require(Framework.UI.Box)

	local StudioTheme = require(Framework.Style.Themes.StudioTheme)

	local Util = require(Framework.Util)
	local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

	local DEFAULT_PROPS = {
		Selected = true,
		OnClick = function() end,
	}
	local function createTestToggle(props)
		local mouse = Mouse.new({})
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
		return provide({theme, mouse}, {
			ToggleButton = Roact.createElement(ToggleButton, props or DEFAULT_PROPS),
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestToggle()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local container = Instance.new("Folder")
		local element = createTestToggle()
		local instance = Roact.mount(element, container)

		local frame = container:FindFirstChildOfClass("Frame")
		expect(frame).to.be.ok()
		Roact.unmount(instance)
	end)

	it("should show the HoverArea when not disabled", function()
		local folder = Instance.new("Folder")
		local element = createTestToggle({
			Disabled = false,
			OnClick = function() end,
		})
		local instance = Roact.mount(element, folder)

		local button = folder:FindFirstChildOfClass("Frame")
		local pointingHand = button.Contents.TextButton:FindFirstChild("PointingHand")
		expect(pointingHand).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should not show the HoverArea when disabled", function()
		local folder = Instance.new("Folder")
		local element = createTestToggle({
			Disabled = true,
			OnClick = function() end,
		})
		local instance = Roact.mount(element, folder)

		local button = folder:FindFirstChildOfClass("Frame")
		local pointingHand = button.Contents.TextButton:FindFirstChild("PointingHand")
		expect(pointingHand).to.never.be.ok()

		Roact.unmount(instance)
	end)

	it("should render a background", function()
		local folder = Instance.new("Folder")
		local element = createTestToggle({
			Selected = true,
			OnClick = function() end,
			Style = {
				Background = Box,
			},
		})
		local instance = Roact.mount(element, folder)

		local button = folder:FindFirstChildOfClass("Frame")
		expect(button.Decoration).to.be.ok()

		Roact.unmount(instance)
	end)
end