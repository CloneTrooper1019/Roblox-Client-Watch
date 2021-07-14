return function()
	local UIFolderData = require(script.Parent.UIFolderData)

	describe("new", function()
		it("should return a table with at least one entry", function()
			expect(UIFolderData).to.be.ok()
			expect(typeof(UIFolderData)).to.equal("table")
			expect(next(UIFolderData) ~= nil).to.equal(true)
		end)

		it("should have a name for each entry in the table", function()
			local allEntriesHaveNameAttribute = true
			for _,v in pairs(UIFolderData) do
				if v.name == nil then
					allEntriesHaveNameAttribute = false
					break
				end
			end
			expect(allEntriesHaveNameAttribute).to.equal(true)
		end)
	end)
end