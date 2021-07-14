local log = require(script.Parent.appLogger)
-- The app has some way to import the page, but not vice versa.
local page = require(script.Parent.Parent.page.page)
local printer = require(script.Parent.PrintSink)

log:addSink(printer.new(log.Levels.Error))

return function()
    log:info("calling {root}")
    page.init(log)

    return page.doSomething()
end