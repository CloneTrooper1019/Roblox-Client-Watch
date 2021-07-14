return function(options)
	return {
		getStatus = require(script.getStatus)(options),
		setStatus = require(script.setStatus)(options),
		installReducer = require(script.installReducer)(options),

		Enum = {
			Status = require(script.EnumNetworkStatus),
		},
	}
end
