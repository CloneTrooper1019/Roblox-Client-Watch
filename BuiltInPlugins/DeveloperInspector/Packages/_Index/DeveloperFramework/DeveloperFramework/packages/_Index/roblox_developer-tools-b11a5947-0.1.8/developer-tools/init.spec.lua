return function()
	local Packages = script.Parent.Parent

	local jest = require(Packages.Dev.JestRoblox).Globals
	local expect = jest.expect
	
	local RoactExamples = require(Packages.Test.RoactExamples)

	local DeveloperTools = require(script.Parent)

	local Dash = require(Packages.Dash)
	local keys = Dash.keys
	
	describe("DeveloperTools", function()
		describe("Roact inspecting", function()
			it("can be initialized for a plugin", function()
				local host = Instance.new("Frame")
				local tree = RoactExamples.getTree(host)
				local inspector = DeveloperTools.forPlugin("TestPlugin", {}, host)
				inspector:addRoactTree("Roact tree", tree)
				expect(#keys(inspector.targets)).toEqual(1)
			end)
			it("can be initialized for a library", function()
				local host = Instance.new("Frame")
				local tree = RoactExamples.getTree(host)
				local inspector = DeveloperTools.forLibrary("TestLibrary", {})
				inspector:addRoactTree("Roact tree", tree)
				expect(#keys(inspector.targets)).toEqual(1)
			end)
		end)
	end)

end