return function()
	local Framework = script.Parent.Parent
	local Signal = require(Framework.Util).Signal
	local Roact = require(Framework.Parent.Roact)
	local provide = require(Framework.ContextServices.provide)

	local TestLocalizationChangedSignal = Signal.new()
	local Localization = require(script.Parent.Localization)
	local TestDevStrings = script.Parent.TestDevStrings
	local TestTranslationStrings = script.Parent.TestTranslationStrings
	local TestLibraryDevStrings = script.Parent.TestLibraryDevStrings
	local TestLibraryTranslationStrings = script.Parent.TestLibraryTranslationStrings
	local LIBRARY_PROJECT = "MyLibrary"

	describe("Localization", function()
		local function runTestWithLocalization(props, runTest)
			local localization = Localization.new({
				stringResourceTable = TestDevStrings,
				translationResourceTable = TestTranslationStrings,
				pluginName = "Framework",
				libraries = {
					[LIBRARY_PROJECT] = {
						stringResourceTable = TestLibraryDevStrings,
						translationResourceTable = TestLibraryTranslationStrings,
					}
				},
				overrideLocaleChangedSignal = TestLocalizationChangedSignal,
				overrideLocaleId = props.localeId or "en-us",
				getLocale = props.getLocale,
			})

			runTest(localization)

			localization:destroy()
		end

		it("should construct with the correct inputs", function()
			runTestWithLocalization({}, function(localization)
				expect(localization).to.be.ok()
			end)
		end)

		it("should error if it is missing any props", function()
			expect(function()
				Localization.new()
			end).to.throw()

			expect(function()
				Localization.new({})
			end).to.throw()

			expect(function()
				Localization.new({ 
					libraries = {
						MyBadlySpecifiedLibrary = {},
					}
				})
			end).to.throw()

			expect(function()
				Localization.new({ 
					libraries = {
						MyBadlySpecifiedLibrary = {
							stringResourceTable = TestDevStrings
						},
					},
				})
			end).to.throw()

			expect(function()
				Localization.new({ 
					libraries = {
						MyBadlySpecifiedLibrary = {
							translationResourceTable = TestTranslationStrings
						},
					},
				})
			end).to.throw()

			expect(function()
				Localization.new({ stringResourceTable = TestDevStrings })
			end).to.throw()

			expect(function()
				Localization.new({ translationResourceTable = TestTranslationStrings })
			end).to.throw()

			expect(function()
				Localization.new({ pluginName = "Framework" })
			end).to.throw()
		end)

		it("should be providable as a ContextItem", function()
			runTestWithLocalization({}, function(localization)
				local element = provide({localization}, {
					Frame = Roact.createElement("Frame"),
				})
				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end)
		end)

		it("should return localized strings when given keys to look up", function()
			runTestWithLocalization({}, function(localization)
				local greeting = localization:getText("Spec", "greeting_formal")
				expect(greeting).to.equal("Hello")

				greeting = localization:getProjectText("Framework", "Spec", "greeting_formal")
				expect(greeting).to.equal("Hello")

				local farewell = localization:getProjectText(LIBRARY_PROJECT, "Spec", "farewell_formal")
				expect(farewell).to.equal("Goodbye")
			end)
		end)

		it("should return a formatted string when args are provided", function()
			runTestWithLocalization({}, function(localization)
				local greeting = localization:getText("Spec", "greeting_informal", {
					friend = "Builderman",
					days = 2
				})
				expect(greeting).to.equal("Sup Builderman, I haven't seen you in 2 days")
			end)
		end)

		it("should return the English text of a string if a translation is missing in the resourceTable", function()
			runTestWithLocalization({
				localeId = "es-es",
			}, function(localization)
				local normal = localization:getText("Spec", "greeting_formal")
				expect(normal).to.equal("Hola")

				local informal = localization:getText("Spec", "greeting_informal", {
					friend = "John Doe",
					days = 100,
				})
				expect(informal).to.equal("¿Qué pasa John Doe? No te he visto en 100 días")

				local surprise = localization:getText("Spec", "greeting_surprise")
				expect(surprise).to.equal("No one expects the Spanish Inquisition!")

				local farewell = localization:getProjectText(LIBRARY_PROJECT, "Spec", "farewell_surprise")
				expect(farewell).to.equal("Fare thee well!")
			end)
		end)

		it("should return the key if the string does not exist in the resourceTable at all", function()
			runTestWithLocalization({}, function(localization)
				local greeting = localization:getText("Spec", "greeting_serious")
				expect(greeting).to.equal("Studio.Framework.Spec.greeting_serious")

				local farewell = localization:getProjectText(LIBRARY_PROJECT, "Spec", "oops")
				expect(farewell).to.equal("Studio.MyLibrary.Spec.oops")
			end)
		end)

		it("should throw if project is missing", function()
			runTestWithLocalization({}, function(localization)
				expect(function()
					localization:getProjectText("missingProject", "Spec", "farewell_formal")
				end).to.throw()
			end)
		end)

		it("should update its strings if the localization changes", function()
			local currentLocale = "en-us"
			local function getLocale()
				return currentLocale
			end

			runTestWithLocalization({
				getLocale = getLocale,
			}, function(localization)
				local greeting = localization:getText("Spec", "greeting_formal")
				expect(greeting).to.equal("Hello")

				local farewell = localization:getProjectText(LIBRARY_PROJECT, "Spec", "farewell_formal")
				expect(farewell).to.equal("Goodbye")

				-- trigger a locale change
				currentLocale = "es-es"
				TestLocalizationChangedSignal:Fire()

				greeting = localization:getText("Spec", "greeting_formal")
				expect(greeting).to.equal("Hola")

				local farewell = localization:getProjectText(LIBRARY_PROJECT, "Spec", "farewell_formal")
				expect(farewell).to.equal("Adios")
			end)
		end)

		it("should remove the observer to the localization changed signal when it is destroyed", function()
			local currentLocale = "en-us"
			local callCount = 0
			local function getLocale()
				callCount = callCount + 1
				return currentLocale
			end

			runTestWithLocalization({
				getLocale = getLocale,
			}, function(localization)
				expect(callCount).to.equal(1)

				local greeting = localization:getText("Spec", "greeting_formal")
				expect(greeting).to.equal("Hello")

				-- trigger a locale change
				currentLocale = "es-es"
				TestLocalizationChangedSignal:Fire()

				greeting = localization:getText("Spec", "greeting_formal")
				expect(greeting).to.equal("Hola")
				expect(callCount).to.equal(2)

				-- destroy the connection and trigger another change
				localization:destroy()
				currentLocale = "en-us"
				TestLocalizationChangedSignal:Fire()

				greeting = localization:getText("Spec", "greeting_formal")
				expect(greeting).to.equal("Hola")
				expect(callCount).to.equal(2)
			end)
		end)

		it("should fallback to the base language if it is available when a specific locale isn't supported", function()
			runTestWithLocalization({
				localeId = "es-mx",
			}, function(localization)
				local greeting = localization:getText("Spec", "greeting_formal")
				expect(greeting).to.equal("Hola")

				local farewell = localization:getProjectText(LIBRARY_PROJECT, "Spec", "farewell_formal")
				expect(farewell).to.equal("Adios")
			end)
		end)
	end)

	describe("Localization.mock()", function()
		it("should be creatable with no arguments", function()
			local mock = Localization.mock()
			mock:destroy()
		end)

		it("should return the key and args that were passed into getText", function()
			local mock = Localization.mock()

			local strA = mock:getText("Anything", "greeting_formal")
			expect(strA).to.equal("Studio.Test.Anything.greeting_formal:[]")

			local strB = mock:getText("Anything", "greeting_informal", {
				friend = "Jane Doe",
				days = 1
			})
			expect(strB).to.equal("Studio.Test.Anything.greeting_informal:[friend:Jane Doe,days:1]")

			mock:destroy()
		end)
	end)
end