return function()
	local Framework = script.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local provide = require(Framework.ContextServices.provide)
	local mapToProps = require(script.Parent.mapToProps)

	local Theme = require(script.Parent.Theme)
	local THEME_REFACTOR = require(Framework.Util.RefactorFlags).THEME_REFACTOR

	local Util = require(Framework.Util)
	local Style = Util.Style
	local StyleTable = Util.StyleTable
	local StyleModifier = Util.StyleModifier
	local Signal = Util.Signal

	if THEME_REFACTOR then
		return
	end

	local function createTestThemedComponent(render)
		local TestThemedComponent = Roact.PureComponent:extend("TestThemedComponent")

		function TestThemedComponent:render()
			local theme = self.props.Theme
			local style = theme:getStyle("Test", self)
			if render then
				render(style)
			end
		end

		mapToProps(TestThemedComponent, {
			Theme = Theme,
		})

		return TestThemedComponent
	end

	local function createTestTheme(values)
		return Theme.new(function()
			return {
				Test = {
					TestThemedComponent = StyleTable.new("TestThemedComponent", function()
						return values
					end)
				},
			}
		end)
	end

	describe("new", function()
		it("should expect a createStyles function", function()
			expect(function()
				Theme.new()
			end).to.throw()
		end)

		it("should return a new Theme", function()
			local theme = Theme.new(function()
				return {}
			end)
			expect(theme).to.be.ok()
			theme:destroy()
		end)
	end)

	describe("mock", function()
		it("should expect a createStyles function", function()
			expect(function()
				Theme.mock()
			end).to.throw()
		end)

		it("should expect a getTheme function", function()
			expect(function()
				local createStyles = function()
					return {}
				end
				Theme.mock(createStyles)
			end).to.throw()
		end)

		it("should create without errors", function()
			local createStyles = function()
				return {}
			end
			local getTheme = function()
				return "Light"
			end
			local theme = Theme.mock(createStyles, getTheme)
			theme:destroy()
		end)

		it("should accept a themeChanged signal", function()
			local createStyles = function()
				return {}
			end
			local getTheme = function()
				return "Light"
			end
			local themeChanged = Signal.new()
			local theme = Theme.mock(createStyles, getTheme, themeChanged)
			theme:destroy()
		end)
	end)

	describe("createStyles", function()
		it("should throw if nothing is returned", function()
			expect(function()
				Theme.new(function(theme, getColors)
				end)
			end).to.throw()
		end)

		it("should accept theme and getColors as parameters", function()
			local theme = Theme.new(function(theme, getColors)
				expect(theme).to.be.ok()
				expect(getColors).to.be.ok()
				expect(type(getColors)).to.equal("function")
				return {}
			end)
			theme:destroy()
		end)

		it("should be able to get Palette colors via the getColors function", function()
			local theme = Theme.new(function(theme, getColors)
				expect(getColors("Mock_TestColor")).to.be.ok()
				expect(typeof(getColors("Mock_TestColor"))).to.equal("Color3")
				return {}
			end)
			theme:destroy()
		end)

		it("should be called each time the theme updates", function()
			local themeChanged = Signal.new()
			local getTheme = function()
				return Enum.UITheme.Light
			end
			local calls = 0
			local createStyles = function(theme, getColors)
				calls = calls + 1
				return {}
			end
			local theme = Theme.mock(createStyles, getTheme, themeChanged)
			expect(calls).to.equal(1)
			themeChanged:Fire()
			expect(calls).to.equal(2)

			theme:destroy()
		end)
	end)

	describe("destroy", function()
		it("should disconnect from the theme changed signal", function()
			local themeChanged = Signal.new()
			local getTheme = function()
				return Enum.UITheme.Light
			end
			local calls = 0
			local mock = Theme.mock(function(theme, getColors)
				calls = calls + 1
				return {}
			end, getTheme, themeChanged)
			expect(calls).to.equal(1)
			mock:destroy()
			themeChanged:Fire()
			expect(calls).to.equal(1)
		end)
	end)

	it("should be providable as a ContextItem", function()
		local theme = Theme.new(function()
			return {}
		end)
		local element = provide({theme}, {
			Frame = Roact.createElement("Frame"),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
		theme:destroy()
	end)

	describe("get", function()
		it("should return the theme values", function()
			local testValues = {}
			local theme = Theme.new(function()
				return {
					Test = testValues,
				}
			end)
			expect(theme:get("Test")).to.equal(testValues)
			theme:destroy()
		end)

		it("should throw when called with a namespace that does not exist", function()
			local testValues = {}
			local theme = Theme.new(function()
				return {
					Test = testValues,
				}
			end)
			expect(function()
				theme:get("Toast")
			end).to.throw()
			theme:destroy()
		end)
	end)

	describe("getStyle", function()
		it("should not throw if the component has a correctly defined style", function()
			local themedComponent = createTestThemedComponent()
			local theme = createTestTheme( {
				Default = Style.new({})
			})
			local element = provide({theme}, {
				ThemedComponent = Roact.createElement(themedComponent),
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
			theme:destroy()
		end)

		it("should throw when called with a component that does not have a style", function()
			local themedComponent = createTestThemedComponent()
			local theme = Theme.new(function()
				return {
					Test = {},
				}
			end)
			local element = provide({theme}, {
				ThemedComponent = Roact.createElement(themedComponent),
			})
			expect(function()
				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end).to.throw()
			theme:destroy()
		end)

		it("should throw when called with a namespace that does not exist", function()
			local themedComponent = createTestThemedComponent()
			local theme = Theme.new(function()
				return {
					Toast = {
						TestThemedComponent = StyleTable.new("TestThemedComponent", function()
							return {
								Default = Style.new({})
							}
						end)
					},
				}
			end)
			local element = provide({theme}, {
				ThemedComponent = Roact.createElement(themedComponent),
			})
			expect(function()
				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end).to.throw()
			theme:destroy()
		end)

		describe("using Style prop", function()
			it("should take values from the current style", function()
				local receivedValue
				local themedComponent = createTestThemedComponent(function(style)
					receivedValue = style.Value
				end)
				local theme = createTestTheme({
					Default = Style.new({
						Value = "Test",
					}),
					Styled = Style.new({
						Value = "StyledTest",
					}),
				})
				local element = provide({theme}, {
					ThemedComponent = Roact.createElement(themedComponent, {
						Style = "Styled",
					}),
				})
				local instance = Roact.mount(element)
				Roact.unmount(instance)
				expect(receivedValue).to.equal("StyledTest")
				theme:destroy()
			end)
		end)

		describe("using StyleModifier prop", function()
			it("should take values from the current StyleModifier", function()
				local receivedValue
				local themedComponent = createTestThemedComponent(function(style)
					receivedValue = style.Value
				end)
				local theme = createTestTheme({
					Default = Style.new({
						Value = "Test",
						[StyleModifier.Hover] = {
							Value = "HoverTest",
						},
					}),
				})
				local element = provide({theme}, {
					ThemedComponent = Roact.createElement(themedComponent, {
						StyleModifier = StyleModifier.Hover,
					}),
				})
				local instance = Roact.mount(element)
				Roact.unmount(instance)
				expect(receivedValue).to.equal("HoverTest")
				theme:destroy()
			end)

			it("should take values from Style and StyleModifier combined", function()
				local receivedValue
				local themedComponent = createTestThemedComponent(function(style)
					receivedValue = style.Value
				end)
				local theme = createTestTheme({
					Default = Style.new({}),
					Styled = Style.new({
						Value = "Test",
						[StyleModifier.Hover] = {
							Value = "HoverTest",
						},
					}),
				})
				local element = provide({theme}, {
					ThemedComponent = Roact.createElement(themedComponent, {
						Style = "Styled",
						StyleModifier = StyleModifier.Hover,
					}),
				})
				local instance = Roact.mount(element)
				Roact.unmount(instance)
				expect(receivedValue).to.equal("HoverTest")
				theme:destroy()
			end)

			it("should fall back to the style if no modified value is found", function()
				local receivedValue, otherValue
				local themedComponent = createTestThemedComponent(function(style)
					receivedValue = style.Value
					otherValue = style.OtherValue
				end)
				local theme = createTestTheme({
					Default = Style.new({
						Value = "Test",
						OtherValue = "Test",
						[StyleModifier.Hover] = {
							Value = "HoverTest",
						},
					}),
				})
				local element = provide({theme}, {
					ThemedComponent = Roact.createElement(themedComponent, {
						StyleModifier = StyleModifier.Hover,
					}),
				})
				local instance = Roact.mount(element)
				Roact.unmount(instance)
				expect(receivedValue).to.equal("HoverTest")
				expect(otherValue).to.equal("Test")
				theme:destroy()
			end)
		end)
	end)
end