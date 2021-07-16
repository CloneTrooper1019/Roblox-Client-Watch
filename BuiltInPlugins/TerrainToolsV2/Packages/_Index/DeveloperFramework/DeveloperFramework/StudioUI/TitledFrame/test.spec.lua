return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local ContextServices = require(Framework.ContextServices)
	local FrameworkStyles = require(Framework.UI.FrameworkStyles)
	local provide = ContextServices.provide
	local TitledFrame = require(script.Parent)
	local Theme = ContextServices.Theme

	local StudioTheme = require(Framework.Style.Themes.StudioTheme)

	local Util = require(Framework.Util)
	local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR


	local function createTestTitledFrame(children, container)
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
			TitledFrame = Roact.createElement(TitledFrame, {
				Title = "Test",
			}, children)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestTitledFrame()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render a title", function()
		local container = Instance.new("Folder")
		local element = createTestTitledFrame({}, container)
		local instance = Roact.mount(element, container)

		local frame = container:FindFirstChildOfClass("ImageLabel")
		expect(frame).to.be.ok()
		expect(frame.Title).to.be.ok()
		Roact.unmount(instance)
	end)

	it("should render its children", function()
		local container = Instance.new("Folder")
		local element = createTestTitledFrame({
			MyChild = Roact.createElement("Frame", {}),
		}, container)
		local instance = Roact.mount(element, container)

		local frame = container:FindFirstChildOfClass("ImageLabel")
		expect(frame).to.be.ok()
		expect(frame.Content).to.be.ok()
		expect(frame.Content.MyChild).to.be.ok()
		Roact.unmount(instance)
	end)
end