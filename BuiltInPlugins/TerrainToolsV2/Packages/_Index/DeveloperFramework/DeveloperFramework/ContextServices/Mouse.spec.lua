return function()
	local Framework = script.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local provide = require(Framework.ContextServices.provide)

	local Mouse = require(script.Parent.Mouse)

	local function testMouse()
		return {
			Icon = "rbxasset://SystemCursors/Arrow",
		}
	end

	it("should be providable as a ContextItem", function()
		local mouse = Mouse.new(testMouse())
		local element = provide({mouse}, {
			Frame = Roact.createElement("Frame"),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should return the mouse via get", function()
		local test = testMouse()
		local mouse = Mouse.new(test)
		expect(mouse:get()).to.equal(test)
	end)

	it("should expect a mouse when constructing", function()
		expect(function()
			Mouse.new()
		end).to.throw()
	end)

	describe("Implementation", function()
		it("should update the mouse icon on pushCursor", function()
			local test = testMouse()
			local mouse = Mouse.new(test)
			mouse:__pushCursor("PointingHand")
			expect(test.Icon).to.equal("rbxasset://SystemCursors/PointingHand")
		end)

		it("should update the mouse icon on popCursor", function()
			local test = testMouse()
			local mouse = Mouse.new(test)
			mouse:__pushCursor("PointingHand")
			mouse:__popCursor()
			expect(test.Icon).to.equal("rbxasset://SystemCursors/Arrow")
		end)

		it("should clear all stacks when resetCursor is called", function()
			local test = testMouse()
			local mouse = Mouse.new(test)
			mouse:__pushCursor("PointingHand")
			mouse:__pushCursor("PointingHand", 2)
			mouse:__resetCursor()
			expect((next(mouse.cursors))).never.to.be.ok()
		end)

		it("should be a stack", function()
			local test = testMouse()
			local mouse = Mouse.new(test)
			mouse:__pushCursor("PointingHand")
			expect(test.Icon).to.equal("rbxasset://SystemCursors/PointingHand")
			mouse:__pushCursor("IBeam")
			expect(test.Icon).to.equal("rbxasset://SystemCursors/IBeam")
			mouse:__popCursor()
			expect(test.Icon).to.equal("rbxasset://SystemCursors/PointingHand")
			mouse:__popCursor()
			expect(test.Icon).to.equal("rbxasset://SystemCursors/Arrow")
		end)

		it("should respect priority", function()
			local test = testMouse()
			local mouse = Mouse.new(test)
			mouse:__pushCursor("PointingHand")
			expect(test.Icon).to.equal("rbxasset://SystemCursors/PointingHand")
			mouse:__pushCursor("IBeam", 2)
			expect(test.Icon).to.equal("rbxasset://SystemCursors/IBeam")
			mouse:__pushCursor("SizeEW")
			expect(test.Icon).to.equal("rbxasset://SystemCursors/IBeam")
			mouse:__popCursor(1)
			expect(test.Icon).to.equal("rbxasset://SystemCursors/IBeam")
			mouse:__popCursor(2)
			expect(test.Icon).to.equal("rbxasset://SystemCursors/PointingHand")
			mouse:__popCursor(1)
			expect(test.Icon).to.equal("rbxasset://SystemCursors/Arrow")
		end)

		it("should not throw when calling popCursor on an empty stack", function()
			local test = testMouse()
			local mouse = Mouse.new(test)
			mouse:__popCursor()
			expect(test.Icon).to.equal("rbxasset://SystemCursors/Arrow")
		end)
	end)
end
