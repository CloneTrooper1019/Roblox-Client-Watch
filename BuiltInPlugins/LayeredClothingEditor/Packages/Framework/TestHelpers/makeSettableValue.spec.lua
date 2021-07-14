local makeSettableValue = require(script.Parent.makeSettableValue)

return function()
	it("should store the initial value", function()
		local v = makeSettableValue("foo")
		expect(v.get()).to.equal("foo")

		v = makeSettableValue(12345)
		expect(v.get()).to.equal(12345)
	end)

	it("should update the stored value", function()
		local v = makeSettableValue("foo")

		v.set("bar")
		expect(v.get()).to.equal("bar")

		v.set(13579)
		expect(v.get()).to.equal(13579)
	end)

	it("should fire a changed signal", function()
		local signalFired = false

		local v = makeSettableValue("foo")
		local con = v.changed:Connect(function()
			signalFired = true
		end)

		expect(signalFired).to.equal(false)
		v.set("bar")
		expect(signalFired).to.equal(true)

		signalFired = false
		v.set("baz")
		expect(signalFired).to.equal(true)

		con:Disconnect()
	end)
end
