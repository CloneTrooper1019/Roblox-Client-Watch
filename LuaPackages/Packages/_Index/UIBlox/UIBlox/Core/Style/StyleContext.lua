local Style = script.Parent
local Core = Style.Parent
local UIBlox = Core.Parent

local Packages = UIBlox.Parent
local Roact = require(Packages.Roact)

return Roact.createContext(nil)