return function()
	local FrameworkRoot = script.Parent.Parent
	local Http = require(FrameworkRoot.Http)
	local RobloxAPI = require(FrameworkRoot.RobloxAPI)
	local Url = require(script.Parent.Url)
	local Networking = Http.Networking

	describe("new()", function()
		it("should construct without arguments", function()
			local api = RobloxAPI.new()
			expect(api).to.be.ok()
		end)

		it("should construct with arguments", function()
			local networkingImpl = Networking.mock()
			local api = RobloxAPI.new({
				networking = networkingImpl,
			})
			expect(api).to.be.ok()


			local url = Url.new("https://www.roblox.com")
			api = RobloxAPI.new({
				baseUrl = url,
			})
			expect(api).to.be.ok()


			api = RobloxAPI.new({
				networking = networkingImpl,
				baseUrl = url,
			})
			expect(api).to.be.ok()
		end)
	end)
end
