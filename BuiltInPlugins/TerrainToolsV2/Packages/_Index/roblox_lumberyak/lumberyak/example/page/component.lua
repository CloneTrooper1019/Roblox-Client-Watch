local log = require(script.Parent.pageLogger):new()
log:setContext({bar = "bar"})

return function()
    log:info("calling {root} {foo} {bar}")
    return "done"
end