return function()
	local findFileNameFromPath = require(script.Parent.findFileNameFromPath)

	it("should strip out everything before the file that threw the error, and the error itself", function()
		local errString = "CoreGui.RobloxGui.Modules.LuaApp.Components.Home.HomePageWithAvatarViewportFrame, line 98 - field testError"
		local fileName = findFileNameFromPath(errString)
		expect(fileName).to.equal("HomePageWithAvatarViewportFrame, line 98 - field testError")
	end)
end