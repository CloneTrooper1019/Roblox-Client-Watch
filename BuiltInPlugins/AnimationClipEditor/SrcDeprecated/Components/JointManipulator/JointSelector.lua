--[[
	A component which allows the user to select and manipulate parts which
	are kinematically controlled by the rig within the current instance.

	Props:
		Instance RootInstance = The root instance controlled by the editor.
		Instance Container = A container to place the handles in. Defaults to
			CoreGui, so overrides in this prop are likely for testing only.
		bool IKEnabled = whether or not to use ik manipulation logic when dragging handles
		table MotorData = saved motor data for ik manipulations before the motors were deleted
			Expect format is as follows:
			{
				[part] = {
					Name = motor name
					Parent = parent instance of motor
					Part0 = motor Part0
					Part1 = motor Part1
					C0 = motor C0
					C1 = motor C1
				}
			}
		table SelectedTracks = All currently selected tracks in the track list.

		callback OnManipulateJoint(CFrame newValue) = A callback for when
			a joint's CFrame updates due to manipulation by the user via tools.
		callback OnSelectPart(string partName) = A callback for when the user selects
			a part by clicking on it in the 3D view.
		callback OnDragStart() = A function for when the user starts interacting
			with a tool. Used to dispatch History waypoints.
]]

local RunService = game:GetService("RunService")
local StudioService = game:GetService("StudioService")
local CoreGui = game:GetService("CoreGui")

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)

local PluginContext = require(Plugin.SrcDeprecated.Context.Plugin)
local getPlugin = PluginContext.getPlugin

local RigUtils = require(Plugin.SrcDeprecated.Util.RigUtils)
local Constants = require(Plugin.SrcDeprecated.Util.Constants)
local JointManipulator = require(Plugin.SrcDeprecated.Components.JointManipulator.JointManipulator)

local ToggleWorldSpace = require(Plugin.SrcDeprecated.Actions.ToggleWorldSpace)

local JointSelector = Roact.PureComponent:extend("JointSelector")

function JointSelector:init()
	self.state = {
		HoverPart = nil,
	}

	local rootInstance = self.props.RootInstance
	self.CurrentRoot = rootInstance
	self.KinematicParts, self.PartsToMotors = RigUtils.getRigInfo(rootInstance)
	self.Bones = RigUtils.getBoneMap(rootInstance)

	local mouse = getPlugin(self):GetMouse()
	mouse.TargetFilter = RigUtils.findRootPart(rootInstance)

	self.mouseButtonDown = mouse.Button1Down:Connect(function()
		local props = self.props
		local target = mouse.Target
		if target and self:isValidJoint(target) then
			props.OnSelectPart(target.Name)
			props.Analytics:onTrackSelected(target.Name, "View")
		else
			props.OnSelectPart(nil)
		end
	end)

	self.heartbeat = RunService.Heartbeat:Connect(function(step)
		local target = mouse.Target
		local hoverPart = self.state.HoverPart
		if target ~= hoverPart then
			if target and self:isValidJoint(target)
				and target ~= self.state.HoverPart then
				self:setState({
					HoverPart = target,
				})
			elseif not target or not self:isValidJoint(target) then
				self:setState({
					HoverPart = Roact.None,
				})
			end
		end

		if self.props.WorldSpace ~= not StudioService.UseLocalSpace then
			self.props.ToggleWorldSpace()
		end
	end)

	self.onManipulateJoints = function(values)
		self.props.OnManipulateJoints("Root", values)
	end
end

function JointSelector:isValidJoint(instance)
	local rootInstance = self.props.RootInstance
	return instance:IsDescendantOf(rootInstance) and instance:IsA("BasePart")
		and self.PartsToMotors[instance.Name] ~= nil
end

function JointSelector:willUpdate()
	local rootInstance = self.props.RootInstance

	if rootInstance ~= self.CurrentRoot then
		self.CurrentRoot = rootInstance
		self.KinematicParts, self.PartsToMotors = RigUtils.getRigInfo(rootInstance)
		self.Bones = RigUtils.getBoneMap(rootInstance)
		local mouse = getPlugin(self):GetMouse()
		mouse.TargetFilter = RigUtils.findRootPart(rootInstance)
	end
