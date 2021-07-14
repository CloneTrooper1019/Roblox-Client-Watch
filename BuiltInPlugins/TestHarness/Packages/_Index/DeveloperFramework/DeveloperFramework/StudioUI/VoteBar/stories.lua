local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local VoteBar = require(script.Parent)
local Container = require(Framework.UI.Container)

return function()
	return {
		NoVotes = Roact.createElement(VoteBar, {
			AssetId = 123,
			OnVoteUp = function() end,
			OnVoteDown = function() end,
			Voting = {
				UpVotes = 0,
				DownVotes = 0,
			}
		}),
		AllUp = Roact.createElement(VoteBar, {
			AssetId = 123,
			OnVoteUp = function() end,
			OnVoteDown = function() end,
			Voting = {
				UpVotes = 1,
				DownVotes = 0,
			}
		}),
		AllDown = Roact.createElement(VoteBar, {
			AssetId = 123,
			OnVoteUp = function() end,
			OnVoteDown = function() end,
			Voting = {
				UpVotes = 0,
				DownVotes = 1,
			}
		}),
		Mix = Roact.createElement(VoteBar, {
			AssetId = 123,
			OnVoteUp = function() end,
			OnVoteDown = function() end,
			Voting = {
				UpVotes = 5,
				DownVotes = 4,
			}
		}),
		CanVote = Roact.createElement(VoteBar, {
			AssetId = 123,
			OnVoteUp = function() end,
			OnVoteDown = function() end,
			Voting = {
				UpVotes = 5,
				DownVotes = 4,
				CanVote = true,
			}
		}),
		HasVotedUp = Roact.createElement(VoteBar, {
			AssetId = 123,
			OnVoteUp = function() end,
			OnVoteDown = function() end,
			Voting = {
				UpVotes = 5,
				DownVotes = 4,
				CanVote = true,
				UserVote = true
			}
		}),
		HasVotedDown = Roact.createElement(VoteBar, {
			AssetId = 123,
			OnVoteUp = function() end,
			OnVoteDown = function() end,
			Voting = {
				UpVotes = 5,
				DownVotes = 4,
				CanVote = true,
				UserVote = false
			}
		}),
		LowWidth = Roact.createElement(Container, {
			Size = UDim2.new(0, 183, 0, 30)
		}, {
			VoteBar = Roact.createElement(VoteBar, {
				AssetId = 123,
				OnVoteUp = function() end,
				OnVoteDown = function() end,
				Voting = {
					UpVotes = 5,
					DownVotes = 0,
					CanVote = true,
					UserVote = false
				}
			})
		})
	}
end