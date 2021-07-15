local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local Votes = require(script.Parent)

return function()
	return {
		NoVotes = Roact.createElement(Votes, {
			Voting = {
				UpVotes = 0,
				DownVotes = 0,
			}
		}),
		AllUp = Roact.createElement(Votes, {
			Voting = {
				UpVotes = 1,
				DownVotes = 0,
			}
		}),
		AllDown = Roact.createElement(Votes, {
			Voting = {
				UpVotes = 0,
				DownVotes = 1,
			}
		}),
		Mix = Roact.createElement(Votes, {
			Voting = {
				UpVotes = 5,
				DownVotes = 4,
			}
		}),
	}
end