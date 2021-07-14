return function()
	local Library = script.Parent.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local Vote = require(Library.Components.Preview.Vote)

	local function createTestAsset(container, name)
		local voting = {
			CanVote = false,
			HasVoted = false,
			UserVote = false,
		}

		local element = Roact.createElement(MockWrapper, {}, {
			Vote = Roact.createElement(Vote, {
				Position = UDim2.new(1, 0, 1, 0),
				Size = UDim2.new(0, 100, 0, 20),
				AssetId = 183435411,
				Voting = voting,
			})
		})

		return Roact.mount(element, container or nil, name or "")
	end

	it("should create and destroy without errors", function()
		local instance = createTestAsset()
		Roact.unmount(instance)
	end)
end