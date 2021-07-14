return function()
	local StyleTable = require(script.Parent.StyleTable)

	describe("new", function()
		it("should expect a name", function()
			expect(function()
				StyleTable.new()
			end).to.throw()
		end)

		it("should expect a createFunc function", function()
			expect(function()
				StyleTable.new("Test")
			end).to.throw()
		end)

		it("should return what was created in createFunc", function()
			local styleTable = StyleTable.new("Test", function()
				return {
					Default = {},
					OtherStyle = {},
				}
			end)
			expect(styleTable).to.be.ok()
			expect(styleTable.Default).to.be.ok()
			expect(styleTable.OtherStyle).to.be.ok()
		end)
	end)

	describe("extend", function()
		it("should expect the parent table to have an entry for every child entry", function()
			local parentTable = StyleTable.new("Parent", function()
				return {
					Button = {},
				}
			end)
			local childTable = StyleTable.new("Child", function()
				return {
					Button = {},
					TextLabel = {},
				}
			end)
			expect(function()
				StyleTable.extend(parentTable, childTable)
			end).to.throw()
		end)

		it("should make a new table that adds the child styles", function()
			local parentTable = StyleTable.new("Parent", function()
				return {
					Button = {
						Default = {},
					},
				}
			end)
			local childTable = StyleTable.new("Child", function()
				return {
					Button = {
						WackyButton = {},
					},
				}
			end)
			local newStyles = StyleTable.extend(parentTable, childTable)
			expect(newStyles).to.be.ok()
			expect(newStyles.Button).to.be.ok()
			expect(newStyles.Button.Default).to.be.ok()
			expect(newStyles.Button.WackyButton).to.be.ok()
		end)

		it("should preserve the original StyleTables", function()
			local parentTable = StyleTable.new("Parent", function()
				return {
					Button = {
						Default = {},
					},
				}
			end)
			local childTable = StyleTable.new("Child", function()
				return {
					Button = {
						WackyButton = {},
					},
				}
			end)
			StyleTable.extend(parentTable, childTable)
			expect(parentTable.Button.WackyButton).never.to.be.ok()
			expect(childTable.Button.Default).never.to.be.ok()
		end)
	end)
end