return function()
	local StudioUIFolderData = require(script.Parent.StudioUIFolderData)

	describe("new", function()
		it("should return a table with at least one entry", function()
			expect(StudioUIFolderData).to.be.ok()
			expect(typeof(StudioUIFolderData)).to.equal("table")
			expect(next(StudioUIFolderData) ~= nil).to.equal(true)
		end)

		it("should have a name for each entry in the table", function()
			local allEntriesHaveNameAttribute = true
			for _,v in pairs(StudioUIFolderData) do
				if v.name == nil then
					allEntriesHaveNameAttribute = false
					break
				end
			end
			expect(allEntriesHaveNameAttribute).to.equal(true)
		end)
	end)
end