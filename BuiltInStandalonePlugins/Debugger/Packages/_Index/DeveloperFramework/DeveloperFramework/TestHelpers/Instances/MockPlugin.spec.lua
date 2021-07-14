local MockPlugin = require(script.Parent.MockPlugin)

return function()
	it("should have a mouse", function()
		local plugin = MockPlugin.new()
		expect(plugin:GetMouse()).to.be.ok()
	end)

	it("should create toolbars", function()
		local plugin = MockPlugin.new()
		local toolbar = plugin:CreateToolbar("Foo")

		expect(toolbar).to.be.ok()
		expect(toolbar._plugin).to.equal(plugin)
		expect(toolbar._id).to.equal("Foo")
		expect(toolbar.Text).to.equal("Foo")

		toolbar:Destroy()
		plugin:Destroy()
	end)

	describe("activation", function()
		it("should work", function()
			local plugin = MockPlugin.new()
			expect(plugin:IsActivated()).to.equal(false)
			expect(plugin:IsActivatedWithExclusiveMouse()).to.equal(false)

			plugin:Activate()
			expect(plugin:IsActivated()).to.equal(true)
			expect(plugin:IsActivatedWithExclusiveMouse()).to.equal(false)

			plugin:Activate(true)
			expect(plugin:IsActivated()).to.equal(true)
			expect(plugin:IsActivatedWithExclusiveMouse()).to.equal(true)

			plugin:Deactivate()
			expect(plugin:IsActivated()).to.equal(false)
			expect(plugin:IsActivatedWithExclusiveMouse()).to.equal(false)
		end)

		it("should fire a signal when deactivated", function()
			local signalFired = false

			local plugin = MockPlugin.new()
			local con = plugin.Deactivation:Connect(function()
				signalFired = true
			end)

			-- Plugin starts deactivated so this should do nothing
			plugin:Deactivate()
			expect(signalFired).to.equal(false)

			plugin:Activate()
			plugin:Deactivate()
			expect(signalFired).to.equal(true)

			con:Disconnect()
		end)

		it("should deactivate other plugins if mockedPlugins set is given", function()
			local mockedPlugins = {}

			local p1 = MockPlugin.new("", mockedPlugins)
			local p2 = MockPlugin.new("", mockedPlugins)

			expect(p1:IsActivated()).to.equal(false)
			expect(p2:IsActivated()).to.equal(false)

			p1:Activate()
			expect(p1:IsActivated()).to.equal(true)
			expect(p2:IsActivated()).to.equal(false)

			p2:Activate()
			expect(p1:IsActivated()).to.equal(false)
			expect(p2:IsActivated()).to.equal(true)
		end)
	end)
end
