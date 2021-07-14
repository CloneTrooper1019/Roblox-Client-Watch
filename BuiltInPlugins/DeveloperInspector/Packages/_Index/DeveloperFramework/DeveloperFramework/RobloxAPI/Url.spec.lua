return function()
	local ContentProvider = game:GetService("ContentProvider")
	local RobloxAPI = script.Parent
	local Url = require(RobloxAPI.Url)

	it("has not changed the base url for debugging", function()
		local baseUrl = Url.new()
		local contentProviderUrl = ContentProvider.BaseUrl
		expect(contentProviderUrl).to.equal(baseUrl.BASE_URL)
	end)

	describe("new()", function()
		it("should append a slash if the base url is missing it", function()
			local baseUrl = Url.new("https://www.roblox.com")
			expect(baseUrl.BASE_URL).to.equal("https://www.roblox.com/")
		end)

		it("should construct all of the baseUrls based on the current environment", function()
			local baseUrl = Url.new("https://www.roblox.com")
			expect(baseUrl.API_URL).to.equal("https://api.roblox.com/")
			expect(baseUrl.APIS_URL).to.equal("https://apis.roblox.com/")
			expect(baseUrl.ASSET_GAME_URL).to.equal("https://assetgame.roblox.com/")
			expect(baseUrl.AUTH_URL).to.equal("https://auth.roblox.com/")
			expect(baseUrl.CATALOG_URL).to.equal("https://catalog.roblox.com/")
			expect(baseUrl.CHAT_URL).to.equal("https://chat.roblox.com/")
			expect(baseUrl.DATA_URL).to.equal("https://data.roblox.com/")
			expect(baseUrl.DEVELOP_URL).to.equal("https://develop.roblox.com/")
			expect(baseUrl.GAMES_INTERNATIONALIZATION_URL).to.equal(
				"https://gameinternationalization.roblox.com/")
			expect(baseUrl.GAMES_URL).to.equal("https://games.roblox.com/")
			expect(baseUrl.GROUPS_URL).to.equal("https://groups.roblox.com/")
			expect(baseUrl.ITEM_CONFIGURATION_URL).to.equal("https://itemconfiguration.roblox.com/")
			expect(baseUrl.LOCALE_URL).to.equal("https://locale.roblox.com/")
			expect(baseUrl.LOCALIZATION_TABLES_URL).to.equal("https://localizationtables.roblox.com/")
			expect(baseUrl.NOTIFICATIONS_URL).to.equal("https://notifications.roblox.com/")
			expect(baseUrl.PUBLISH_URL).to.equal("https://publish.roblox.com/")
			expect(baseUrl.REALTIME_URL).to.equal("https://realtime.roblox.com/")
			expect(baseUrl.TRANSLATION_ROLES_URL).to.equal("https://translationroles.roblox.com/")
			expect(baseUrl.WEB_URL).to.equal("https://web.roblox.com/")
		end)

		it("should properly handle vanity sites and test environments", function()
			local baseUrl = Url.new("https://www.sitetest1.robloxlabs.com")
			expect(baseUrl.API_URL).to.equal("https://api.sitetest1.robloxlabs.com/")

			baseUrl = Url.new("https://kyle.sitetest1.robloxlabs.com")
			expect(baseUrl.API_URL).to.equal("https://api.sitetest1.robloxlabs.com/")
		end)
	end)

	describe("composeUrl()", function()
		it("should format a url", function()
			local url = Url.composeUrl("https://www.test.com/", "a/b/c")
			expect(url).to.equal("https://www.test.com/a/b/c")
		end)

		it("should format a url with a table of arguments", function()
			local url = Url.composeUrl("https://www.test.com/", "a/b/c", { d = "123" })
			expect(url).to.equal("https://www.test.com/a/b/c?d=123")
		end)

		it("should format a url with multiple arguments", function()
			local url = Url.composeUrl("https://www.test.com/", "a/b/c", {
				d = "123",
				e = "456"
			})

			-- the order that arguments are added is not deterministic, so check both options
			local formatA = "https://www.test.com/a/b/c?d=123&e=456"
			local formatB = "https://www.test.com/a/b/c?e=456&d=123"

			local matchesUrl = (url == formatA) or (url == formatB)
			expect(matchesUrl).to.equal(true)
		end)

		it("should format a url with any variant data type", function()
			local numberUrl = Url.composeUrl("https://www.test.com/", "a/b/c", { d = 123 })
			expect(numberUrl).to.equal("https://www.test.com/a/b/c?d=123")

			local stringUrl = Url.composeUrl("https://www.test.com/", "a/b/c", { d = "123" })
			expect(stringUrl).to.equal("https://www.test.com/a/b/c?d=123")

			local boolUrl = Url.composeUrl("https://www.test.com/", "a/b/c", { d = true })
			expect(boolUrl).to.equal("https://www.test.com/a/b/c?d=true")

			local arrayUrl = Url.composeUrl("https://www.test.com/", "a/b/c", { d = {1, 2, 3} })
			expect(arrayUrl).to.equal("https://www.test.com/a/b/c?d=1,2,3")
		end)

		it("should throw errors with invalid input", function()
			local validBase = "https://www.test.com/"
			local validPath = "a/b/c"
			local validArgs = { d = "123" }

			-- base
			expect(function() Url.composeUrl(nil, validPath, validArgs) end).to.throw()
			expect(function() Url.composeUrl(123, validPath, validArgs) end).to.throw()
			expect(function() Url.composeUrl({}, validPath, validArgs) end).to.throw()
			expect(function() Url.composeUrl(newproxy(true), validPath, validArgs) end).to.throw()
			expect(function() Url.composeUrl(true, validPath, validArgs) end).to.throw()

			-- path
			expect(function() Url.composeUrl(validBase, nil, validArgs) end).to.throw()
			expect(function() Url.composeUrl(validBase, 123, validArgs) end).to.throw()
			expect(function() Url.composeUrl(validBase, {}, validArgs) end).to.throw()
			expect(function() Url.composeUrl(validBase, newproxy(true), validArgs) end).to.throw()
			expect(function() Url.composeUrl(validBase, true, validArgs) end).to.throw()

			-- args
			expect(function() Url.composeUrl(validBase, validPath, 123) end).to.throw()
			expect(function() Url.composeUrl(validBase, validPath, "123") end).to.throw()
			expect(function() Url.composeUrl(validBase, validPath, newproxy(true)) end).to.throw()
			expect(function() Url.composeUrl(validBase, validPath, true) end).to.throw()
		end)

		it("should throw errors for invalid argument datatypes", function()
			-- userdata
			expect(function()
				Url.composeUrl("https://www.test.com/", "a/b/c", { d = newproxy(true) })
			end).to.throw()

			-- maps
			expect(function()
				Url.composeUrl("https://www.test.com/", "a/b/c", { d = { e = "f" } })
			end).to.throw()

			-- empty array
			expect(function()
				Url.composeUrl("https://www.test.com/", "a/b/c", { d = {} })
			end).to.throw()
		end)

		it("should return a url which is correctly encoded", function()
			local encodedURL = "https://www.test.com/a/b/c?d=hello%5Fworld"
			local url = Url.composeUrl("https://www.test.com/", "a/b/c", {
				d = "hello_world",
			})
			expect(url).to.equal(encodedURL)
		end)

		it("should return a url whose array objects are correctly encoded", function()
			local url = Url.composeUrl("https://www.test.com/", "a/b/c", {
				d = "hello_world",
				e = "wow!"
			})

			-- the order that arguments are added is not deterministic, so check both options
			local formatA = "https://www.test.com/a/b/c?d=hello%5Fworld&e=wow%21"
			local formatB = "https://www.test.com/a/b/c?e=wow%21&d=hello%5Fworld"

			local matchesUrl = (url == formatA) or (url == formatB)
			expect(matchesUrl).to.equal(true)
		end)
	end)
end
