return function()
	local Stylizer = require(script.Parent.Stylizer)
	local Framework = script.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local provide = require(Framework.ContextServices.provide)
	local mapToProps = require(Framework.ContextServices.mapToProps)

	local FrameworkStyle = require(Framework.Style)
	local ui = FrameworkStyle.ComponentSymbols
	local StyleKey = require(script.Parent.StyleKey)

	local Util = require(Framework.Util)
	local Signal = Util.Signal
	local StyleModifier = Util.StyleModifier

	local testSymbols = {}

	local function createTestThemedComponent(render)
		local TestThemedComponent = Roact.PureComponent:extend("TestThemedComponent")

		function TestThemedComponent:render()
			local style = self.props.Theme
			if render then
				render(style)
			end
		end

		mapToProps(TestThemedComponent, {
			Theme = Stylizer,
		})

		return TestThemedComponent
	end

	local function addSymbol(symbolName)
		local symbol = ui:add(symbolName)
		table.insert(testSymbols, symbol)
		return symbol
	end

	local function cleanUpSymbols()
		for _,v in pairs(testSymbols) do
			ui[v] = nil
		end
	end

	local function createDefaultStylizer(initialTable)
		initialTable = initialTable or {}
		return Stylizer.new(initialTable, {
			getThemeName = function() end,
		})
	end

	describe("new", function()
		afterEach(function()
			cleanUpSymbols()
		end)

		it("should expect an initial table as a parameter", function()
			expect(function()
				Stylizer.new(nil, {})
			end).to.throw()
		end)

		it("should expect an inial themeProps as a parameter", function()
			expect(function()
				Stylizer.new({}, nil)
			end).to.throw()
		end)

		it("should return a new Stylizer", function()
			local stylizer = createDefaultStylizer()
			expect(stylizer).to.be.ok()
			stylizer:destroy()
		end)
	end)

	describe("extend", function()
		it("should return a new Stylizer", function()
			local stylizer = createDefaultStylizer()
			stylizer = stylizer:extend({})
			expect(stylizer).to.be.ok()
			stylizer:destroy()
		end)

		it("should merge the table with existing values", function()
			local oldValue = "old"
			local addedValue = "add"
			local overrideValue = "world"
			local stylizer = createDefaultStylizer({
				old = oldValue,
				override = "old",
			})
			stylizer = stylizer:extend({
				added = addedValue,
				override = overrideValue,
			})

			local result = stylizer.__calculatedStyle
			expect(result.old).to.equal(oldValue)
			expect(result.override).to.equal(overrideValue)
			expect(result.added).to.equal(addedValue)
			stylizer:destroy()
		end)
	end)

	it("should be providable as a ContextItem", function()
		local stylizer = createDefaultStylizer()
		local element = provide({stylizer}, {
			Frame = Roact.createElement("Frame"),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
		stylizer:destroy()
	end)

	describe("destroy", function()
		it("should disconnect from the theme changed signal", function()
			local themeChanged = Signal.new()
			local calls = 0
			local callback = function(theme, getColors)
				calls = calls + 1
				return {}
			end
			local stylizer = Stylizer.mock({}, {
				getThemeName = function() return "Light" end,
				themesList = { ["Light"] = {} },
				themeChangedConnection = themeChanged,
			}, callback)
			stylizer:destroy()
			themeChanged:Fire()
			expect(calls).to.equal(0)
		end)
	end)

	describe("getStyleKeysTable", function()
		it("should get a list of all StyleKey values in the first layer of the passed in table", function()
			local styleKeyValue = "world"
			local styleKeysTable = {
				[StyleKey.hello] = styleKeyValue,
				notAStyleKey = "no",
			}
			local result = Stylizer:getStyleKeysTable(styleKeysTable)
			expect(result.notAStyleKey).to.never.be.ok()
			expect(result[tostring(StyleKey.hello)]).to.equal(styleKeyValue)
		end)
	end)

	describe("convertStyleKeys", function()
		it("should replace all StyleKey values with the correct value", function()
			local redValue = "Mario"
			local styleKeysTable = {
				[StyleKey.Red] = redValue,
			}
			styleKeysTable = Stylizer:getStyleKeysTable(styleKeysTable)
			local tableToConvert = {
				itsAme = StyleKey.Red,
				its = {
					aMe = StyleKey.Red,
				}
			}
			local result = Stylizer:convertStyleKeys(tableToConvert, nil, nil, styleKeysTable)
			expect(result.itsAme).to.equal(redValue)
			expect(result.its.aMe).to.equal(redValue)
		end)
	end)

	describe("getPathString", function()
		afterEach(function()
			cleanUpSymbols()
		end)

		it("should get the correct path value for root styles", function()
			local receivedValue
			local themedComponent = createTestThemedComponent(function(style)
				receivedValue = style:getPathString()
			end)
			addSymbol("TestThemedComponent")
			local theme = createDefaultStylizer({})
			local element = provide({theme}, {
				ThemedComponent = Roact.createElement(themedComponent, {}),
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
			expect(receivedValue).to.be.ok()
			expect(receivedValue).to.equal("[Root Style]")
			theme:destroy()
		end)

		it("should get the correct path value for a component", function()
			local receivedValue
			local themedComponent = createTestThemedComponent(function(style)
				receivedValue = style:getPathString()
			end)
			addSymbol("TestThemedComponent")
			local theme = createDefaultStylizer({
				[ui.TestThemedComponent] = {
					hello = "world",
				},
			})
			local element = provide({theme}, {
				ThemedComponent = Roact.createElement(themedComponent),
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
			expect(receivedValue).to.be.ok()
			expect(receivedValue).to.equal("[Root Style]-->ComponentSymbols(TestThemedComponent)")
			theme:destroy()
		end)

		it("should get the correct path value for a Style in the Root", function()
			local receivedValue
			local themedComponent = createTestThemedComponent(function(style)
				receivedValue = style:getPathString()
			end)
			addSymbol("TestThemedComponent")
			local theme = createDefaultStylizer({
				[ui.TestThemedComponent] = {
					hello = "world",
				},
				override = {
					test = "test",
				}
			})
			local element = provide({theme}, {
				ThemedComponent = Roact.createElement(themedComponent, {
					Style = "override",
				}),
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
			expect(receivedValue).to.be.ok()
			expect(receivedValue).to.equal("[Root Style]-->override")
			theme:destroy()
		end)

		it("should get the correct path value for an ampersand Style", function()
			local receivedValue
			local themedComponent = createTestThemedComponent(function(style)
				receivedValue = style:getPathString()
			end)
			addSymbol("TestThemedComponent")
			local theme = createDefaultStylizer({
				[ui.TestThemedComponent] = {
					hello = "world",
					["&override"] = {
						test = "test",
					}
				},
			})
			local element = provide({theme}, {
				ThemedComponent = Roact.createElement(themedComponent, {
					Style = "override",
				}),
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
			expect(receivedValue).to.be.ok()
			expect(receivedValue).to.equal("[Root Style]-->ComponentSymbols(TestThemedComponent)-->&override")
			theme:destroy()
		end)
	end)

	describe("getConsumerItem", function()
		afterEach(function()
			cleanUpSymbols()
		end)

		it("should get the corresponding component's style values", function()
			local receivedValue
			local themedComponent = createTestThemedComponent(function(style)
				receivedValue = style
			end)
			local componentValue = "world"
			addSymbol("TestThemedComponent")
			addSymbol("doNotGet")
			local theme = createDefaultStylizer({
				[ui.TestThemedComponent] = {
					hello = componentValue,
				},
				[ui.doNotGet] = {
					ohNo = "no",
				},
			})
			local element = provide({theme}, {
				ThemedComponent = Roact.createElement(themedComponent),
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
			expect(receivedValue).to.be.ok()
			expect(receivedValue.hello).to.equal(componentValue)
			expect(receivedValue.ohNo).to.never.be.ok()
			theme:destroy()
		end)

		it("should replace StyleKey values with the correct value", function()
			local receivedValue
			local themedComponent = createTestThemedComponent(function(style)
				receivedValue = style
			end)
			local blueValue = Color3.new(1, 1, 1)
			local redValue = Color3.new(1, 0, 0)
			addSymbol("TestThemedComponent")
			local theme = createDefaultStylizer({
				[StyleKey.Blue] = blueValue,

				[ui.TestThemedComponent] = {
					theSkyIs = StyleKey.Blue,
					["&override"] = {
						theSkyIs = redValue,
					}
				}
			})
			local element = provide({theme}, {
				ThemedComponent = Roact.createElement(themedComponent, {}),
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
			expect(receivedValue.theSkyIs).to.equal(blueValue)
			theme:destroy()
		end)

		it("should be overridden with the correct ampersand when a string is passed into Style prop", function()
			local receivedValue
			local themedComponent = createTestThemedComponent(function(style)
				receivedValue = style
			end)
			local blueValue = Color3.new(1, 1, 1)
			local redValue = Color3.new(1, 0, 0)
			addSymbol("TestThemedComponent")
			local theme = createDefaultStylizer({
				[ui.TestThemedComponent] = {
					theSkyIs = blueValue,
					["&override"] = {
						theSkyIs = redValue,
					}
				}
			})
			local element = provide({theme}, {
				ThemedComponent = Roact.createElement(themedComponent, {
					Style = "override",
				}),
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
			expect(receivedValue.theSkyIs).to.equal(redValue)
			theme:destroy()
		end)

		it("should get the correct value for a Style in the Root", function()
			local receivedValue
			local themedComponent = createTestThemedComponent(function(style)
				receivedValue = style
			end)
			addSymbol("TestThemedComponent")
			local blueValue = Color3.new(1, 1, 1)
			local theme = createDefaultStylizer({
				[ui.TestThemedComponent] = {
					hello = "world",
				},
				override = {
					hello = blueValue,
				}
			})
			local element = provide({theme}, {
				ThemedComponent = Roact.createElement(themedComponent, {
					Style = "override",
				}),
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
			expect(receivedValue).to.be.ok()
			expect(receivedValue.hello).to.equal(blueValue)
			theme:destroy()
		end)

		it("should be overridden with the table passed into Style prop", function()
			local receivedValue
			local themedComponent = createTestThemedComponent(function(style)
				receivedValue = style
			end)
			local blueValue = Color3.new(1, 1, 1)
			local redValue = Color3.new(1, 0, 0)
			local blackValue = Color3.new(0, 0, 0)
			addSymbol("TestThemedComponent")
			local theme = createDefaultStylizer({
				[ui.TestThemedComponent] = {
					theSkyIs = blueValue,
					["&override"] = {
						theSkyIs = redValue,
					}
				}
			})
			local element = provide({theme}, {
				ThemedComponent = Roact.createElement(themedComponent, {
					Style = {
						theSkyIs = blackValue
					},
				}),
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
			expect(receivedValue.theSkyIs).to.equal(blackValue)
			theme:destroy()
		end)

		it("should be called each time the theme updates", function()
			local themeChanged = Signal.new()
			local calls = 0
			local callback = function(theme, getColors)
				calls = calls + 1
				return {}
			end
			local stylizer = Stylizer.mock({}, {
				getThemeName = function() return "Light" end,
				themesList = { ["Light"] = {} },
				themeChangedConnection = themeChanged,
			}, callback)
			themeChanged:Fire()
			expect(calls).to.equal(1)
			themeChanged:Fire()
			expect(calls).to.equal(2)

			stylizer:destroy()
		end)

		describe("using StyleModifier prop", function()
			afterEach(function()
				cleanUpSymbols()
			end)

			it("should take values from the current StyleModifier", function()
				local receivedValue
				local themedComponent = createTestThemedComponent(function(style)
					receivedValue = style
				end)
				addSymbol("TestThemedComponent")
				local theme = createDefaultStylizer({
					[ui.TestThemedComponent] = {
						Value = "Test",
						[StyleModifier.Hover] = {
							Value = "HoverTest",
						},
					}
				})
				local element = provide({theme}, {
					ThemedComponent = Roact.createElement(themedComponent, {
						StyleModifier = StyleModifier.Hover,
					}),
				})
				local instance = Roact.mount(element)
				Roact.unmount(instance)
				expect(receivedValue.Value).to.equal("HoverTest")
				theme:destroy()
			end)

			it("should take values from ampersand Style and StyleModifier combined", function()
				local receivedValue
				local themedComponent = createTestThemedComponent(function(style)
					receivedValue = style
				end)
				addSymbol("TestThemedComponent")
				local theme = createDefaultStylizer({
					[ui.TestThemedComponent] = {
						Value = "Test",
						["&Styled"] = {
							[StyleModifier.Hover] = {
								Value = "HoverTest",
							},
						}
					},
				})
				local element = provide({theme}, {
					ThemedComponent = Roact.createElement(themedComponent, {
						Style = "Styled",
						StyleModifier = StyleModifier.Hover,
					}),
				})
				local instance = Roact.mount(element)
				Roact.unmount(instance)
				expect(receivedValue.Value).to.equal("HoverTest")
				theme:destroy()
			end)

			it("should take values from passed-in Style and StyleModifier combined", function()
				local receivedValue
				local themedComponent = createTestThemedComponent(function(style)
					receivedValue = style
				end)
				addSymbol("TestThemedComponent")
				local theme = createDefaultStylizer({
					[ui.TestThemedComponent] = {
						Value = "Test",
					},
				})
				local element = provide({theme}, {
					ThemedComponent = Roact.createElement(themedComponent, {
						Style = {
							[StyleModifier.Hover] = {
								Value = "HoverTest",
							},
						},
						StyleModifier = StyleModifier.Hover,
					}),
				})
				local instance = Roact.mount(element)
				Roact.unmount(instance)
				expect(receivedValue.Value).to.equal("HoverTest")
				theme:destroy()
			end)

			it("should fall back to the style if no modified value is found", function()
				local receivedValue
				local themedComponent = createTestThemedComponent(function(style)
					receivedValue = style
				end)
				local theme = createDefaultStylizer({
					[ui.TestThemedComponent] = {
						Value = "Test",
						OtherValue = "Test",
						[StyleModifier.Hover] = {
							Value = "HoverTest",
						},
					},
				})
				local element = provide({theme}, {
					ThemedComponent = Roact.createElement(themedComponent, {
						StyleModifier = StyleModifier.Hover,
					}),
				})
				local instance = Roact.mount(element)
				Roact.unmount(instance)
				expect(receivedValue.Value).to.equal("HoverTest")
				expect(receivedValue.OtherValue).to.equal("Test")
				theme:destroy()
			end)
		end)
	end)
end