return function()
	local Immutable = require(script.Parent.Immutable)

	describe("JoinDictionaries", function()
		it("should preserve immutability", function()
			local a = {}
			local b = {}

			local c = Immutable.JoinDictionaries(a, b)

			expect(c).never.to.equal(a)
			expect(c).never.to.equal(b)
		end)

		it("should treat list-like values like dictionary values", function()
			local a = {
				[1] = 1,
				[2] = 2,
				[3] = 3
			}

			local b = {
				[1] = 11,
				[2] = 22
			}

			local c = Immutable.JoinDictionaries(a, b)

			expect(c[1]).to.equal(b[1])
			expect(c[2]).to.equal(b[2])
			expect(c[3]).to.equal(a[3])
		end)

		it("should merge dictionary values correctly", function()
			local a = {
				hello = "world",
				foo = "bar"
			}

			local b = {
				foo = "baz",
				tux = "penguin"
			}

			local c = Immutable.JoinDictionaries(a, b)

			expect(c.hello).to.equal(a.hello)
			expect(c.foo).to.equal(b.foo)
			expect(c.tux).to.equal(b.tux)
		end)

		it("should merge multiple dictionaries", function()
			local a = {
				foo = "yes"
			}

			local b = {
				bar = "yup"
			}

			local c = {
				baz = "sure"
			}

			local d = Immutable.JoinDictionaries(a, b, c)

			expect(d.foo).to.equal(a.foo)
			expect(d.bar).to.equal(b.bar)
			expect(d.baz).to.equal(c.baz)
		end)
	end)

	describe("JoinLists", function()
		it("should preserve immutability", function()
			local a = {}
			local b = {}

			local c = Immutable.JoinLists(a, b)

			expect(c).never.to.equal(a)
			expect(c).never.to.equal(b)
		end)

		it("should treat list-like values correctly", function()
			local a = {1, 2, 3}
			local b = {4, 5, 6}

			local c = Immutable.JoinLists(a, b)

			expect(#c).to.equal(6)

			for i = 1, #c do
				expect(c[i]).to.equal(i)
			end
		end)

		it("should merge multiple lists", function()
			local a = {1, 2}
			local b = {3, 4}
			local c = {5, 6}

			local d = Immutable.JoinLists(a, b, c)

			expect(#d).to.equal(6)

			for i = 1, #d do
				expect(d[i]).to.equal(i)
			end
		end)
	end)

	describe("Set", function()
		it("should preserve immutability", function()
			local a = {}

			local b = Immutable.Set(a, "foo", "bar")

			expect(b).never.to.equal(a)
		end)

		it("should treat numeric keys normally", function()
			local a = {1, 2, 3}

			local b = Immutable.Set(a, 2, 4)

			expect(b[1]).to.equal(1)
			expect(b[2]).to.equal(4)
			expect(b[3]).to.equal(3)
		end)

		it("should overwrite dictionary-like keys", function()
			local a = {
				foo = "bar",
				baz = "qux"
			}

			local b = Immutable.Set(a, "foo", "hello there")

			expect(b.foo).to.equal("hello there")
			expect(b.baz).to.equal(a.baz)
		end)
	end)

	describe("Append", function()
		it("should preserve immutability", function()
			local a = {}

			local b = Immutable.Append(a, "another happy landing")

			expect(b).never.to.equal(a)
		end)

		it("should append values", function()
			local a = {1, 2, 3}
			local b = Immutable.Append(a, 4, 5)

			expect(#b).to.equal(5)

			for i = 1, #b do
				expect(b[i]).to.equal(i)
			end
		end)
	end)

	describe("RemoveFromDictionary", function()
		it("should preserve immutability", function()
			local a = { foo = "bar" }

			local b = Immutable.RemoveFromDictionary(a, "foo")

			expect(b).to.never.equal(a)
		end)

		it("should remove fields from the dictionary", function()
			local a = {
				foo = "bar",
				baz = "qux",
				boof = "garply",
			}

			local b = Immutable.RemoveFromDictionary(a, "foo", "boof")

			expect(b.foo).to.never.be.ok()
			expect(b.baz).to.equal("qux")
			expect(b.boof).to.never.be.ok()
		end)
	end)

	describe("RemoveFromList", function()
		it("should preserve immutability", function()
			local a = {1, 2, 3}
			local b = Immutable.RemoveFromList(a, 2)

			expect(b).never.to.equal(a)
		end)

		it("should remove elements from the list", function()
			local a = {1, 2, 3}
			local b = Immutable.RemoveFromList(a, 2)

			expect(b[1]).to.equal(1)
			expect(b[2]).to.equal(3)
			expect(b[3]).never.to.be.ok()
		end)
	end)

	describe("RemoveRangeFromList", function()
		it("should preserve immutability", function()
			local a = {1, 2, 3}
			local b = Immutable.RemoveRangeFromList(a, 2, 1)

			expect(b).never.to.equal(a)
		end)

		it("should remove single elements from the middle of the list", function()
			local a = {1, 2, 3}
			local b = Immutable.RemoveRangeFromList(a, 2, 1)

			expect(b[1]).to.equal(1)
			expect(b[2]).to.equal(3)
			expect(b[3]).never.to.be.ok()
		end)

		it("should remove multiple elements from the front of the list", function()
			local a = {1, 2, 3, 4, 5, 6}
			local b = Immutable.RemoveRangeFromList(a, 1, 4)

			expect(b[1]).to.equal(5)
			expect(b[2]).to.equal(6)
			expect(b[3]).never.to.be.ok()
		end)

		it("should remove multiple elements properly from middle of the list", function()
			local a = {1, 2, 3, 4, 5, 6}
			local b = Immutable.RemoveRangeFromList(a, 2, 4)

			expect(b[1]).to.equal(1)
			expect(b[2]).to.equal(6)
			expect(b[3]).never.to.be.ok()
		end)

		it("should remove multiple elements properly from the end of the list", function()
			local a = {1, 2, 3, 4, 5, 6, 7}
			local b = Immutable.RemoveRangeFromList(a, 4, 4)

			expect(b[1]).to.equal(1)
			expect(b[2]).to.equal(2)
			expect(b[3]).to.equal(3)
			expect(b[4]).never.to.be.ok()
		end)

		it("should not remove any elements when count is 0 or less", function()
			local a = {1, 2, 3}
			local b = Immutable.RemoveRangeFromList(a, 2, 0)

			expect(b[1]).to.equal(1)
			expect(b[2]).to.equal(2)
			expect(b[3]).to.equal(3)

			local c = Immutable.RemoveRangeFromList(a, 2, -1)
			expect(c[1]).to.equal(1)
			expect(c[2]).to.equal(2)
			expect(c[3]).to.equal(3)
		end)
	end)

	describe("RemoveValueFromList", function()
		it("should preserve immutability", function()
			local a = {1, 1, 1}
			local b = Immutable.RemoveValueFromList(a, 1)

			expect(b).never.to.equal(a)
		end)

		it("should remove all elements from the list", function()
			local a = {1, 2, 2, 3}
			local b = Immutable.RemoveValueFromList(a, 2)

			expect(b[1]).to.equal(1)
			expect(b[2]).to.equal(3)
			expect(b[3]).never.to.be.ok()
		end)
	end)
end