return function()
	local Signal = require(script.Parent.Signal)

	it("should construct from nothing", function()
		local signal = Signal.new()

		expect(signal).to.be.ok()
	end)

	it("should fire connected callbacks", function()
		local callCount = 0
		local value1 = "Hello World"
		local value2 = 7

		local callback = function(arg1, arg2)
			expect(arg1).to.equal(value1)
			expect(arg2).to.equal(value2)
			callCount = callCount + 1
		end

		local signal = Signal.new()

		local connection = signal:Connect(callback)
		signal:Fire(value1, value2)

		expect(callCount).to.equal(1)

		connection:Disconnect()
		signal:Fire(value1, value2)

		expect(callCount).to.equal(1)
	end)

	it("should disconnect handlers", function()
		local callback = function()
			error("Callback was called after disconnect!")
		end

		local signal = Signal.new()

		local connection = signal:Connect(callback)
		connection:Disconnect()

		signal:Fire()
	end)

	it("should fire handlers in order", function()
		local signal = Signal.new()
		local x = 0
		local y = 0

		local callback1 = function()
			expect(x).to.equal(0)
			expect(y).to.equal(0)
			x = x + 1
		end

		local callback2 = function()
			expect(x).to.equal(1)
			expect(y).to.equal(0)
			y = y + 1
		end

		signal:Connect(callback1)
		signal:Connect(callback2)
		signal:Fire()

		expect(x).to.equal(1)
		expect(y).to.equal(1)
	end)

	it("should continue firing despite mid-event disconnection", function()
		local signal = Signal.new()
		local countA = 0
		local countB = 0

		local connectionA
		connectionA = signal:Connect(function()
			connectionA:Disconnect()
			countA = countA + 1
		end)

		signal:Connect(function()
			countB = countB + 1
		end)

		signal:Fire()

		expect(countA).to.equal(1)
		expect(countB).to.equal(1)
	end)

	it("should ignore listeners that were disconnected during event evaluation", function()
		local signal = Signal.new()
		local countA = 0
		local countB = 0

		local connectionB

		signal:Connect(function()
			countA = countA + 1
			connectionB:Disconnect()
		end)

		connectionB = signal:Connect(function()
			countB = countB + 1
		end)

		signal:Fire()

		expect(countA).to.equal(1)
		expect(countB).to.equal(0)
	end)
end