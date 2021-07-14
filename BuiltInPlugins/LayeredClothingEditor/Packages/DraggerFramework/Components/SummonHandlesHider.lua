local DraggerFramework = script.Parent.Parent

local Library = DraggerFramework.Parent.Parent
local Roact = require(Library.Packages.Roact)

local SummonHandlesHider = Roact.PureComponent:extend("SummonHandlesHider")

-- When the user has summoned the handles for at duration, the hint that they
-- can be summoned will permanently become hidden. We do it this way so that if
-- you just slightly tap the tab key you won't lose the hint, you actually have
-- to hold it down.
local sTotalSummonHintTime = 2

-- Was the hint hidden in a previous session?
local SETTING_NAME = "CoreDraggersSummonHintHidden"
local sWasPreviouslyHidden = nil

function SummonHandlesHider:didMount()
	self._startTime = os.clock()
end

function SummonHandlesHider:willUnmount()
	local duration = os.clock() - self._startTime
	sTotalSummonHintTime -= duration
	if sWasPreviouslyHidden == nil then
		sWasPreviouslyHidden = self.props.DraggerContext:getSetting(SETTING_NAME)
	end
	if sTotalSummonHintTime <= 0 and not sWasPreviouslyHidden then
		self.props.DraggerContext:setSetting(SETTING_NAME, true)
		sWasPreviouslyHidden = true
	end
end

function SummonHandlesHider:render()
	return nil
end

function SummonHandlesHider.hasSeenEnough(draggerContext)
	if sWasPreviouslyHidden == nil then
		sWasPreviouslyHidden = draggerContext:getSetting(SETTING_NAME)
	end
	return sWasPreviouslyHidden or sTotalSummonHintTime <= 0
end

return SummonHandlesHider