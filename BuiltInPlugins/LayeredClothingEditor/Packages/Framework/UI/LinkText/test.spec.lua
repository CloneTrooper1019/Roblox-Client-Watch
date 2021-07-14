return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local ContextServices = require(Framework.ContextServices)
	local Mouse = ContextServices.Mouse
	local Theme = ContextServices.Theme
	local provide = ContextServices.provide
	local FrameworkStyles = require(Framework.UI.FrameworkStyles)
	local LinkText = require(script.Parent)

	local StudioTheme = require(Framework.Style.Themes.StudioTheme)

	local Util = require(Framework.Util)
	local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

	local function createTestLinkText(props)
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
			LinkText = Roact.createElement(LinkText, props),
		})
	end

	it("should expect an OnClick function", function()
		local element = createTestLinkText()
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should create and destroy without errors", function()
		local element = createTestLinkText({
			OnClick = function()
			end,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local folder = Instance.new("Folder")
		local element = createTestLinkText({
			OnClick = function()
			end,
		})
		local instance = Roact.mount(element, folder)

		local frame = folder:FindFirstChildOfClass("Frame")
		expect(frame).to.be.ok()
		expect(frame.Contents).to.be.ok()
		expect(frame.Contents.TextButton).to.be.ok()
		expect(frame.Contents.TextButton.HoverArea).to.be.ok()

		Roact.unmount(instance)
	end)
end