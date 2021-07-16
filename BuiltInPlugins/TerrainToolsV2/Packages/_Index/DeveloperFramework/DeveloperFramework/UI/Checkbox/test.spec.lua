local FFlagDevFrameworkCheckbox = game:GetFastFlag("DevFrameworkCheckbox")
local FFlagDevFrameworkPaneOnClick = game:GetFastFlag("DevFrameworkPaneOnClick")

if not FFlagDevFrameworkCheckbox then
	return function() end
else
	return function()
		local Framework = script.Parent.Parent.Parent
		local Roact = require(Framework.Parent.Roact)
		local ContextServices = require(Framework.ContextServices)
		local Theme = ContextServices.Theme
		local FrameworkStyles = require(Framework.UI.FrameworkStyles)
		local provide = ContextServices.provide
		local Checkbox = require(script.Parent)
		local Immutable = require(Framework.Util.Immutable)

		local StudioTheme = require(Framework.Style.Themes.StudioTheme)

		local Util = require(Framework.Util)
		local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

		local DEFAULT_PROPS = {
			Key = "",
			Text = "",
		}

		local function createTestCheckbox(props, children)
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
				Checkbox = Roact.createElement(Checkbox, combinedProps, children),
			})
		end

		it("should create and destroy without errors", function()
			local element = createTestCheckbox()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("should render correctly", function()
			local container = Instance.new("Folder")
			local element = createTestCheckbox()
			local instance = Roact.mount(element, container)

			local frame = container:FindFirstChildOfClass("Frame")
			expect(frame).to.be.ok()
			expect(frame.Contents).to.be.ok()

			Roact.unmount(instance)
		end)


		it("should render the correct text", function()
			local container = Instance.new("Folder")
			local myText = "My Text"
			local element = createTestCheckbox({
				Key = "Key",
				Text = myText,
			})
			local instance = Roact.mount(element, container)

			local frame = container:FindFirstChildOfClass("TextButton")
			if FFlagDevFrameworkPaneOnClick then
				expect(frame.Button).to.be.ok()
				expect(frame.Label).to.be.ok()
				expect(frame.Label.Text).to.equal(myText)
			else
				expect(frame.Container).to.be.ok()
				expect(frame.Container.Button).to.be.ok()
				expect(frame.Container.Label).to.be.ok()
				expect(frame.Container.Label.Text).to.equal(myText)
			end
			Roact.unmount(instance)
		end)
	end
end
