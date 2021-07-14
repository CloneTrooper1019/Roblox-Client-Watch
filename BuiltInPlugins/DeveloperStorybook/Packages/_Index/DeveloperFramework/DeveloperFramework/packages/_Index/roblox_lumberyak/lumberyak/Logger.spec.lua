return function()
	local Logger = require(script.Parent.Logger)

	local function newSink(level)
		return {
			maxLevel = level,
			seen = {},
			log = function(self, message, context)
				table.insert(self.seen, {message=message, context=context})
			end,
		}
	end

	describe("A new Logger", function()
		it("should be creatable without a parent", function()
			expect(function()
				local _ = Logger.new()
			end).to.never.throw()
		end)

		it("should be creatable with a parent", function()
			expect(function()
				local log1 = Logger.new()
				local _ = Logger.new(log1)
			end).to.never.throw()
		end)

		it("should be creatable with a parent, alternate syntax", function()
			expect(function()
				local log1 = Logger.new()
				local _ = log1:new()
			end).to.never.throw()
		end)

		it("should add sinks", function()
			expect(function()
				local log = Logger.new()
				local sink = newSink(Logger.Levels.Info)
				log:addSink(sink)
			end).to.never.throw()
		end)

		it("should add context", function()
			expect(function()
				local log = Logger.new()
				log:setContext({foo = "bar"})
			end).to.never.throw()
		end)
	end)

	describe("Basic logging", function()
		it("to the root logger", function()
			local log = Logger.new()
			local sink = newSink(Logger.Levels.Info)
			log:addSink(sink)

			log:info("foo")

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("foo")
		end)

		it("to a child logger", function()
			local log1 = Logger.new()
			local log2 = log1:new()
			local sink = newSink(Logger.Levels.Info)
			log1:addSink(sink)

			log2:info("foo")

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("foo")
		end)

		it("to a sibling logger", function()
			local log1 = Logger.new()
			local log2 = log1:new()
			local log3 = log1:new()
			local sink = newSink(Logger.Levels.Info)
			log2:addSink(sink)

			log3:info("foo")

			expect(#sink.seen).to.equal(0)
		end)

		it("to a parent logger", function()
			local log1 = Logger.new()
			local log2 = log1:new()
			local sink = newSink(Logger.Levels.Info)
			log2:addSink(sink)

			log1:info("foo")

			expect(#sink.seen).to.equal(0)
		end)

		it("to a child logger, sink added first", function()
			local log1 = Logger.new()
			local sink = newSink(Logger.Levels.Info)
			log1:addSink(sink)
			local log2 = log1:new()

			log2:info("foo")

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("foo")
		end)

		it("to a sibling logger, sink added first", function()
			local log1 = Logger.new()
			local log2 = log1:new()
			local sink = newSink(Logger.Levels.Info)
			log2:addSink(sink)
			local log3 = log1:new()

			log3:info("foo")

			expect(#sink.seen).to.equal(0)
		end)
	end)

	describe("When logging different levels", function()
		local cases = {
			[Logger.Levels.Error] = 1,
			[Logger.Levels.Warning] = 2,
			[Logger.Levels.Info] = 3,
			[Logger.Levels.Debug] = 4,
			[Logger.Levels.Trace] = 5,
		}

		for level, count in pairs(cases) do
			it("logging to the root should respect " .. level, function()
				local log = Logger.new()
				local sink = newSink(level)
				log:addSink(sink)

				log:error("error")
				log:warning("warning")
				log:info("info")
				log:debug("debug")
				log:trace("trace")

				expect(#sink.seen).to.equal(count)
			end)

			it("logging to the child should respect " .. level, function()
				local log1 = Logger.new()
				local log2 = log1:new()
				local sink = newSink(level)
				log1:addSink(sink)

				log2:error("error")
				log2:warning("warning")
				log2:info("info")
				log2:debug("debug")
				log2:trace("trace")

				expect(#sink.seen).to.equal(count)
			end)
		end

		describe("should treat invalid log levels as disabled", function()
			it("should log to no levels when given a bad maxLevel", function()
				local log = Logger.new()
				local sink = newSink("not-a-level")
				log:addSink(sink)

				log:error("error")
				log:warning("warning")
				log:info("info")
				log:debug("debug")
				log:trace("trace")

				expect(#sink.seen).to.equal(0)
			end)

			it("should log to no levels when given nil", function()
				local log = Logger.new()
				local sink = newSink(nil)
				log:addSink(sink)

				log:error("error")
				log:warning("warning")
				log:info("info")
				log:debug("debug")
				log:trace("trace")

				expect(#sink.seen).to.equal(0)
			end)

			it("should handle multiple sinks when some are disabled", function()
				local log = Logger.new()
				local sink1 = newSink(nil)
				local sink2 = newSink(Logger.Levels.Trace)
				log:addSink(sink1)
				log:addSink(sink2)

				log:error("error")
				log:warning("warning")
				log:info("info")
				log:debug("debug")
				log:trace("trace")

				expect(#sink1.seen).to.equal(0)
				expect(#sink2.seen).to.equal(5)
			end)
		end)
	end)

	describe("When logging different levels using fromString", function()
		local cases = {
			["error"] = 1,
			["Warning"] = 2,
			["INFO"] = 3,
			["dEBUG"] = 4,
			["TrAcE"] = 5,
			["invalid"] = 0,
		}

		for level, count in pairs(cases) do
			it("fromString should handle " .. level, function()
				local log = Logger.new()
				local sink = newSink(Logger.Levels.fromString(level))
				log:addSink(sink)

				log:error("error")
				log:warning("warning")
				log:info("info")
				log:debug("debug")
				log:trace("trace")

				expect(#sink.seen).to.equal(count)
			end)
		end
	end)

	describe("sinks", function()
		it("should be disabled without error when maxLevel isn't set", function()
			local log = Logger.new()
			local seen = 0
			log:addSink({
				log = function()
					seen = seen + 1
				end,
			})

			log:error("error")
			log:warning("warning")
			log:info("info")
			log:debug("debug")
			log:trace("trace")

			expect(seen).to.equal(0)
		end)

		it("should be disabled without error when maxLevel is set incorrectly", function()
			local log = Logger.new()
			local seen = 0
			log:addSink({
				maxLevel = "foo",
				log = function()
					seen = seen + 1
				end,
			})

			log:error("error")
			log:warning("warning")
			log:info("info")
			log:debug("debug")
			log:trace("trace")

			expect(seen).to.equal(0)
		end)

		it("should not cause problems with parenting when not set", function()
			local log1 = Logger.new()
			local seen = 0
			log1:addSink({
				log = function()
					seen = seen + 1
				end,
			})

			local log2 = log1:new()

			log2:error("error")
			log2:warning("warning")
			log2:info("info")
			log2:debug("debug")
			log2:trace("trace")

			expect(seen).to.equal(0)
		end)
	end)

	describe("should treat invalid log levels as disabled", function()
		it("should log to no levels when given a bad maxLevel", function()
			local log = Logger.new()
			local sink = newSink("not-a-level")
			log:addSink(sink)

			log:error("error")
			log:warning("warning")
			log:info("info")
			log:debug("debug")
			log:trace("trace")

			expect(#sink.seen).to.equal(0)
		end)

		it("should log to no levels when given nil", function()
			local log = Logger.new()
			local sink = newSink(nil)
			log:addSink(sink)

			log:error("error")
			log:warning("warning")
			log:info("info")
			log:debug("debug")
			log:trace("trace")

			expect(#sink.seen).to.equal(0)
		end)

		it("should handle multiple sinks when some are disabled", function()
			local log = Logger.new()
			local sink1 = newSink(nil)
			local sink2 = newSink(Logger.Levels.Trace)
			log:addSink(sink1)
			log:addSink(sink2)

			log:error("error")
			log:warning("warning")
			log:info("info")
			log:debug("debug")
			log:trace("trace")

			expect(#sink1.seen).to.equal(0)
			expect(#sink2.seen).to.equal(5)
		end)
	end)

	describe("with positional arguments", function()
		it("should work with one arg", function()
			local log = Logger.new()
			local sink = newSink(Logger.Levels.Info)
			log:addSink(sink)

			log:info("foo {}", "bar")

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("foo bar")
		end)

		it("should work with two args", function()
			local log = Logger.new()
			local sink = newSink(Logger.Levels.Info)
			log:addSink(sink)

			log:info("foo {} {}", "bar", "baz")

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("foo bar baz")
		end)

		it("should output a warning with too many arguments", function()
			local log = Logger.new()
			local sink = newSink(Logger.Levels.Info)
			log:addSink(sink)

			log:info("foo {}", "bar", "baz")

			assert(string.find(sink.seen[1].message, "LUMBERYAK INTERNAL"),
				"Expected an internal warning, got [[\n" .. sink.seen[1].message .. "\n]]")
		end)

		it("should output a warning with too few arguments", function()
			local log = Logger.new()
			local sink = newSink(Logger.Levels.Info)
			log:addSink(sink)

			log:info("foo {} {}", "bar")

			assert(string.find(sink.seen[1].message, "LUMBERYAK INTERNAL"),
				"Expected an internal warning, got [[\n" .. sink.seen[1].message .. "\n]]")
		end)

		it("should handle a single nil positional argument", function()
			local log = Logger.new()
			local sink = newSink(Logger.Levels.Info)
			log:addSink(sink)

			log:info("foo {} bar", nil)

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("foo nil bar")
		end)

		it("should handle a nil positional argument in the middle", function()
			local log = Logger.new()
			local sink = newSink(Logger.Levels.Info)
			log:addSink(sink)

			log:info("foo {} {}", nil, "bar")

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("foo nil bar")
		end)

		it("should handle multiple nil arguments", function()
			local log = Logger.new()
			local sink = newSink(Logger.Levels.Info)
			log:addSink(sink)

			log:info("foo {} {}", nil, nil)

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("foo nil nil")
		end)

		it("should ignore a nil named arugment", function()
			local log = Logger.new()
			local sink = newSink(Logger.Levels.Info)
			log:addSink(sink)

			log:info("foo {notFound} bar")

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("foo {notFound} bar")
		end)
	end)

	describe("When passing in context", function()
		describe("with context from root", function()
			it("should pass along static context", function()
				local log = Logger.new()
				local sink = newSink(Logger.Levels.Info)
				log:addSink(sink)
				log:setContext({bar = 1})

				log:info("foo")

				expect(#sink.seen).to.equal(1)
				expect(sink.seen[1].context.bar).to.equal(1)
			end)

			it("should call dynamic context", function()
				local log = Logger.new()
				local sink = newSink(Logger.Levels.Info)
				log:addSink(sink)
				log:setContext({bar = function()
					return 1
				end})

				log:info("foo")

				expect(#sink.seen).to.equal(1)
				expect(sink.seen[1].context.bar).to.equal(1)
			end)
		end)

		describe("when combining context", function()
			it("should merge non-overlapping context", function()
				local log1 = Logger.new()
				local log2 = log1:new()
				local log3 = log2:new()
				local sink = newSink(Logger.Levels.Info)
				log1:addSink(sink)
				log1:setContext({bar = 1})
				log2:setContext({baz = 2})
				log3:setContext({quz = 3})

				log3:info("foo")

				expect(#sink.seen).to.equal(1)
				expect(sink.seen[1].context.bar).to.equal(1)
				expect(sink.seen[1].context.baz).to.equal(2)
				expect(sink.seen[1].context.quz).to.equal(3)
			end)

			it("should overwrite overlapping context", function()
				local log1 = Logger.new()
				local log2 = log1:new()
				local log3 = log2:new()
				local sink = newSink(Logger.Levels.Info)
				log1:addSink(sink)
				log1:setContext({bar = 1, baz = 1, quz = 1})
				log2:setContext({bar = 2, baz = 2})
				log3:setContext({baz = 3})

				log3:info("foo")

				expect(#sink.seen).to.equal(1)
				expect(sink.seen[1].context.quz).to.equal(1)
				expect(sink.seen[1].context.bar).to.equal(2)
				expect(sink.seen[1].context.baz).to.equal(3)
			end)

			it("should call dynamic context", function()
				local log1 = Logger.new()
				local log2 = log1:new()
				local sink = newSink(Logger.Levels.Info)
				log1:addSink(sink)
				log1:setContext({bar = 1})
				log2:setContext({bar = function()
					return 2
				end})

				log2:info("foo")

				expect(#sink.seen).to.equal(1)
				expect(sink.seen[1].context.bar).to.equal(2)
			end)
		end)
	end)

	describe("Message interpolation", function()
		it("should leave plain messages alone", function()
			local log = Logger.new()
			local sink = newSink(Logger.Levels.Info)
			log:addSink(sink)
			log:setContext({bar = "baz"})

			log:info("foo")

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("foo")
		end)

		it("should substitute info from static context", function()
			local log = Logger.new()
			local sink = newSink(Logger.Levels.Info)
			log:addSink(sink)
			log:setContext({bar = "baz"})

			log:info("foo {bar}")

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("foo baz")
		end)

		it("should substitute info from dynamic context", function()
			local log = Logger.new()
			local sink = newSink(Logger.Levels.Info)
			log:addSink(sink)
			log:setContext({bar = function()
				return "baz"
			end})

			log:info("foo {bar}")

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("foo baz")
		end)
	end)

	describe("Message prefix", function()
		it("should prepend the prefix", function()
			local log = Logger.new()
			local sink = newSink(Logger.Levels.Info)
			log:addSink(sink)
			log:setContext({prefix = "foo: "})

			log:info("bar")

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("foo: bar")
		end)

		it("should interpolate the prefix", function()
			local log = Logger.new()
			local sink = newSink(Logger.Levels.Info)
			log:addSink(sink)
			log:setContext({prefix = "{foo}: ", foo = "baz"})

			log:info("bar")

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("baz: bar")
		end)

		it("should stack prefixes", function()
			local log1 = Logger.new()
			local log2 = log1:new()
			local sink = newSink(Logger.Levels.Info)
			log1:addSink(sink)
			log1:setContext({prefix = "foo: "})
			log2:setContext({prefix = "bar: "})

			log2:info("baz")

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("foo: bar: baz")
		end)
	end)

	it("Should get the name of logger used", function()
		local log1 = Logger.new(nil, "log1")
		local log2 = log1:new("log2")
		local sink = newSink(Logger.Levels.Info)
		log1:addSink(sink)

		log1:info("{loggerName}")
		log2:info("{loggerName}")

		expect(#sink.seen).to.equal(2)
		expect(sink.seen[1].message).to.equal("log1")
		expect(sink.seen[2].message).to.equal("log2")
	end)

	describe("setParent should work", function()
		it("when calling A->B then B->C", function()
			local a = Logger.new()
			local b = Logger.new()
			local c = Logger.new()

			local sink = newSink(Logger.Levels.Info)
			a:addSink(sink)

			a:setContext({a = "A"})
			b:setContext({b = "B"})
			c:setContext({c = "C"})

			b:setParent(a)
			c:setParent(b)

			c:info("{a} {b} {c}")

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("A B C")
		end)

		it("when calling B->C then A->B", function()
			local a = Logger.new()
			local b = Logger.new()
			local c = Logger.new()

			local sink = newSink(Logger.Levels.Info)
			a:addSink(sink)

			a:setContext({a = "A"})
			b:setContext({b = "B"})
			c:setContext({c = "C"})

			c:setParent(b)
			b:setParent(a)

			c:info("{a} {b} {c}")

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("A B C")
		end)

		it("when moving D from B to C", function()
			local a = Logger.new()
			local b = Logger.new()
			local c = Logger.new()
			local d = Logger.new()

			local sink = newSink(Logger.Levels.Info)
			a:addSink(sink)

			a:setContext({x = "A"})
			b:setContext({y = "B"})
			c:setContext({y = "C"})
			d:setContext({z = "D"})

			c:setParent(a)
			b:setParent(a)

			d:setParent(b)
			d:info("{x} {y} {z}")

			d:setParent(c)
			d:info("{x} {y} {z}")

			expect(#sink.seen).to.equal(2)
			expect(sink.seen[1].message).to.equal("A B D")
			expect(sink.seen[2].message).to.equal("A C D")
		end)

		it("when mixing setParent and static parents", function()
			local a = Logger.new()
			local b = Logger.new()
			local c = b:new()

			local sink = newSink(Logger.Levels.Info)
			a:addSink(sink)

			a:setContext({a = "A"})
			b:setContext({b = "B"})
			c:setContext({c = "C"})

			b:setParent(a)

			c:info("{a} {b} {c}")

			expect(#sink.seen).to.equal(1)
			expect(sink.seen[1].message).to.equal("A B C")
		end)
	end)
end
