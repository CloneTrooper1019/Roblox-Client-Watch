--[[
	This thunk is used to change which tracks are currently opened
	and visible in the Animation Editor window. The user can choose which
	tracks to open, so that not every track is automatically immediately
	populated when the user opens an instance.

	Sorts tracks alphabetically and by hierarchy, then sets them.

	Parameters:
		list<Track> newTracks: The new tracks to show.
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Packages.Cryo)
local SkeletonUtils = require(Plugin.Src.Util.SkeletonUtils)
local RigUtils = require(Plugin.Src.Util.RigUtils)
local FacsUtils = require(Plugin.Src.Util.FacsUtils)

local SetTracks = require(Plugin.Src.Actions.SetTracks)

local GetFFlagFacialAnimationSupport = require(Plugin.LuaFlags.GetFFlagFacialAnimationSupport)

local function depthFirstTraverse(node, callback, depth)
	local keys = Cryo.Dictionary.keys(node)
	table.sort(keys)

	for _, key in ipairs(keys) do
		local child = node[key]
		local found = callback(key, depth)
		if found then
			depthFirstTraverse(child, callback, depth + 1)
		else
			depthFirstTraverse(child, callback, depth)
		end
	end
end

local function sortByHierarchy(tracks, hierarchy)
	local sorted = {}
	depthFirstTraverse(hierarchy, function(node, depth)
		for _, track in ipairs(tracks) do
			if track.Name == node then
				track.Depth = depth
				table.insert(sorted, track)
				return true
			end
		end
	end, 0)

	return sorted
end

local function sortAlphabetically(tracks)
	table.sort(tracks, function(first, second)
		return first.Name < second.Name
	end)

	for _, track in ipairs(tracks) do
		track.Depth = 0
	end
	return tracks
end

return function(newTracks)
	return function(store)
		local status = store:getState().Status
		local root = status.RootInstance

		local sorted, hierarchy
		local unusedTracks = {}

		-- See if we can sort using a hierarchy
		if root then
			if typeof(root) == "Instance" or type(root) == "table" then
				if root.ClassName == "Skeleton" or root.ClassName == "MockSkeleton" then
					local names, parents
					if root.ClassName == "Skeleton" then
						local bones = root:GetBones()
						names = bones.Names
						parents = bones.Parents
					else
						names = root.Names
						parents = root.Parents
					end
					hierarchy = SkeletonUtils.buildSkeletonHierarchy(names, parents)
					unusedTracks = SkeletonUtils.getUnusedSkeletonTracks(names, newTracks)
				elseif root.ClassName == "Model" and root:FindFirstChildOfClass("Humanoid")
					or root:FindFirstChildOfClass("AnimationController") then
					hierarchy = RigUtils.buildRigHierarchy(root)
					unusedTracks = RigUtils.getUnusedRigTracks(root, newTracks)
				end
			end
		end

		if hierarchy then
			-- If we found a hierarchy to the data, sort by hierarchy
			-- and set depths so we can display the data at
			-- different levels of indentation
			sorted = sortByHierarchy(newTracks, hierarchy)

			if GetFFlagFacialAnimationSupport() then
				-- Facs tracks have been skipped during sortByHierarchy.
				-- Add them now
				local facs = FacsUtils.filterFacsTracks(newTracks)
				sorted = Cryo.List.join(sorted, sortAlphabetically(facs))
			end
		else
			-- If there is no hierarchy do the data, just alphabetically sort
			-- and display every track at the same level of indentation.
			sorted = sortAlphabetically(newTracks)
		end

		if GetFFlagFacialAnimationSupport() then
			local unusedFacs = FacsUtils.getUnusedFacs(newTracks)
			store:dispatch(SetTracks(sorted, unusedTracks, unusedFacs))
		else
			store:dispatch(SetTracks(sorted, unusedTracks))
		end
	end
end