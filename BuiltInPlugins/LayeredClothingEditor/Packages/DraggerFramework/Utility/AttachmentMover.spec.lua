local DraggerFramework = script.Parent.Parent
local AttachmentMover = require(DraggerFramework.Utility.AttachmentMover)

return function()
	local function createTestAttachments()
		local part1 = Instance.new("Part")
		local part2 = Instance.new("Part")
		part1.CFrame = CFrame.new(0, 0, -1.5)
		part2.CFrame = CFrame.new(0, 0, 1.5)

		local attachment1 = Instance.new("Attachment", part1)
		local attachment2 = Instance.new("Attachment", part2)
		local originalCFrames = {}
		originalCFrames[attachment1] = attachment1.WorldCFrame
		originalCFrames[attachment2] = attachment2.WorldCFrame

		return {attachment1, attachment2}, originalCFrames
	end

	it("should transform attachments", function()
		local attachments, originalCFrames = createTestAttachments()
		local transform = CFrame.new(10, 0, 0)

		local attachmentMover = AttachmentMover.new()
		attachmentMover:setDragged(attachments)
		attachmentMover:transformTo(transform)

		for _, attachment in ipairs(attachments) do
			local originalCFrame = originalCFrames[attachment]
			local appliedTransform = attachment.WorldCFrame * originalCFrame:Inverse()
			expect(appliedTransform == transform).to.equal(true)
		end
	end)

	it("should error if used before setting attachments", function()
		local attachmentMover = AttachmentMover.new()

		expect(function()
			attachmentMover:transformTo(CFrame.new(0, 0, -1))
		end).to.throw()
	end)

	it("should error if used after commit", function()
		local attachments = createTestAttachments()

		local attachmentMover = AttachmentMover.new()
		attachmentMover:setDragged(attachments)
		attachmentMover:commit()

		expect(function()
			attachmentMover:transformTo(CFrame.new(0, 0, -1))
		end).to.throw()
	end)

	it("should replace existing when setting attachments", function()
		local attachments, originalCFrames = createTestAttachments()
		local transform = CFrame.new(10, 0, 0)

		local attachmentMover = AttachmentMover.new()
		attachmentMover:setDragged(attachments)
		attachmentMover:setDragged({})
		attachmentMover:transformTo(transform)

		for _, attachment in ipairs(attachments) do
			local originalCFrame = originalCFrames[attachment]
			expect(attachment.WorldCFrame == originalCFrame).to.equal(true)
		end
	end)
end
