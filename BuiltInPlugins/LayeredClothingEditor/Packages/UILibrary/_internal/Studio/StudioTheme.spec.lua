return function()
	local Library = script.Parent.Parent
	local StudioTheme = require(Library.Studio.StudioTheme)

	local function createValues()
		return {}
	end

	describe("StudioTheme.new", function()
		it("should return a new StudioTheme", function()
			local theme = StudioTheme.new(createValues)
			expect(theme).to.be.ok()
			expect(theme.values).to.be.ok()

			theme:destroy()
		end)

		it("should have a getTheme function that gets the Studio theme", function()
			local theme = StudioTheme.new(createValues)
			expect(theme.getTheme).to.be.ok()
			expect(theme.getTheme()).to.equal(settings().Studio.Theme)

			theme:destroy()
		end)

		it("should listen for Studio theme changes", function()
			local event = Instance.new("BindableEvent")
			local theme = StudioTheme.new(createValues, event.Event)
			expect(theme.themeChangedConnection).to.be.ok()

			local called = false
			theme:connect(function()
				called = true
			end)
			event:Fire()
			expect(called).to.equal(true)

			event:Destroy()
			theme:destroy()
		end)
	end)

	describe("StudioTheme.newDummyTheme", function()
		it("should return a new fake StudioTheme", function()
			local theme = StudioTheme.newDummyTheme(createValues)
			expect(theme).to.be.ok()
			expect(theme.values).to.be.ok()

			theme:destroy()
		end)

		it("should have a getTheme function that returns a constant color", function()
			local theme = StudioTheme.newDummyTheme(createValues)
			expect(theme.getTheme).to.be.ok()
			expect(theme.getTheme()).never.to.equal(settings().Studio.Theme)
			expect(theme.getTheme().GetColor).to.be.ok()
			expect(theme.getTheme().GetColor()).to.equal(Color3.new())

			theme:destroy()
		end)

		it("should not listen for theme changes", function()
			local theme = StudioTheme.newDummyTheme(createValues)
			expect(theme.themeChangedConnection).never.to.be.ok()

			theme:destroy()
		end)
	end)

	describe("StudioTheme.recalculateTheme", function()
		it("should call the createValues function", function()
			local called = false

			local theme = StudioTheme.new(function()
				called = true
				return {}
			end)

			expect(called).to.equal(true)
			called = false
			theme:recalculateTheme()
			expect(called).to.equal(true)

			theme:destroy()
		end)

		it("should update the theme values", function()
			local called = false

			local theme = StudioTheme.new(function()
				return called and {newColor = Color3.new()} or {}
			end)

			expect(theme.values.newColor).never.to.be.ok()
			called = true
			theme:recalculateTheme()
			expect(theme.values.newColor).to.be.ok()

			theme:destroy()
		end)
	end)
end