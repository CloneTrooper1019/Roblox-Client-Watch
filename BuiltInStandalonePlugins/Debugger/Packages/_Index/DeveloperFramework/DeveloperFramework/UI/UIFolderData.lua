local Framework = script.Parent.Parent
local createFolderDataLookup = require(Framework.Util.createFolderDataLookup)

return createFolderDataLookup(Framework.UI:GetChildren())