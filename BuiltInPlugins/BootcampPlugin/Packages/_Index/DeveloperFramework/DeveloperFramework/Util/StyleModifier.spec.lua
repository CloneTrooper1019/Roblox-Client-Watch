return function()
	local StyleModifier = require(script.Parent.StyleModifier)

	it("should contain enum values", function()
		local hover = StyleModifier.Hover
		expect(hover).to.be.ok()
	end)

	it("should be able to check for equality", function()
		local hover = StyleModifier.Hover
		local hover2 = StyleModifier.Hover
		expect(hover).to.equal(hover2)
	end)

	it("should not work with strings", function()
		local hover = StyleModifier.Hover
		expect(hover).never.to.equal("Hover")
	end)

	it("should throw if a nonexistent enum value is called", function()
		expect(function()
			local _ = StyleModifier.NonexistentValue
		end).to.throw()
	end)

	it("should throw if attempting to modify the values", function()
		expect(function()
			StyleModifier.NonexistentValue = {}
		end).to.throw()
	end)
end