local Framework = script.Parent.Parent
local CrossPluginCommunication = require(Framework.Util.CrossPluginCommunication)

return function()
	local TEST_NAMESPACE = "test"

	-- TODO DEVTOOLS-4397: Move cleanup to afterEach hook after the dependency structure is fixed

	local hostService = workspace

	local function createTestComms()
		return CrossPluginCommunication.new(TEST_NAMESPACE, hostService)
	end

	describe("Invoke", function()

		it("should throw if the function is missing", function()
			local comms = createTestComms()

			expect(function()
				comms:Invoke("blah")
			end).to.throw()

			comms:cleanup()
		end)
	end)

	describe("OnInvoke", function()

		it("should create the namespace if it does not exist", function()
			local comms = createTestComms()

			comms:OnInvoke("blah", function() end)

			local namespace = hostService:FindFirstChild(CrossPluginCommunication.BASE_FOLDER_NAME):FindFirstChild(TEST_NAMESPACE)

			assert(namespace)

			expect(namespace:FindFirstChild("blah"):IsA("BindableFunction")).to.equal(true)

			comms:cleanup()
		end)

		it("should throw if the function is already extant (bound)", function()

			local comms = createTestComms()

			comms:OnInvoke("blah", function() end)

			expect(function()
				comms:OnInvoke("blah", function() end)
			end).to.throw()

			comms:cleanup()
		end)

	end)

	-- Ideally we might actually create another plugin (other than the one running this test)
	-- But currently CrossPluginCommunication is on a shared DM, and this would be unnecessary.
	--
	-- PluginManager:CreatePlugin is being deprecated.
	-- When plugin:CreatePlugin() is available we should use that
	it("should bind and call the callback with the arguments when it is invoked", function()

		local comms = createTestComms()

		local calledWith
		comms:OnInvoke("myFunc", function(a)
			calledWith = a
		end)

		comms:Invoke("myFunc", 2)
		expect(calledWith).to.equal(2)

		comms:cleanup()
	end)

end