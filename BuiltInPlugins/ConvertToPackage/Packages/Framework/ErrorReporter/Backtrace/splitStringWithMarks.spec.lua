return function()
	local splitStringWithMarks = require(script.Parent.splitStringWithMarks)

	it("should split a string if any of the supplied patterns are found", function()
		local first, second = splitStringWithMarks("this is a test", {" is a "})
		expect(first).to.equal("this")
		expect(second).to.equal("test")

		first, second = splitStringWithMarks("this is a test", {"abc", "is", "blah"})
		expect(first).to.equal("th")
		expect(second).to.equal(" is a test")
	end)

	it("should return the original string if no matches are found", function()
		local first, second = splitStringWithMarks("abcdef", { "12345", "this is a test" })
		expect(first).to.equal("abcdef")
		expect(second).to.equal("")
	end)
end