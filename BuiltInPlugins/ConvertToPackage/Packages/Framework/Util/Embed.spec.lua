return function()
	local Embed = require(script.Parent.Embed)
	it("should embed DeveloperFramework in ReplicatedStorage", function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local Root = Instance.new("Folder")
		Root.Parent = ReplicatedStorage
		Embed.install(Root)
		-- TODO RIDE-4035: Enable debug.loadmodule for tests
		-- local embeddedFramework = debug.loadmodule(Root.Packages.Framework)()
		-- local endsWith = embeddedFramework.Dash.endsWith
		-- expect(endsWith("this works", "works")).to.equal(true)
		Root:Destroy()
	end)
end
