--[[
	Play Animation on previwing avatar

	Required Props:
		boolean IsPlaying: if animation is playing or pausing, which is provided via store
		number Playhead: position of the current anim, which is provided via store
		number SliderPlayhead: position of the current anim by slider, which is provided via store
		callback SetPlayhead: function to set the playhead, which is provided via mapDispatchToProps.
		callback SetIsPlaying: function to set is animation is playing, which is provided via mapDispatchToProps.
		callback SetTrackLength: function to set animation track's length, which is provided via mapDispatchToProps.
	Optional Props:
		number AnimationId: animation id that is selecting now, which is provided via store
		table EditingItemContext: An EditingItemContext, which is provided via mapToProps.
		table PreviewContext: A Preview ContextItem, which is provided via mapToProps.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local EditingItemContext = require(Plugin.Src.Context.EditingItemContext)
local PreviewContext = require(Plugin.Src.Context.PreviewContext)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local AnimationPlayback = Roact.PureComponent:extend("AnimationPlayback")

local SetPlayhead = require(Plugin.Src.Actions.SetPlayhead)
local SetTrackLength = require(Plugin.Src.Actions.SetTrackLength)
local SetIsPlaying = require(Plugin.Src.Actions.SetIsPlaying)

local PreviewingInfo = require(Plugin.Src.Util.PreviewingInfo)

local RunService = game:GetService("RunService")

local Util = Framework.Util
local Typecheck = Util.Typecheck
Typecheck.wrap(AnimationPlayback, script)

function AnimationPlayback:init()
	self.tracks = {}
	self.animations = {}
	self.previousAnimationURL = nil
end

local function hasFinished(self, now)
	local _, track = next(self.tracks)
	if track then
		return now - self.StartTime > track.Length
	end

	return false
end

function AnimationPlayback:didMount()
	self.Stepped = RunService.Heartbeat:Connect(function()
		local props = self.props
		local playhead = props.Playhead
		local _, track = next(self.tracks)
		if props.IsPlaying and track and track.Length > 0 then
			if track.Length ~= props.trackLength then
				props.SetTrackLength(track.Length)
			end
			local now = tick()
			if not self.StartTime then
				self.StartTime = now - playhead
			end
			if hasFinished(self, now) then
				self.StartTime += track.Length
			end
			local elapsed = now - self.StartTime
			props.SetPlayhead(elapsed)
		elseif self.StartTime ~= nil then
			self.StartTime = nil
		end
	end)
end

local function getAnimator(avatar)
	if not avatar then
		return nil
	end
	local animationController = avatar:FindFirstChildOfClass("Humanoid") or avatar:FindFirstChildOfClass("AnimationController")
	local animator = animationController and animationController:FindFirstChildOfClass("Animator")
	if animator then
		return animator
	else
		return Instance.new("Animator", animationController)
	end
end

function AnimationPlayback:render()
	local props = self.props
	local previewingAvatars = props.PreviewContext:getAvatars()
	for _, avatar in ipairs(previewingAvatars) do
		local animator = getAnimator(avatar)
		if animator and self.tracks[avatar] then
			self.tracks[avatar]:Play()
			animator:StepAnimations(0)
			animator:StepAnimations(props.Playhead)
		end
	end
end

function AnimationPlayback:cleanOldAnims()
	for _, track in pairs(self.tracks) do
		track:Stop(0)
		track:Destroy()
	end
	self.tracks = {}

	local previewingAvatars = self.props.PreviewContext:getAvatars()
	for _, avatar in ipairs(previewingAvatars) do
		local animator = getAnimator(avatar)
		if animator then
			animator:StepAnimations(0)
		end

		--reset the joints
		if avatar then
			for _, descendant in pairs(avatar:GetDescendants()) do
				if descendant:IsA("Motor6D") then
					local joint = descendant
					joint.CurrentAngle = 0
					joint.Transform = CFrame.new()
				end
			end
		end
	end

	for _, animation in pairs(self.animations) do
		animation:Destroy()
	end

	self.animations = {}
	self.StartTime = nil
	self.props.SetTrackLength(0)
	self.props.SetIsPlaying(false)
	self.props.SetPlayhead(0)
end

local function animationIdToURL(animationId)
	return "http://www.roblox.com/asset/?id="..tostring(animationId)
end

function AnimationPlayback:willUpdate(incomingProps, incomingState)
	local props = self.props
	local previewingAvatars = props.PreviewContext:getAvatars()
	local animationId = incomingProps.AnimationId
	if animationId then
		local animationURL = animationIdToURL(animationId)
		local animChanged = not self.previousAnimationURL or self.previousAnimationURL ~= animationURL
		self.previousAnimationURL = animationURL
		if animChanged then
			self:cleanOldAnims()
			for _, avatar in ipairs(previewingAvatars) do
				local humanoid = avatar:FindFirstChildOfClass("Humanoid")
				if humanoid then
					self.animations[avatar] = Instance.new("Animation")
					self.animations[avatar].AnimationId = animationURL
					self.tracks[avatar] = humanoid:LoadAnimation(self.animations[avatar])
					incomingProps.SetIsPlaying(true)
					incomingProps.SetPlayhead(0)
				end
			end
		end
		-- if animation's playhead is controlled by slider, override the normal playhead
		if incomingProps.SliderPlayhead and incomingProps.SliderPlayhead >=0 then
			incomingProps.SetPlayhead(incomingProps.SliderPlayhead)
		end
	else
		self:cleanOldAnims()
		self.previousAnimationURL = nil
	end
end

function AnimationPlayback:willUnmount()
	self:cleanOldAnims()
	if self.Stepped then
		self.Stepped:Disconnect()
	end
end

ContextServices.mapToProps(AnimationPlayback,{
	EditingItemContext = EditingItemContext,
	PreviewContext = PreviewContext,
})

local function mapStateToProps(state, props)
	local animation = state.animation
	return {
		AnimationId = PreviewingInfo.getPreviewingAnimationId(state),
		IsPlaying = animation.IsPlaying,
		Playhead = animation.Playhead,
		SliderPlayhead = animation.SliderPlayhead,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		SetPlayhead = function(playhead)
			dispatch(SetPlayhead(playhead))
		end,
		SetTrackLength = function(track)
			dispatch(SetTrackLength(track))
		end,
		SetIsPlaying = function(isPlaying)
			dispatch(SetIsPlaying(isPlaying))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(AnimationPlayback)
