local CorePackages = game:GetService("CorePackages")

local Rodux = require(CorePackages.Packages.Rodux)

local chatReducer = require(script.Parent.Parent.Reducers.chatReducer)

return Rodux.Store.new(chatReducer)
