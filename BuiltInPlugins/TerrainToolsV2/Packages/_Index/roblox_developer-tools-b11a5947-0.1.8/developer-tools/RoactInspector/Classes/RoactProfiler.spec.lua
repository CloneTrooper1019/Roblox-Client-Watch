return function()
	local Packages = script:FindFirstAncestor("Packages")
	local jest = require(Packages.Dev.JestRoblox).Globals
	local expect = jest.expect

	local DeveloperTools = require(Packages.DeveloperTools)
	local RoactInspectorWorker = require(Packages.DeveloperTools.RoactInspector.Classes.RoactInspectorWorker)
	local RoactExamples = require(Packages.Test.RoactExamples)
	local Roact = require(Packages.Dev.Roact)

	local function getProfiler(roactTree)
		local inspector = DeveloperTools.forLibrary("TestLibrary", {})
		local worker = RoactInspectorWorker.new(inspector, "", "", roactTree, Roact)
		return worker.profiler
	end

	local host = Instance.new("Frame")
	local profiler
	local roactTree

	beforeEach(function()
		roactTree = RoactExamples.getTree(host)
		profiler = getProfiler(roactTree)
		profiler:setActive(true)
	end)

	afterEach(function()
		profiler:setActive(false)
		profiler:clearData()
	end)

	describe("RoactProfiler", function()
		it('can activate', function()
			expect(profiler.active).toEqual(true)
			expect(profiler:getData()).toEqual({
				componentRows = {},
				eventCount = 0,
				eventRows = {},
				instanceEventCount = 0,
				rowCount = 0,
			})
		end)
		
		it('can collect an update, preserving records when deactivated', function()
			Roact.update(roactTree, Roact.createElement(RoactExamples.Component, {
				Text = "Hello World"
			}))
			profiler:setActive(false)
			local data = profiler:getData(1, 100, 1, 100)
			expect(data.componentRows).toEqual({
				expect.objectContaining({
					count = 1,
					depth = 1,
					instanceId = "1",
					instanceName = "MyComponent",
					path = {"Frame", "RoactTree"},
					pathString = "Path: Frame.RoactTree",
				})
			})
		end)

		it('can collect an update and drill down on events', function()
			Roact.update(roactTree, Roact.createElement(RoactExamples.Component, {
				Text = "Hello World"
			}))
			profiler:getData(1, 100, 1, 100)
			profiler:selectInstance("1")
			local data = profiler:getData(1, 100, 1, 100)
			expect(data.eventRows).toEqual({
				expect.objectContaining({
					cause = "Props",
					details = "Text",
					detailsTip = [[Text: Hello -> Hello World
]],
				})
			})
		end)

		it('can set the search term and include / exclude a component', function()
			Roact.update(roactTree, Roact.createElement(RoactExamples.Component, {
				Text = "Hello World"
			}))
			profiler:setSearchTerm("Nope")
			local data = profiler:getData(1, 100, 1, 100)
			expect(data.componentRows).toEqual({})
			-- Permit lowercase
			profiler:setSearchTerm("comp")
			data = profiler:getData(1, 100, 1, 100)
			expect(data.componentRows).toEqual({
				expect.objectContaining({
					count = 1,
					depth = 1,
					instanceId = "1",
					instanceName = "MyComponent",
					path = {"Frame", "RoactTree"},
					pathString = "Path: Frame.RoactTree",
				})
			})
		end)

	end)
end
