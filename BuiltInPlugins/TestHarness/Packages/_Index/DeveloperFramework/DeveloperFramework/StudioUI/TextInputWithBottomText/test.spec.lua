return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local ContextServices = require(Framework.ContextServices)
	local FrameworkStyles = require(Framework.UI.FrameworkStyles)
	local provide = ContextServices.provide
	local TextInputWithBottomText = require(script.Parent)
	local Theme = ContextServices.Theme

	local StudioTheme = require(Framework.Style.Themes.StudioTheme)

	local Util = require(Framework.Util)
	local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

	local function createTestElement(element, container)
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
		return provide({theme}, element)
	end

	it("should create and destroy without errors", function()
		local element = createTestElement({
			TextInputWithBottomText = Roact.createElement(TextInputWithBottomText, {
				BottomText = "test",
				Size = UDim2.new(1, 0, 1, 0),
				TextInputProps = {
					Text = "textbox"
				},
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

end
