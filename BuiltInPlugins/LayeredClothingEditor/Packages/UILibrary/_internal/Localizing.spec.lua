local Localizing = require(script.Parent.Localizing)

local Library = script.Parent
local Roact = require(Library.Parent.Parent.Roact)
local Signal = require(Library.Utils.Signal)
local Localization = require(Library.Studio.Localization)

local LocalizationProvider = Localizing.Provider
local LocalizationConsumer = Localizing.Consumer
local withLocalization = Localizing.withLocalization

return function()
	describe("LocalizationProvider", function()
		it("should construct/deconstruct without a problem", function()
			local localization = Localization.mock()

			local root = Roact.createElement(LocalizationProvider, {
				localization = localization
			})
			local handle = Roact.mount(root)
			Roact.unmount(handle)

			localization:destroy()
		end)

		it("should error if a localization object isn't provided", function()
			expect(function()
				local root = Roact.createElement(LocalizationProvider, {})
				local instance = Roact.mount(root)
				Roact.unmount(instance)
			end).to.throw()
		end)
	end)


	describe("LocalizationConsumer", function()
		it("should construct/deconstruct without a problem when used appropriately", function()
			local mockLocalization = Localization.mock()

			local function createTestElement()
				return withLocalization(function(localization)
					return Roact.createElement("TextLabel", {
						Text = localization:getText("Anything", "test")
					})
				end)
			end

			local root = Roact.createElement(LocalizationProvider, {
				localization = mockLocalization
			},{
				Roact.createElement(createTestElement, {})
			})

			local handle = Roact.mount(root)
			Roact.unmount(handle)

			mockLocalization:destroy()
		end)

		it("should error if constructed without a LocalizationProvider in the Roact tree", function()
			local function createTestElement()
				return withLocalization(function(localization)
					return Roact.createElement("TextLabel", {
						Text = localization:getText("Anything", "test")
					})
				end)
			end

			expect(function()
				local root = Roact.createElement(createTestElement)
				local instance = Roact.mount(root)
				Roact.unmount(instance)
			end).to.throw()
		end)

		it("should error if you construct it on its own", function()
			expect(function()
				local root = Roact.createElement(LocalizationConsumer, {})
				local instance = Roact.mount(root)
				Roact.unmount(instance)
			end).to.throw()
		end)

		it("should re-render its contents if the localization changes", function()
			local changeSignal = Signal.new()
			local localization = Localization.mock(changeSignal)

			-- create a test element and keep track of how many times it renders
			local renderCount = 0

			local TestElement = Roact.PureComponent:extend("TestElement")
			function TestElement:render()
				renderCount = renderCount + 1
				local text = self.props.text

				return Roact.createElement("TextLabel", {
					Text = text
				})
			end

			-- create the roact tree
			local root = Roact.createElement(LocalizationProvider, {
				localization = localization
			},{
				Roact.createElement(function()
					return withLocalization(function(localizationObject)
						return Roact.createElement(TestElement, {
							text = localizationObject:getText("Test", "hello_world")
						})
					end)
				end)
			})

			local instance = Roact.mount(root)
			expect(renderCount).to.equal(1)

			-- trigger a locale change
			changeSignal:fire()
			expect(renderCount).to.equal(2)

			-- clean up
			Roact.unmount(instance)
			localization:destroy()
		end)
	end)


	describe("withLocalization()", function()
		it("should error if a render callback isn't provided", function()
			expect(function()
				withLocalization()
			end).to.throw()
		end)

		it("should expose the stored localization object", function()
			local mockLocalization = Localization.mock()
			local foundLocalization = nil

			local function localizedRender(localization)
				foundLocalization = localization
				return Roact.createElement("TextLabel")
			end

			local root = Roact.createElement(LocalizationProvider, {
				localization = mockLocalization
			},{
				Roact.createElement(function()
					return withLocalization(localizedRender)
				end)
			})
			local instance = Roact.mount(root)
			Roact.unmount(instance)

			expect(foundLocalization).to.equal(mockLocalization)
		end)
	end)
end