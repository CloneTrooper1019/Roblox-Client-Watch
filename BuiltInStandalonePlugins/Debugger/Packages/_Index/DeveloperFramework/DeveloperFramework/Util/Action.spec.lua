return function()
	local Action = require(script.Parent.Action)

	it("should return a table", function()
		local action = Action("foo", function()
			return {}
		end)

		expect(action).to.be.a("table")
	end)

	it("should set the name of the action", function()
		local action = Action("foo", function()
			return {}
		end)

		expect(action.name).to.equal("foo")
	end)

	it("should be able to be called as a function", function()
		local action = Action("foo", function()
			return {}
		end)

		expect(action).never.to.throw()
	end)

	it("should return a table when called as a function", function()
		local action = Action("foo", function()
			return {}
		end)

		expect(action()).to.be.a("table")
	end)

	it("should set the type of the action", function()
		local action = Action("foo", function()
			return {}
		end)

		expect(action().type).to.equal("foo")
	end)

	it("should set values", function()
		local action = Action("foo", function(value)
			return {
				value = value
			}
		end)

		expect(action(100).value).to.equal(100)
	end)

	it("should throw when passed a function", function()
		local action = Action("foo", function()
			return function() end
		end)

		expect(action).to.throw()
	end)

	it("should throw with a invalid name", function()
		expect(function()
			Action(nil, function()
				return {}
			end)
		end).to.throw()

		expect(function()
			Action(100, function()
				return {}
			end)
		end).to.throw()
	end)

	it("should throw when passed a invalid function", function()
		expect(function()
			Action("foo", nil)
		end).to.throw()

		expect(function()
			Action("foo", {})
		end).to.throw()
	end)
end
