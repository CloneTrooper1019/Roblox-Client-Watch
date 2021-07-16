local DevFrameworkRoot = script.Parent.Parent

local Rodux = require(DevFrameworkRoot.Parent.Rodux)
local Cryo = require(DevFrameworkRoot.Util.Cryo)

local Action = require(DevFrameworkRoot.Util.Action)

local testImmutability = require(script.Parent.testImmutability)

return function()
	it("should error on invalid input", function()
		-- expected fields
		-- reducer : (Rodux reducer)
		-- action : (Action)

		local function createTestReducer()
			local defaultState = {
				foo = "bar",
			}
			local testReducer = Rodux.createReducer(defaultState, {
				emptyAction = function(state, _)
					return Cryo.Dictionary.join(state, {})
				end,
			})

			return testReducer
		end
		local emptyAction = Action("emptyAction", function()
			return {}
		end)

		-- if everything is fine, return true
		expect(testImmutability(createTestReducer(), emptyAction)).to.equal(true)

		-- invalid reducer
		expect(function()
			testImmutability("", emptyAction)
		end).to.throw()

		-- invalid action
		expect(function()
			testImmutability(createTestReducer(), "hello")
		end).to.throw()
	end)

	it("should return true if the originalState is unchanged by the supplied action", function()
		-- create a proper reducer
		local r = Rodux.createReducer({ value = "foo" }, {
			setValue = function(state, action)
				local newValue = action.value
				return Cryo.Dictionary.join(state, {
					value = newValue
				})
			end
		})
		local setValueAction = Action("setValue", function(v)
			return { value = v }
		end)
		local emptyAction = Action("emptyAction", function()
			return {}
		end)

		-- get the default state
		local defaultState = r(nil, emptyAction)
		expect(defaultState.value).to.equal("foo")

		-- show that this action can modify this state
		local newState = r(nil, setValueAction("bar"))
		expect(newState.value).to.equal("bar")

		-- even if the state can be modified by the action,
		-- the original state table should not reflect those changes.
		expect(testImmutability(r, setValueAction("test"))).to.equal(true)
	end)

	it("should throw an error if the originalState has been modified in any way", function()
		local r = Rodux.createReducer({ value = "foo" }, {
			setValue = function(state, action)
				-- erroneously modify the old state
				local newValue = action.value
				state.value = newValue
				return state
			end
		})
		local setValueAction = Action("setValue", function(v)
			return { value = v }
		end)

		expect(function()
			testImmutability(r, setValueAction("test"))
		end).to.throw()
	end)

	it("should catch changes in nested tables", function()
		local r = Rodux.createReducer({
			value = {
				children = { "foo", "bar", "cat" },
			},
		}, {
			setChildren = function(state, action)
				-- reuse the table from the old state
				local newValue = {}
				newValue.value = {}
				newValue.value.children = state.value.children

				-- erroneously mutate the old data
				newValue.value.children[1] = "fooo"
				return newValue
			end
		})
		local setChildrenAction = Action("setChildren", function()
			return {}
		end)

		expect(function()
			testImmutability(r, setChildrenAction("test"))
		end).to.throw()
	end)

	it("should return true when the result is two empty tables", function()
		local emptyAction = Action("emptyAction", function() return {} end)
		local testReducer = Rodux.createReducer({
			tA = {},
			tB = {},
		}, {
			emptyAction = function(state, action)
				return Cryo.Dictionary.join(state, {})
			end,
		})

		expect(testImmutability(testReducer, emptyAction)).to.equal(true)
	end)

	it("should allow you pass a table in as a previous state", function()
		-- create a state that holds non-default information
		local previousState = {
			tA = {
				name = "test"
			}
		}

		-- create a reducer whose default state lacks enough information
		-- to work on more advanced actions. Let's assume another action sets
		-- the field 'tA', and changeNameAction works with its contents.
		local testReducer = Rodux.createReducer({}, {
			changeNameAction = function(state, action)
				local target = action.target
				local newName = action.name

				return Cryo.Dictionary.join(state, {
					[target] = Cryo.Dictionary.join(state[target], {
						name = newName
					}),
				})
			end,
		})

		-- create an action that extends work done by other actions
		local changeNameAction = Action("changeNameAction", function(target, name)
			return {
				target = target,
				name = name
			}
		end)

		expect(testImmutability(testReducer, changeNameAction,
			previousState)).to.equal(true)
	end)
end
