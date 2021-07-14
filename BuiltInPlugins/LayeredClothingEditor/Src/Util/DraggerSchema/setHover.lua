local Plugin = script.Parent.Parent.Parent.Parent
local Cryo = require(Plugin.Packages.Cryo)

return function(draggerContext, hoverSelectable)
	hoverSelectable = hoverSelectable == nil and Cryo.None or hoverSelectable
	if draggerContext.setHovered then
		draggerContext.setHovered(hoverSelectable)
	end
end