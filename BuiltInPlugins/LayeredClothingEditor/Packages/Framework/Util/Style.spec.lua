return function()
	local Style = require(script.Parent.Style)

	describe("new", function()
		it("should expect a table of values", function()
			expect(function()
				Style.new()
			end).to.throw()
		end)

		it("should return the values", function()
			local style = Style.new({
				Color = Color3.new(),
				Text = "Text",
			})
			expect(style).to.be.ok()
			expect(style.Color).to.be.ok()
			expect(style.Text).to.be.ok()
		end)
	end)

	describe("extend", function()
		it("should join multiple styles", function()
			local firstStyle = Style.new({
				Color = Color3.new(),
				Text = "Text",
				Font = Enum.Font.SourceSans,
			})
			local secondStyle = Style.new({
				Color = Color3.new(),
				Text = "NewText",
				Bool = true,
			})
			local extended = Style.extend(firstStyle, secondStyle)
			expect(extended).to.be.ok()
			expect(extended.Color).to.be.ok()
			expect(extended.Text).to.equal("NewText")
			expect(extended.Bool).to.be.ok()
			expect(extended.Font).to.be.ok()
		end)

		it("should preserve the original styles", function()
			local firstStyle = Style.new({
				Color = Color3.new(),
				Text = "Text",
				Font = Enum.Font.SourceSans,
			})
			local secondStyle = Style.new({
				Color = Color3.new(),
				Text = "NewText",
				Bool = true,
			})
			Style.extend(firstStyle, secondStyle)
			expect(firstStyle.Text).to.equal("Text")
			expect(firstStyle.Bool).never.to.be.ok()
			expect(secondStyle.Font).never.to.be.ok()
		end)
	end)
end