--[[
	getDeepFolder is a utility that walks a data-model tree using a given path.
	If any child along the way doesn't exist, it creates a new Folder instance
	with the correct name.

	The parameter path is a string array.
]]
local Framework = script.Parent.Parent
local Packages = Framework.packages
local Dash = require(Packages.Dash)

local reduce = Dash.reduce

local function getDeepFolder(path, root: Instance?): Instance?
	root = root or game
	return reduce(path, function(current: Instance, key: string)
		local child = current:FindFirstChild(key)
		if not child then
			child = Instance.new("Folder")
			child.Name = key
			child.Parent = current
		end
		return child
	end, root)
end


return getDeepFolder
