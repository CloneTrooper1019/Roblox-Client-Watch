local BoundsChangedTracker = {}
BoundsChangedTracker.__index = BoundsChangedTracker

function BoundsChangedTracker.new(draggerContext, handler)
	return setmetatable({
		_handler = handler,
	}, BoundsChangedTracker)
end

function BoundsChangedTracker:install()
	-- TODO
	return nil
end

function BoundsChangedTracker:uninstall()
	-- TODO
	return nil
end

function BoundsChangedTracker:setSelection(selectionInfo)
	-- TODO
end

return BoundsChangedTracker
