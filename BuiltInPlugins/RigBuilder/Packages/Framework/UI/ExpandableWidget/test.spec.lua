return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local ContextServices = require(Framework.ContextServices)
	local Theme = ContextServices.Theme
	local provide = ContextServices.provide
	local FrameworkStyles = require(Framework.UI.FrameworkStyles)
	local ExpandableWidget = require(script.Parent)

	local StudioTheme = require(Framework.Style.Themes.StudioTheme)

	local Util = require(Framework.Util)
	local Cryo = Util.Cryo
	local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

	local function createTestExpandableWidget(props)
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
		local defaultProps = {
			TopLevelContent = {
				Roact.createElement("TextLabel", {
					Text = "TopLevelItem",
				})
			},
			ExpandableContent = {
				Roact.createElement("TextLabel", {
					Text = "ExpandableContent",
				})
			},
		}
		props = Cryo.Dictionary.join(defaultProps, props)
		return provide({theme}, {
			ExpandableWidget = Roact.createElement(ExpandableWidget, props),
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestExpandableWidget({})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should show ExpandableContent when expanded is true", function ()
		local folder = Instance.new("Folder")
		local element = createTestExpandableWidget({
			IsExpanded = true,
		})
		local instance = Roact.mount(element, folder)

		local ExpandableWidget = folder:FindFirstChildOfClass("Frame")
		expect(ExpandableWidget).to.be.ok()
		expect(ExpandableWidget.ExpandableFrame).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should not show ExpandableContent when expanded is false", function ()
		local folder = Instance.new("Folder")
		local element = createTestExpandableWidget({
			IsExpanded = false,
		})
		local instance = Roact.mount(element, folder)

		local ExpandableWidget = folder:FindFirstChildOfClass("Frame")
		expect(ExpandableWidget).to.be.ok()
		local expandableFrame = ExpandableWidget:FindFirstChild("ExpandableFrame")
		expect(expandableFrame).to.never.be.ok()

		Roact.unmount(instance)
	end)
end