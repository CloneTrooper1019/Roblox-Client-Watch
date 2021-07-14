return function()
	local Store = require(script.Parent.Store)
	local loggerMiddleware = require(script.Parent.loggerMiddleware)

	it("should print whenever an action is dispatched", function()
		local outputCount = 0
		local outputMessage

		local function reducer(state, action)
			return state
		end

		local store = Store.new(reducer, {
			fooValue = 12345,
			barValue = {
				bazValue = "hiBaz",
			},
		}, { loggerMiddleware.middleware })

		loggerMiddleware.outputFunction = function(message)
			outputCount = outputCount + 1
			outputMessage = message
		end

		store:dispatch({
			type = "testActionType",
		})

		expect(outputCount).to.equal(1)
		expect(outputMessage:find("testActionType")).to.be.ok()
		expect(outputMessage:find("fooValue")).to.be.ok()
		expect(outputMessage:find("12345")).to.be.ok()
		expect(outputMessage:find("barValue")).to.be.ok()
		expect(outputMessage:find("bazValue")).to.be.ok()
		expect(outputMessage:find("hiBaz")).to.be.ok()

		loggerMiddleware.outputFunction = print
	end)
end
