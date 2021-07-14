local RunService = game:GetService("RunService")

local DraggerFramework = script.Parent.Parent

local AttachmentMover = {}
AttachmentMover.__index = AttachmentMover

function AttachmentMover.new()
	return setmetatable({}, AttachmentMover)
end

function AttachmentMover:setDragged(attachments)
	self._originalWorldCFrames = {}
	local isRunning = RunService:IsRunning()
	self._partsToUnanchor = {}
	for _, attachment in ipairs(attachments) do
		self._originalWorldCFrames[attachment] = attachment.WorldCFrame
		if isRunning then
			local part = attachment:FindFirstAncestorWhichIsA("BasePart")
			if part and not part:IsGrounded() then
				self._partsToUnanchor[part] = true
			end
		end
	end
	for part, _ in pairs(self._partsToUnanchor) do
		part.Anchored = true
	end
end

function AttachmentMover:transformTo(transform)
	for attachment, originalWorldCFrame in pairs(self._originalWorldCFrames) do
		attachment.WorldCFrame = transform * originalWorldCFrame
	end
end

function AttachmentMover:commit()
	self._originalWorldCFrames = nil
	for part, _ in pairs(self._partsToUnanchor) do
		part.Anchored = false
	end
	self._partsToUnanchor = nil
end

return AttachmentMover