end

function JointSelector:getJoints()
	local joints = {}
	local selectedTracks = self.props.SelectedTracks
	for _, track in ipairs(selectedTracks) do
		-- because of IK deleting motors during manipulation, it is no longer
		-- safe to pass motors directly.
		if self.PartsToMotors[track] then
			table.insert(joints, {
				Type = Constants.MOTOR_CLASS_NAME,
				Part0 = self.PartsToMotors[track].Part0,
				Part1 = self.PartsToMotors[track].Part1,
				C0 = self.PartsToMotors[track].C0,
				C1 = self.PartsToMotors[track].C1
			})
		elseif self.Bones[track] then
			table.insert(joints, {
				Type = Constants.BONE_CLASS_NAME,
				Bone = self.Bones[track],
			})
		end
	end
	return joints
end

function JointSelector:findCurrentParts(selectedTracks, rootInstance)
	local currentParts = {}
	if selectedTracks and rootInstance and self.KinematicParts and #self.KinematicParts > 0 then
		for _, track in ipairs(selectedTracks) do
			local bone = RigUtils.getBoneByName(rootInstance, track)
			if bone then
				table.insert(currentParts, bone)
			else
				for _, part in ipairs(self.KinematicParts) do
					if part.Name == track then
						table.insert(currentParts, part)
						break
					end
				end
			end
		end
	end

	return (#currentParts > 0) and currentParts or nil
end

function JointSelector:render()
	local state = self.state
	local props = self.props

	local selectedTracks = props.SelectedTracks
	local rootInstance = props.RootInstance
	local currentParts = self:findCurrentParts(selectedTracks, rootInstance)

	local hoverPart = state.HoverPart
	local container = props.Container or CoreGui

	local children = {}
	children["Manipulator"] = currentParts and Roact.createElement(JointManipulator, {
		CurrentPart = currentParts[#currentParts],
		Joints = self:getJoints(),
		RootInstance = props.RootInstance,
		IKEnabled = props.IKEnabled,
		Tool = props.Tool,
		WorldSpace = props.WorldSpace,
		IKMode = props.IKMode,
		StartingPose = props.StartingPose,
		MotorData = props.MotorData,
		SetMotorData = props.SetMotorData,
		PinnedParts = props.PinnedParts,
		OnManipulateJoints = self.onManipulateJoints,
		OnDragStart = props.OnDragStart,
		ToggleWorldSpace = props.ToggleWorldSpace,
		VisualizeBones = props.VisualizeBones,
	})

	children["HoverBox"] = hoverPart and Roact.createElement("SelectionBox", {
		Archivable = false,
		Adornee = hoverPart,
		LineThickness = 0.02,
		Transparency = 0.5,
	})

	if currentParts then
		for index, part in ipairs(currentParts) do
			children["SelectionBox" ..index] = part:IsA("BasePart") and Roact.createElement("SelectionBox", {
				Archivable = false,
				Adornee = part,
				LineThickness = 0.01,
				Transparency = 0.5,
				SurfaceTransparency = 0.8,
			}) or nil
		end
	end

	return Roact.createElement(Roact.Portal, {
		target = container,
	}, children)
end

function JointSelector:willUnmount()
	local mouse = getPlugin(self):GetMouse()
	mouse.TargetFilter = nil

	if self.heartbeat then
		self.heartbeat:Disconnect()
	end

	if self.mouseButtonDown then
		self.mouseButtonDown:Disconnect()
	end
end

local function mapStateToProps(state, props)
	return {
		Tool = state.Status.Tool,
		WorldSpace = state.Status.WorldSpace,
		StartingPose = state.Status.StartingPose,
		Analytics = state.Analytics,
		VisualizeBones = state.Status.VisualizeBones
	}
end

local function mapDispatchToProps(dispatch)
	return {
		ToggleWorldSpace = function()
			dispatch(ToggleWorldSpace())
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(JointSelector)