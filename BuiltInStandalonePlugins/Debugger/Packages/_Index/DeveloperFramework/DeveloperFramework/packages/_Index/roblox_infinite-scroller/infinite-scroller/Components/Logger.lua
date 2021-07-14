local Root = script:FindFirstAncestor("infinite-scroller").Parent
local Lumberyak = require(Root.Lumberyak)

return Lumberyak.Logger.new(nil, script:GetFullName())
