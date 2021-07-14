local longPropComment = [[The size of the component, except in a specific scenario
that must be explained in an amount of detail that spans multiple
lines of explanation.]]

return function()
	local DocParser = require(script.Parent.DocParser)

	local oneProp = [[
	This is a component with a Size prop.
	Required Props:
		UDim2 Size: The size of the component.]]

	local fewProps = [[
	Required Props:
		UDim2 Size: The size of the component.
		UDim2 Position: The position of the component.
		Vector2 AnchorPoint: The anchor point of the component.]]

	local allTypes = [[
	Required Props:
		UDim2 Size: The size of the component.
	Optional Props:
		number LayoutOrder: The layout order of the component.
	Style Values:
		Color3 Color: The color of the component.]]

	local longProp = [[
	Required Props:
		UDim2 Size: The size of the component, except in a specific scenario
			that must be explained in an amount of detail that spans multiple
			lines of explanation.]]

	it("should parse a single prop", function()
		local parser = DocParser.new("Test")
		local docs = parser:parseComments(oneProp)
		expect(docs).to.be.ok()
		expect(docs.Summary).to.equal("This is a component with a Size prop.")
		expect(docs.Required).to.be.ok()
		expect(docs.Required[1]).to.be.ok()
		expect(docs.Required[1].Name).to.equal("Size")
		expect(docs.Required[1].Type).to.equal("UDim2")
		expect(docs.Required[1].Comment).to.equal("The size of the component.")
	end)

	it("should parse several props", function()
		local parser = DocParser.new("Test")
		local docs = parser:parseComments(fewProps)
		expect(docs).to.be.ok()
		expect(docs.Required).to.be.ok()
		expect(#docs.Required).to.equal(3)
	end)

	it("should parse all types of props", function()
		local parser = DocParser.new("Test")
		local docs = parser:parseComments(allTypes)
		expect(docs.Required).to.be.ok()
		expect(docs.Required[1]).to.be.ok()
		expect(docs.Optional).to.be.ok()
		expect(docs.Optional[1]).to.be.ok()
		expect(docs.Style).to.be.ok()
		expect(docs.Style[1]).to.be.ok()
	end)

	it("should parse long prop comments", function()
		local parser = DocParser.new("Test")
		local docs = parser:parseComments(longProp)
		expect(docs.Required[1].Comment).to.equal(longPropComment)
	end)

	local typoHeader = [[
	Requied Props:
		UDim2 Size: The size of the component.]]

	local malformedProp = [[
	Required Props:
		UDim2 Size = The size of the component.]]

	local malformedProp2 = [[
	Required Props:
		UDim2 Size : The size of the component.]]

	local badIndentation = [[
	Required Props:
	UDim2 Size: The size of the component.]]

	local badIndentation2 = [[
	Required Props:
		UDim2 Size: The size of the component.
		Here's more information about the Size.]]

	local badIndentation3 = [[
	Some explanation of the component.
		It also has indentation in it.]]

	local missingHeader = [[
	This is a comment explaning the component.
		UDim2 Size: The size of the component.]]

	describe("Error cases", function()
		it("should catch typos in headers", function()
			local parser = DocParser.new("Test")
			expect(function()
				parser:parseComments(typoHeader)
			end).to.throw()
		end)

		it("should expect the correct syntax for a prop", function()
			local parser = DocParser.new("Test")
			expect(function()
				parser:parseComments(malformedProp)
			end).to.throw()

			expect(function()
				parser:parseComments(malformedProp2)
			end).to.throw()
		end)

		it("should expect the indentation to be correct", function()
			local parser = DocParser.new("Test")
			expect(function()
				parser:parseComments(badIndentation)
			end).to.throw()

			expect(function()
				parser:parseComments(badIndentation2)
			end).to.throw()

			expect(function()
				parser:parseComments(badIndentation3)
			end).to.throw()
		end)

		it("should expect to see a header before prop declarations", function()
			local parser = DocParser.new("Test")
			expect(function()
				parser:parseComments(missingHeader)
			end).to.throw()
		end)
	end)

	describe("toInterface", function()
		it("should expect a correctly formatted docs table", function()
			expect(function()
				DocParser.toInterface()
			end).to.throw()

			expect(function()
				DocParser.toInterface({})
			end).to.throw()
		end)

		it("should return a props interface", function()
			local interface = DocParser.toInterface({
				Required = {},
				Optional = {},
				Style = {},
			})
			expect(interface).to.be.ok()
		end)

		it("should return a style interface only if there are style values", function()
			local _, styleInterface = DocParser.toInterface({
				Required = {},
				Optional = {},
				Style = {},
			})
			expect(styleInterface).never.to.be.ok()

			_, styleInterface = DocParser.toInterface({
				Required = {},
				Optional = {},
				Style = {
					{
						Name = "Color",
						Type = "Color3",
					},
				},
			})
			expect(styleInterface).to.be.ok()
		end)

		it("should expect all types to be valid t types", function()
			local docs = {
				Required = {
					{
						Name = "Integer",
						Type = "int", --int is not a valid t type, use number instead
					},
				},
				Optional = {},
				Style = {},
			}

			expect(function()
				DocParser.toInterface(docs)
			end).to.throw()
		end)

		it("should work for custom types", function()
			local docs = {
				Required = {
					{
						Name = "Background",
						Type = "Component",
					},
				},
				Optional = {},
				Style = {},
			}

			local interface = DocParser.toInterface(docs)
			expect(interface).to.be.ok()

			expect(interface({
				Background = {},
			})).to.equal(false)

			expect(interface({
				Background = {
					render = function()
					end,
				},
			})).to.equal(true)
		end)

		it("should work for enum values", function()
			local docs = {
				Required = {
					{
						Name = "Font",
						Type = "Enum.Font",
					},
				},
				Optional = {},
				Style = {},
			}

			local interface = DocParser.toInterface(docs)
			expect(interface).to.be.ok()

			expect(interface({
				Font = Enum.Font.SourceSans,
			})).to.equal(true)

			expect(interface({
				Font = "Some string",
			})).to.equal(false)
		end)

		it("should work for array values", function()
			local docs = {
				Required = {
					{
						Name = "Items",
						Type = "array[string]",
					},
				},
				Optional = {},
				Style = {},
			}

			local interface = DocParser.toInterface(docs)
			expect(interface).to.be.ok()

			expect(interface({
				Items = {"str"}
			})).to.equal(true)

			expect(interface({
				Items = {["somestringKey"] = "str"},
			})).to.equal(false)
		end)

		it("should create a union if multiple props under the same name exist", function()
			local docs = {
				Required = {
					{
						Name = "Padding",
						Type = "number",
					},
					{
						Name = "Padding",
						Type = "table",
					},
				},
				Optional = {},
				Style = {},
			}

			local interface = DocParser.toInterface(docs)
			expect(interface({
				Padding = 3,
			})).to.equal(true)

			expect(interface({
				Padding = {},
			})).to.equal(true)

			expect(interface({
				Padding = "Some string",
			})).to.equal(false)
		end)

		it("should be a strict interface for props", function()
			local docs = {
				Required = {
					{
						Name = "Size",
						Type = "UDim2",
					},
				},
				Optional = {},
				Style = {},
			}

			local interface = DocParser.toInterface(docs)
			expect(interface({})).to.equal(false)

			expect(interface({
				Size = UDim2.new(),
				NotInTable = "Some string",
			})).to.equal(false)

			expect(interface({
				Size = "Some string",
			})).to.equal(false)

			expect(interface({
				Size = UDim2.new(),
			})).to.equal(true)
		end)

		it("should be a non-strict interface for style", function()
			local docs = {
				Required = {},
				Optional = {},
				Style = {
					{
						Name = "Color",
						Type = "Color3",
					},
				},
			}

			local _, styleInterface = DocParser.toInterface(docs)
			expect(styleInterface({})).to.equal(true)

			expect(styleInterface({
				Color = Color3.new(),
				NotInTable = "Some string",
			})).to.equal(true)

			expect(styleInterface({
				Color = Color3.new(),
			})).to.equal(true)

			expect(styleInterface({
				Color = "Some string",
			})).to.equal(false)
		end)

		it("should make all props in the Optional table optional", function()
			local docs = {
				Required = {},
				Optional = {
					{
						Name = "Size",
						Type = "UDim2",
					},
				},
				Style = {},
			}

			local interface = DocParser.toInterface(docs)
			expect(interface({})).to.equal(true)

			expect(interface({
				Size = UDim2.new(),
			})).to.equal(true)

			expect(interface({
				Size = "Some string",
			})).to.equal(false)
		end)
	end)
end
