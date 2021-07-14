return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local ContextServices = require(Framework.ContextServices)
	local Theme = ContextServices.Theme
	local FrameworkStyles = require(Framework.UI.FrameworkStyles)
	local provide = ContextServices.provide
	local RadioButton = require(script.Parent)
	local Immutable = require(Framework.Util.Immutable)

	local StudioTheme = require(Framework.Style.Themes.StudioTheme)

	local Util = require(Framework.Util)
	local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

	local DEFAULT_PROPS = {
		Key = "",
		Text = "",
	}

	local function createTestRadioButton(props, children)
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
		local combinedProps
		if props then
			combinedProps = Immutable.JoinDictionaries(DEFAULT_PROPS, props)
		else
			combinedProps = DEFAULT_PROPS
		end
		return provide({theme}, {
			RadioButton = Roact.createElement(RadioButton, combinedProps, children),
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestRadioButton()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local container = Instance.new("Folder")
		local element = createTestRadioButton()
		local instance = Roact.mount(element, container)

		local frame = container:FindFirstChildOfClass("TextButton")
		expect(frame).to.be.ok()
		Roact.unmount(instance)
	end)

	it("should render the correct text", function()
		local folder = Instance.new("Folder")
		local myText = "My Text"
		local element = createTestRadioButton({
			Key = "Key",
			Text = myText,
		})
		local instance = Roact.mount(element, folder)

		local button = folder:FindFirstChildOfClass("TextButton")
		expect(button.RadioImage).to.be.ok()
		expect(button.TextLabel).to.be.ok()
		expect(button.TextLabel.Text).to.equal(myText)

		Roact.unmount(instance)
	end)
end