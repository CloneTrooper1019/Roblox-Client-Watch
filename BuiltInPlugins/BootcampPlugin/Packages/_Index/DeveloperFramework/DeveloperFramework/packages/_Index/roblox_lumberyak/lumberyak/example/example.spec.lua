return function()
    local app = require(script.Parent.app.app)
    local log = require(script.Parent.app.appLogger)

	local function newSink(level)
		return {
			maxLevel = level,
			seen = {},
			log = function(self, message, context)
				table.insert(self.seen, {message=message, context=context})
			end,
		}
    end

    it("should generate expected messages", function()
        local sink = newSink(log.Levels.Info)
        log:addSink(sink)

        local result = app()
        expect(result).to.equal("done")
        expect(#sink.seen).to.equal(3)
        expect(sink.seen[1].message).to.equal("calling root")
        expect(sink.seen[2].message).to.equal("calling root foo")
        expect(sink.seen[3].message).to.equal("calling root foo bar")
    end)
end