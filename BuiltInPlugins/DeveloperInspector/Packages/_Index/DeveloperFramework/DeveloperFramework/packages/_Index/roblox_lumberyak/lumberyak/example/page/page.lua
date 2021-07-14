-- foo does not need to require root
local log = require(script.Parent.pageLogger)
local component = require(script.Parent.component)

return {
    init = function(logParent)
        log:setParent(logParent)
    end,
    doSomething = function()
        log:info("calling {root} {foo}")
        return component()
    end
}
