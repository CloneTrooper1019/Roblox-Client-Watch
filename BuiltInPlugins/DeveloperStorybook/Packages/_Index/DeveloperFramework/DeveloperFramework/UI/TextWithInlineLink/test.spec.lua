return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local Cryo = require(Framework.Parent.Cryo)

	local ContextServices = require(Framework.ContextServices)
	local Mouse = ContextServices.Mouse
	local Theme = ContextServices.Theme
	local provide = ContextServices.provide

	local Util = require(Framework.Util)
	local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
	local t = require(Framework.Util.Typecheck.t)

	local StudioTheme = require(Framework.Style.Themes.StudioTheme)

	local FrameworkStyles = require(Framework.UI.FrameworkStyles)
	local TextWithInlineLink = require(Framework.UI.TextWithInlineLink)

	local linkPlaceholder = '{link}'
	local linkText = 'Link'
	local textSize = 12

	local container = nil
	local instance = nil

	local function getInstance(props)
		assert(t.interface({
			Text = t.string,
		})(props))

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

		local element = provide({ theme, mouse }, {
			TextWithInlineLink = Roact.createElement(TextWithInlineLink, Cryo.Dictionary.join({
				OnLinkClicked = function() end,
				LinkText = linkText,
				LinkPlaceholder = linkPlaceholder,
				MaxWidth = 100,
				TextProps = {
					TextSize = textSize,
					Font = Enum.Font.SourceSans
				}
			}, props)),
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container)

		return container, instance
	end

	afterEach(function()
		if instance then
			Roact.unmount(instance)
			instance = nil
		end
	end)

	it("with no link placeholder", function()
		local text = "hello world"
		container, instance = getInstance({
			Text = text
		})

		local frame = container:FindFirstChild("line_1", true)
		local children = frame:GetChildren()

		expect(#children).to.equal(2)

		expect(children[1].Text).to.equal(text)
    end)

    it("with one link placeholder at the start of the text", function()
		local text = "{link} world"
		container, instance = getInstance({
			Text = text
		})

		local frame = container:FindFirstChild("line_1", true)
		local children = frame:GetChildren()

		expect(#children).to.equal(3)
		expect(children[1]:FindFirstChild("TextButton", true).Text).to.equal(linkText)
		expect(children[2].Text).to.equal(" world")
	end)

	it("with enough text to cause overflow and wrapping", function()
		local isCli, _ = pcall(function()
			game:GetService("ProcessService")
		end)

		if isCli then
			return
		end

		local text = "Hello here is a {link} that is going to cause this to wrap onto another line and this line after the link will wrap on its own it's that long!"
		container, instance = getInstance({
			Text = text,
		})

		local line1 = container:FindFirstChild("line_1", true)
		local line2 = container:FindFirstChild("line_2", true)

		expect(#line1:GetChildren()).to.equal(3)
		expect(line1:GetChildren()[2].Text).to.equal("Hello here is a ")
		expect(line1:GetChildren()[3]:FindFirstChild("TextButton", true).Text).to.equal(linkText)
		expect(line1.Size.Y.Offset).to.equal(textSize)

		expect(#line2:GetChildren()).to.equal(2)
		expect(line2:GetChildren()[2].Text).to.equal(" that is going to cause this to wrap onto another line and this line after the link will wrap on its own it's that long!")
		expect(line2.Size.Y.Offset).to.equal(textSize * 5)
    end)


    it("with two link placeholders (one at the end of the text)", function()
		local text = "hello {link} world {link}"
		container, instance = getInstance({
			Text = text
		})

		local frame = container:FindFirstChild("line_1", true)
		local children = frame:GetChildren()

		expect(#children).to.equal(5)
		expect(children[1].Text).to.equal("hello ")
		expect(children[2]:FindFirstChild("TextButton", true).Text).to.equal(linkText)
		expect(children[3].Text).to.equal(" world ")
		expect(children[4]:FindFirstChild("TextButton", true).Text).to.equal(linkText)
    end)
end
