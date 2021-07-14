-- This function hides ABTestService away and provides a quick interface for getting a test's variation.
-- Should the requested test not exist, it will return the Control group.

local ABTestService = game:GetService("ABTestService")

local AB_TEST_GROUP_CONTROL = "Control"

-- abTestName : (string) the name of test. ex) "AllUsers.Studio.ExampleTestName"
-- abTestService : (table, optional) an optional override for ABTestService
-- RETURNS : (int) the variation that the user is in. 0 = Control
return function(abTestName, abTestService)
	assert(type(abTestName) == "string", "Expected abTestName to be a string")
	if abTestService then
		assert(type(abTestService.GetVariant) == "function", "Expected the abTestService object to have a GetVariant member function")
	else
		abTestService = ABTestService
	end

	local variation = abTestService:GetVariant(abTestName)
	if variation == AB_TEST_GROUP_CONTROL then
		return 0
	else
		local _, _, variationNumber = string.find(variation, "Variation(%d+)")
		if not variationNumber then
			return 0
		end

		return tonumber(variationNumber)
	end
end
