export type DebuggerStateToken = {
    session : number, -- session can be convert to some breakpoint Ids (Plural) later when this is set up
    stepNumber : number
}

local function fromData(data) : DebuggerStateToken
	return {
		session = data.session,
		stepNumber = data.stepNumber,
	}
end

return {
	fromData = fromData,
}
