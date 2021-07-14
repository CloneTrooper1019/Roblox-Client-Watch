local ContentProvider = game:GetService("ContentProvider")

return function()
	return nil ~= string.find(ContentProvider.BaseUrl, "www.roblox.com")
end