local Rodux = require(script.Parent.Rodux)
local Cryo = require(script.Parent.Parent.Cryo)
local buildActionName = require(script.Parent.buildActionName)

return function(options)
	return function()
		return Rodux.createReducer({}, {
			[buildActionName(options)] = function(state, action)
				local updatedStatus = {}
				if #action.ids == 0 then
					updatedStatus[action.keymapper()] = action.status
				else
					for _, id in ipairs(action.ids) do
						local mappedId = action.keymapper(id)
						updatedStatus[mappedId] = action.status
					end
				end

				return Cryo.Dictionary.join(state, updatedStatus)
			end,
		})
	end
end
