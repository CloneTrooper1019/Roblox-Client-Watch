return function()
	local Framework = script.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local provide = require(Framework.ContextServices.provide)
	local Util = require(Framework.Util)
	local FlagsList = Util.Flags.new({
		FFlagRefactorDevFrameworkContextItems = {"RefactorDevFrameworkContextItems"},
	})

	local Focus = require(script.Parent.Focus)

	it("should expect a LayerCollector", function()
		expect(function()
			Focus.new(Instance.new("Folder"))
		end).to.throw()
		Focus.new(Instance.new("ScreenGui"))
	end)

	it("should be providable as a ContextItem", function()
		local focus = Focus.new(Instance.new("ScreenGui"))
		local element = provide({focus}, {
			Frame = Roact.createElement("Frame"),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should return the target via getTarget", function()
		local screenGui = Instance.new("ScreenGui")
		local focus = Focus.new(screenGui)
		local target = FlagsList:get("FFlagRefactorDevFrameworkContextItems") and focus:get() or focus:getTarget()
		expect(target).to.equal(screenGui)
	end)
end
