local Packages = script:FindFirstAncestor("Packages")
local SocialLibraries = script:FindFirstAncestor("social-libraries")
require(SocialLibraries).config({ UIBloxConfig = {} })

return function()
	beforeAll(function(context)
		context.UnitTestHelpers = require(script.Parent.temp.UnitTestHelpers.api)
		context.Mock = require(Packages.Dev.Mock)
	end)
end
