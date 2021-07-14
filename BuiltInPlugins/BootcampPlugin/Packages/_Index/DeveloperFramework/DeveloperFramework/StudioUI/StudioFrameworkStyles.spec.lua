return function()
	local StudioFrameworkStyles = require(script.Parent.StudioFrameworkStyles)

	local Framework = script.Parent.Parent
	local Util = require(Framework.Util)
	local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

	if THEME_REFACTOR then
		return
	end

	describe("new", function()
		it("should expect a studio theme", function()
			expect(function()
				StudioFrameworkStyles.new()
			end).to.throw()
		end)

		it("should expect a getColor function", function()
			expect(function()
				StudioFrameworkStyles.new(settings().Studio.Theme)
			end).to.throw()
		end)

		it("should return a table of styles", function()
			local styles = StudioFrameworkStyles.new(settings().Studio.Theme, function()
				return Color3.new()
			end)

			expect(styles).to.be.ok()
			expect(type(styles)).to.equal("table")
		end)

		it("should have a non-empty Default style for every entry", function()
			local styles = StudioFrameworkStyles.new(settings().Studio.Theme, function()
				return Color3.new()
			end)

			for name, entry in pairs(styles) do
				local ok, result = pcall(function()
					expect(entry.Default).to.be.ok()
					expect((next(entry.Default))).to.be.ok()
				end)

				if not ok then
					error(string.format("Error checking %s: %s", name, result))
				end
			end
		end)
	end)
end
