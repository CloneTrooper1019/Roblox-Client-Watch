local Plugin = script.Parent.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Util = Framework.Util
local Action = Util.Action

export type Props = {
	threadId : number,
	currentFrame : number,
}

return Action(script.Name, function(threadId : number, currentFrame : number) : Props
	return {
		currentFrame = currentFrame,
		threadId = threadId
	}
end)
