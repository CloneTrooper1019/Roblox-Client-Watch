local Style = script.Parent
local Core = Style.Parent
local UIBlox = Core.Parent

--Note: remove along with styleRefactorConfig
local UIBloxConfig = require(UIBlox.UIBloxConfig)
local styleRefactorConfig = UIBloxConfig.styleRefactorConfig

if not styleRefactorConfig then
	return require(UIBlox.Style.StyleConsumer)
end
---

local StyleContext = require(Style.StyleContext)

return StyleContext.Consumer