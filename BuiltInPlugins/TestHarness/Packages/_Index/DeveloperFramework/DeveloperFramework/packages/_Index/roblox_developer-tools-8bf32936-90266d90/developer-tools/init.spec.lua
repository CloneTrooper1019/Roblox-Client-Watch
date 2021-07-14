return function()
	local DeveloperTools = require(script.Parent)

	local Dash = require(script.Parent.Parent.Dash)
	local keys = Dash.keys
		
	describe("DeveloperTools", function()
		describe("Roact inspecting", function()
			it("can be initialized for a plugin", function()
				local inspector = DeveloperTools.forPlugin("TestPlugin", {})
				inspector:addRoactTree("Roact tree", {})
				expect(#keys(inspector.targets)).to.equal(1)
			end)
			it("can be initialized for a library", function()
				local inspector = DeveloperTools.forLibrary("TestLibrary", {})
				inspector:addRoactTree("Roact tree", {})
				expect(#keys(inspector.targets)).to.equal(1)
			end)
		end)
	end)

end