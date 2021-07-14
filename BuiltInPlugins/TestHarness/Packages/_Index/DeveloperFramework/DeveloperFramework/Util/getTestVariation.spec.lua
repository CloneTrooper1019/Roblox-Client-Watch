return function()
	local getTestVariation = require(script.Parent.getTestVariation)
	local VARIATION_NAME_CONTROL = "Control"

	local function createTestService(result)
		local DebugABService = {}

		function DebugABService:GetVariant(testName)
			return result
		end

		return DebugABService
	end

	it("should expect some test name", function()
		expect(function()
			getTestVariation()
		end).to.throw()
	end)

	it("should return zero when in the control group", function()
		local debugABTestService = createTestService(VARIATION_NAME_CONTROL)
		local variation = getTestVariation("AllUsers.Studio.ShouldShowZero", debugABTestService)
		expect(variation).to.equal(0)
	end)

	it("should return the number of the variation when not in the control group", function()
		local debugABTestService = createTestService("Variation1")
		local variation = getTestVariation("AllUsers.Studio.ShouldShowNumber", debugABTestService)
		expect(variation).to.equal(1)

		-- there aren't any variations past 8, but it should work with any number
		debugABTestService = createTestService("Variation23")
		variation = getTestVariation("AllUsers.Studio.ShouldShowNumber", debugABTestService)
		expect(variation).to.equal(23)

		debugABTestService = createTestService("Variation456")
		variation = getTestVariation("AllUsers.Studio.ShouldShowNumber", debugABTestService)
		expect(variation).to.equal(456)
	end)
end