local StatusCodes = require(script.Parent.StatusCodes)

return function()
	it("should have unique values for each value", function()
		for k1, v1 in pairs(StatusCodes) do
			for k2, v2 in pairs(StatusCodes) do
				if k1 ~= k2 then
					expect(v1).to.never.equal(v2)
				end
			end
		end
	end)

	-- This will be the only value I test, as it is the most important for validating success
	it("should have 200 for its value of OK", function()
		expect(StatusCodes.OK).to.equal(200)
	end)
end