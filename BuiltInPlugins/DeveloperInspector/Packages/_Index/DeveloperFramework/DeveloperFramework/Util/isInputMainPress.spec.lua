return function()
	local isInputMainPress = require(script.Parent.isInputMainPress)
	it("should work as expected", function()
		expect(isInputMainPress({
			UserInputType = Enum.UserInputType.MouseButton1
		})).to.equal(true)
		expect(isInputMainPress({
			UserInputType = Enum.UserInputType.Touch
		})).to.equal(true)
		expect(isInputMainPress({
			UserInputType = Enum.UserInputType.Gamepad1
		})).to.equal(true)
		expect(isInputMainPress({
			UserInputType = Enum.UserInputType.MouseButton2
		})).to.equal(false)
		expect(isInputMainPress({
			UserInputType = Enum.UserInputType.Gamepad2
		})).to.equal(false)
	end)
end
