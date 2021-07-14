local MockPlugin = require(script.Parent.MockPlugin)

return function()
	it("should deactivate the parent plugin when deactivating", function()
		local plugin = MockPlugin.new()
		local toolbar = plugin:CreateToolbar("")
		local button = toolbar:CreateButton("foo")

		plugin:Activate()
		-- Only catch when going from active -> not active
		button:SetActive(false)
		expect(plugin:IsActivated()).to.equal(true)

		button:SetActive(true)
		expect(plugin:IsActivated()).to.equal(true)

		button:SetActive(false)
		expect(plugin:IsActivated()).to.equal(false)

		plugin:Destroy()
	end)
end
