return function()
	local Plugin = script.Parent.Parent.Parent
	local Rodux = require(Plugin.Packages.Rodux)

	local MainReducer = require(script.Parent.MainReducer)
	local History = require(script.Parent.History)
	local SetPointData = require(Plugin.Src.Actions.SetPointData)

	local SetFuture = require(Plugin.Src.Actions.SetFuture)
	local SetPast = require(Plugin.Src.Actions.SetPast)
	local AddWaypoint = require(Plugin.Src.Thunks.AddWaypoint)
	local Undo = require(Plugin.Src.Thunks.Undo)
	local Redo = require(Plugin.Src.Thunks.Redo)

	local testWaypoint = {
		{
			pointData = {
				TheFuture = "IsBright",
			},
		},
	}

	local function createTestHistory()
		local middlewares = {Rodux.thunkMiddleware}
		local store = Rodux.Store.new(History, nil, middlewares)
		return store
	end

	local function createTestStore()
		local middlewares = {Rodux.thunkMiddleware}
		local store = Rodux.Store.new(MainReducer, nil, middlewares)
		return store
	end

	describe("SetPast", function()
		it("should set the Past", function()
			local store = createTestHistory()
			store:dispatch(SetPast({
				SomeKey = "SomeValue"
			}))

			local history = store:getState()
			expect(history).to.be.ok()
			expect(history.past).to.be.ok()
			expect(history.past.SomeKey).to.equal("SomeValue")
		end)
	end)

	describe("SetFuture", function()
		it("should set the Future", function()
			local store = createTestHistory()
			store:dispatch(SetFuture({
				SomeKey = "SomeValue"
			}))

			local history = store:getState()
			expect(history).to.be.ok()
			expect(history.future).to.be.ok()
			expect(history.future.SomeKey).to.equal("SomeValue")
		end)
	end)

	describe("AddWaypoint", function()
		it("should add a waypoint to Past", function()
			local store = createTestStore()
			store:dispatch(SetPointData({}))
			store:dispatch(AddWaypoint())

			local history = store:getState().history
			expect(history).to.be.ok()
			expect(history.past).to.be.ok()
			expect(#history.past).to.equal(1)
		end)

		it("should remove all waypoints from Future", function()
			local store = createTestStore()
			store:dispatch(SetPointData({
				Instances = {},
			}))
			store:dispatch(SetFuture({
				Selection = {},
			}))
			store:dispatch(AddWaypoint())

			local history = store:getState().history
			expect(#history.future).to.equal(0)
		end)
	end)

	describe("Undo", function()
		it("should replace the current PointData with the Past", function()
			local store = createTestStore()
			store:dispatch(SetPointData({
				ThePresent = "IsCool",
			}))
			store:dispatch(AddWaypoint())
			store:dispatch(SetPointData({
				TheFuture = "IsBright",
			}))
			store:dispatch(Undo())
			local state = store:getState()
			expect(state.cageData.pointData).to.be.ok()
			expect(state.cageData.pointData.TheFuture).never.to.be.ok()
			expect(state.cageData.pointData.ThePresent).to.equal("IsCool")
		end)

		it("should add the current PointData to the Future", function()
			local store = createTestStore()
			store:dispatch(SetPointData({
				ThePresent = "IsCool",
			}))
			store:dispatch(AddWaypoint())
			store:dispatch(SetPointData({
				TheFuture = "IsBright",
			}))
			store:dispatch(Undo())
			local state = store:getState()
			expect(state.history.future).to.be.ok()
			expect(#state.history.future).to.equal(1)
			expect(state.history.future[1]).to.be.ok()
			expect(state.history.future[1].pointData.TheFuture).to.equal("IsBright")
		end)

		it("should pop the top of the Past stack", function()
			local store = createTestStore()
			store:dispatch(SetPointData({
				Instances = {},
			}))
			store:dispatch(SetPast(testWaypoint))
			store:dispatch(Undo())
			local state = store:getState()
			expect(#state.history.past).to.equal(0)
		end)

		it("should do nothing if there is no Past", function()
			local store = createTestStore()
			store:dispatch(SetPointData({
				ThePresent = "IsCool",
			}))
			store:dispatch(Undo())
			local state = store:getState()
			expect(state.cageData.pointData).to.be.ok()
			expect(state.cageData.pointData.ThePresent).to.equal("IsCool")
		end)
	end)

	describe("Redo", function()
		it("should replace the current PointData with the Future", function()
			local store = createTestStore()
			store:dispatch(SetPointData({
				ThePresent = "IsCool",
			}))
			store:dispatch(SetFuture(testWaypoint))
			store:dispatch(Redo())
			local state = store:getState()
			expect(state.cageData.pointData).to.be.ok()
			expect(state.cageData.pointData.ThePresent).never.to.be.ok()
			expect(state.cageData.pointData.TheFuture).to.equal("IsBright")
		end)

		it("should add the current PointData to the Past", function()
			local store = createTestStore()
			store:dispatch(SetPointData({
				ThePresent = "IsCool",
			}))
			store:dispatch(SetFuture(testWaypoint))
			store:dispatch(Redo())
			local state = store:getState()
			expect(state.history.past).to.be.ok()
			expect(#state.history.past).to.equal(1)
			expect(state.history.past[1]).to.be.ok()
			expect(state.history.past[1].pointData.ThePresent).to.equal("IsCool")
		end)

		it("should pop the top of the Future stack", function()
			local store = createTestStore()
			store:dispatch(SetPointData({
				Instances = {},
			}))
			store:dispatch(SetFuture(testWaypoint))
			store:dispatch(Redo())
			local state = store:getState()
			expect(#state.history.future).to.equal(0)
		end)

		it("should do nothing if there is no Future", function()
			local store = createTestStore()
			store:dispatch(SetPointData({
				ThePresent = "IsCool",
			}))
			store:dispatch(Redo())
			local state = store:getState()
			expect(state.cageData.pointData).to.be.ok()
			expect(state.cageData.pointData.ThePresent).to.equal("IsCool")
		end)
	end)

	it("should be able to Undo and Redo without loss", function()
		local store = createTestStore()
		store:dispatch(SetPointData({
			Order = "First",
		}))
		store:dispatch(AddWaypoint())
		store:dispatch(SetPointData({
			Order = "Second",
		}))
		store:dispatch(Undo())
		store:dispatch(Redo())
		store:dispatch(Undo())
		store:dispatch(Redo())

		local state = store:getState()
		local history = state.history
		expect(#history.past).to.equal(1)
		expect(#history.future).to.equal(0)
		expect(history.past[1].pointData.Order).to.equal("First")
		local data = state.cageData.pointData
		expect(data.Order).to.equal("Second")
	end)

	it("should work on deep tables", function()
		local store = createTestStore()
		store:dispatch(SetPointData({
			OrderTable = {
				Order = "First",
			},
		}))
		store:dispatch(AddWaypoint())
		store:dispatch(SetPointData({
			OrderTable = {
				Order = "Second",
			},
		}))
		store:dispatch(Undo())

		local state = store:getState()
		local data = state.cageData.pointData
		expect(data.OrderTable.Order).to.equal("First")
	end)
end