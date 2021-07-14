local RunService = game:GetService("RunService")
return function(func)
	local heartbeat
	heartbeat = RunService.Heartbeat:Connect(function()
		heartbeat:Disconnect()
		func()
	end)
end