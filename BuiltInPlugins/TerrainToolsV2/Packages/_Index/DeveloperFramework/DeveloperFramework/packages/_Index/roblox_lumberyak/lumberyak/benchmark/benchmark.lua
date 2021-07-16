local Logger = require(game.LoadedCode.Packages.Lumberyak.Logger)

local runs = 2000000

local function timeit(makeLogger, callLogger)
    local log = makeLogger()

    local t = tick()
    for _ = 1, runs do
        callLogger(log)
    end
    return (tick() - t) / runs
end

local function callSimple(log)
    log:info("foo")
end

local function callInterp(log)
    log:info("foo {}", 2)
end

local function simple()
    local count = 0
    local countSink = {
        maxLevel = Logger.Levels.Info,
        log = function(_, _, context)
            count = count + context.number
        end,
    }

    local log = Logger.new()
    log:setContext({number = 1})
    log:addSink(countSink)
    return log
end

local function empty()
    return {
        info = function() end
    }
end

local function off()
    local count = 0
    local countSink = {
        maxLevel = Logger.Levels.Error,
        log = function(_, _, context)
            count = count + context.number
        end,
    }

    local log = Logger.new()
    log:setContext({number = 1})
    log:addSink(countSink)
    return log
end

local function short()
    local count = 0
    local countSink = {
        maxLevel = Logger.Levels.Info,
        log = function(_, _, context)
            count = count + context.number
        end,
    }

    local log = Logger.new()
    local child = log:new()
    log:setContext({number = 1})
    log:addSink(countSink)
    return child
end

local function long()
    local count = 0
    local countSink = {
        maxLevel = Logger.Levels.Info,
        log = function(_, _, context)
            count = count + context.number
        end,
    }

    local log = Logger.new()
    log:setContext({number = 1})
    log:addSink(countSink)
    local a = log:new()
    local b = a:new()
    local c = b:new()
    local d = c:new()
    return d
end

local function many()
    local count = 0
    local sink1 = {
        maxLevel = Logger.Levels.Error,
        log = function(_, _, context)
            count = count + context.number
        end,
    }
    local sink2 = {
        maxLevel = Logger.Levels.Warning,
        log = function(_, _, context)
            count = count + context.number
        end,
    }
    local sink3 = {
        maxLevel = Logger.Levels.Info,
        log = function(_, _, context)
            count = count + context.number
        end,
    }
    local sink4 = {
        maxLevel = Logger.Levels.Debug,
        log = function(_, _, context)
            count = count + context.number
        end,
    }
    local sink5 = {
        maxLevel = Logger.Levels.Trace,
        log = function(_, _, context)
            count = count + context.number
        end,
    }

    local log = Logger.new()
    log:setContext({number = 1})
    log:addSink(sink1)
    log:addSink(sink2)
    log:addSink(sink3)
    log:addSink(sink4)
    log:addSink(sink5)
    return log
end

local base = timeit(empty, callSimple)
local interp = timeit(empty, callInterp)

local tests = {
    ["Log level off"] = off,
    ["Simple logger"] = simple,
    ["Short chain"] = short,
    ["Long chain"] = long,
    ["Many sinks"] = many,
}

local function fmt(name, case, t)
    print(string.format("%-40s %0.3e [%0.4fx]", name .. " - " .. case, t, t / base))
end

fmt("Empty function", "Simple", base)
fmt("Empty function", "Interpolation", interp)
for k, v in pairs(tests) do
    local t1 = timeit(v, callSimple)
    fmt(k, "Simple", t1)
    local t2 = timeit(v, callInterp)
    fmt(k, "Interpolation", t2)
end
