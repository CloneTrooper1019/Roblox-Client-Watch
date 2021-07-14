return function()
	local Plugin = script.Parent.Parent.Parent
	local GetFFlagDebugExtendAnimationLimit = require(Plugin.LuaFlags.GetFFlagDebugExtendAnimationLimit)

	local AnimationData = require(script.Parent.AnimationData)

	local bones = {"TestTrack", "OtherTrack"}
	local testAnimationData = {
		Metadata = {
			Name = "Test Animation",
			StartFrame = 0,
			EndFrame = 3,
			FrameRate = 30,
		},
		Instances = {
			Root = {
				Type = "Skeleton",
				Tracks = {
					["TestTrack"] = {
						Keyframes = {1, 2, 3},
						Data = {
							[1] = {
								Value = CFrame.new(0, 1, 0),
								EasingStyle = Enum.PoseEasingStyle.Linear,
								EasingDirection = Enum.PoseEasingDirection.In,
							},
							[2] = {
								Value = CFrame.new(1, 0, 0),
								EasingStyle = Enum.PoseEasingStyle.Linear,
								EasingDirection = Enum.PoseEasingDirection.In,
							},
							[3] = {
								Value = CFrame.new(0, 0, 1),
								EasingStyle = Enum.PoseEasingStyle.Linear,
								EasingDirection = Enum.PoseEasingDirection.In,
							},
						}
					},
					["OtherTrack"] = {
						Keyframes = {1, 2, 3},
						Data = {
							[1] = {
								Value = CFrame.new(1, 1, 0),
								EasingStyle = Enum.PoseEasingStyle.Linear,
								EasingDirection = Enum.PoseEasingDirection.In,
							},
							[2] = {
								Value = CFrame.new(1, 0, 1),
								EasingStyle = Enum.PoseEasingStyle.Linear,
								EasingDirection = Enum.PoseEasingDirection.In,
							},
							[3] = {
								Value = CFrame.new(0, 1, 1),
								EasingStyle = Enum.PoseEasingStyle.Linear,
								EasingDirection = Enum.PoseEasingDirection.In,
							},
						}
					}
				},
			},
		},
	}

	describe("new", function()
		it("should expect a name parameter", function()
			expect(function()
				AnimationData.new()
			end).to.throw()
		end)

		it("should expect a frameRate parameter", function()
			expect(function()
				AnimationData.new("Test")
			end).to.throw()
		end)

		it("should expect frameRate to be positive", function()
			expect(function()
				AnimationData.new("Test", -1)
			end).to.throw()
		end)
	end)

	describe("toCFrameArray", function()
		it("should create a valid CFrame[][]", function()
			local metadata = testAnimationData.Metadata
			local poses = AnimationData.toCFrameArray(bones, testAnimationData)
			local animationLength = metadata.EndFrame - metadata.StartFrame

			expect(poses).to.be.ok()

			expect(#poses).to.equal(#bones)

			for _, keyframes in ipairs(poses) do
				expect(typeof(keyframes)).to.equal("table")
				expect(#keyframes).to.equal(animationLength)
				for _, value in ipairs(keyframes) do
					expect(typeof(value)).to.equal("CFrame")
				end
			end
		end)

		it("should set the correct values", function()
			local poses = AnimationData.toCFrameArray(bones, testAnimationData)
			local tracks = testAnimationData.Instances.Root.Tracks

			for bone, keyframes in ipairs(poses) do
				for frame, value in ipairs(keyframes) do
					local track = tracks[bones[bone]]
					expect(value).to.equal(track.Data[frame].Value)
				end
			end
		end)

		it("should make an empty array for a track that doesn't exist", function()
			local moreBones = {"TestTrack", "OtherTrack", "NoTrack"}
			local poses = AnimationData.toCFrameArray(moreBones, testAnimationData)
			expect(#poses).to.equal(3)
			expect(#poses[3]).to.equal(0)
		end)

		it("should create a double length array for double frame rate", function()
			local metadata = testAnimationData.Metadata
			local poses = AnimationData.toCFrameArray(bones, testAnimationData, metadata.FrameRate * 2)

			expect(#poses[1]).to.equal((metadata.EndFrame - metadata.StartFrame) * 2)
		end)

		it("should create a half length array for half frame rate", function()
			local metadata = testAnimationData.Metadata
			local poses = AnimationData.toCFrameArray(bones, testAnimationData, metadata.FrameRate * 0.5)

			expect(#poses[1]).to.equal(math.floor((metadata.EndFrame - metadata.StartFrame) * 0.5))
		end)

		it("should throw if the expected bones array is not correct", function()
			expect(function()
				AnimationData.toCFrameArray()
			end).to.throw()

			expect(function()
				AnimationData.toCFrameArray("a string")
			end).to.throw()
		end)

		it("should throw if the expected data is not correct", function()
			expect(function()
				AnimationData.toCFrameArray(bones)
			end).to.throw()

			expect(function()
				AnimationData.toCFrameArray(bones, "a string")
			end).to.throw()
		end)

		it("should throw if the expected frame rate is not correct", function()
			expect(function()
				AnimationData.toCFrameArray(bones, testAnimationData, 0)
			end).to.throw()
		end)
	end)

	describe("fromCFrameArray", function()
		it("should create a valid animation table", function()
			local metadata = testAnimationData.Metadata
			local poses = AnimationData.toCFrameArray(bones, testAnimationData)

			local newAnimData = AnimationData.fromCFrameArray(bones, poses,
				metadata.Name, metadata.FrameRate)

			expect(newAnimData).to.be.ok()
			expect(newAnimData.Metadata).to.be.ok()
			expect(newAnimData.Events).to.be.ok()
			expect(newAnimData.Instances).to.be.ok()
			expect(newAnimData.Instances.Root).to.be.ok()
			expect(newAnimData.Instances.Root.Type).to.equal("Skeleton")

			local tracks = newAnimData.Instances.Root.Tracks
			expect(tracks).to.be.ok()
			expect(typeof(tracks)).to.equal("table")
			for _, bone in ipairs(bones) do
				expect(tracks[bone]).to.be.ok()
			end

			local track = tracks[bones[1]]
			expect(track).to.be.ok()
			expect(typeof(track)).to.equal("table")
			expect(track.Keyframes).to.be.ok()
			expect(typeof(track.Keyframes)).to.equal("table")
			expect(#track.Keyframes).to.equal(#poses[1])
			expect(track.Data).to.be.ok()
			expect(typeof(track.Data)).to.equal("table")

			local trackData = track.Data[1]
			expect(trackData).to.be.ok()
			expect(trackData.Value).to.be.ok()
			expect(trackData.EasingStyle).to.be.ok()
			expect(trackData.EasingDirection).to.be.ok()
		end)

		it("should set the correct values", function()
			local metadata = testAnimationData.Metadata
			local poses = AnimationData.toCFrameArray(bones, testAnimationData)

			local newAnimData = AnimationData.fromCFrameArray(bones, poses,
				metadata.Name, metadata.FrameRate)

			local tracks = newAnimData.Instances.Root.Tracks

			for bone, keyframes in ipairs(poses) do
				for frame, value in ipairs(keyframes) do
					local track = tracks[bones[bone]]
					expect(track.Data).to.be.ok()

					local trackData = track.Data[frame]
					expect(trackData.EasingStyle).to.equal(Enum.PoseEasingStyle.Linear)
					expect(trackData.EasingDirection).to.equal(Enum.PoseEasingDirection.In)
					expect(trackData.Value).to.equal(value)
				end
			end
		end)

		it("should not create a track for an empty keyframe set", function()
			local metadata = testAnimationData.Metadata
			local moreBones = {"TestTrack", "OtherTrack", "NoTrack"}
			local poses = AnimationData.toCFrameArray(moreBones, testAnimationData)

			local newAnimData = AnimationData.fromCFrameArray(bones, poses,
				metadata.Name, metadata.FrameRate)

			local tracks = newAnimData.Instances.Root.Tracks
			expect(tracks["TestTrack"]).to.be.ok()
			expect(tracks["OtherTrack"]).to.be.ok()
			expect(tracks["NoTrack"]).never.to.be.ok()
		end)

		it("should throw if the expected bones array is not correct", function()
			expect(function()
				AnimationData.fromCFrameArray()
			end).to.throw()

			expect(function()
				AnimationData.fromCFrameArray("a string")
			end).to.throw()
		end)
	end)

	it("should round-trip from the same CFrame[][] without loss", function()
		local metadata = testAnimationData.Metadata
		local poses = AnimationData.toCFrameArray(bones, testAnimationData)

		local newAnimData = AnimationData.fromCFrameArray(bones, poses,
			metadata.Name, metadata.FrameRate)

		local newPoses = AnimationData.toCFrameArray(bones, newAnimData)

		for frame, pose in ipairs(newPoses) do
			for boneIndex, value in ipairs(pose) do
				expect(poses[frame][boneIndex]).to.equal(value)
			end
		end
	end)

	describe("addTrack", function()
		it("should add a new track", function()
			local tracks = {
				NewTrack = nil,
			}

			AnimationData.addTrack(tracks, "NewTrack")
			expect(tracks.NewTrack).to.be.ok()
			expect(tracks.NewTrack.Data).to.be.ok()
			expect(tracks.NewTrack.Keyframes).to.be.ok()
		end)

		it("should preserve the old tracks", function()
			local tracks = {
				OldTrack = {},
			}
			AnimationData.addTrack(tracks, "NewTrack")
			expect(tracks.OldTrack).to.be.ok()
		end)
	end)

	describe("addKeyframe", function()
		it("should add a new keyframe", function()
			local track = {
				Keyframes = {},
				Data = {},
			}
			AnimationData.addKeyframe(track, 1, CFrame.new())
			expect(#track.Keyframes).to.equal(1)
			expect(track.Data[1]).to.be.ok()
			expect(track.Data[1].Value).to.equal(CFrame.new())
		end)

		it("should preserve the old keyframes", function()
			local track = {
				Keyframes = {1},
				Data = {
					[1] = {},
				},
			}
			AnimationData.addKeyframe(track, 2, CFrame.new())
			expect(#track.Keyframes).to.equal(2)
			expect(track.Data[1]).to.be.ok()
		end)

		it("should sort the Keyframes table after adding", function()
			local track = {
				Keyframes = {1, 3},
				Data = {
					[1] = {},
					[3] = {},
				},
			}
			AnimationData.addKeyframe(track, 2, CFrame.new())
			expect(track.Keyframes[1]).to.equal(1)
			expect(track.Keyframes[2]).to.equal(2)
			expect(track.Keyframes[3]).to.equal(3)
		end)
	end)

	describe("moveKeyframe", function()
		it("should move a keyframe", function()
			local track = {
				Keyframes = {1},
				Data = {
					[1] = {},
				},
			}
			AnimationData.moveKeyframe(track, 1, 2)
			expect(#track.Keyframes).to.equal(1)
			expect(track.Keyframes[1]).to.equal(2)
			expect(track.Data[1]).never.to.be.ok()
			expect(track.Data[2]).to.be.ok()
		end)

		it("should preserve the old keyframes", function()
			local track = {
				Keyframes = {1, 2},
				Data = {
					[1] = {},
					[2] = {},
				},
			}
			AnimationData.moveKeyframe(track, 2, 3)
			expect(#track.Keyframes).to.equal(2)
			expect(track.Data[1]).to.be.ok()
		end)

		it("should clobber a keyframe if another is moved onto it", function()
			local track = {
				Keyframes = {1, 2},
				Data = {
					[1] = {
						Value = "KeepThis",
					},
					[2] = {
						Value = "DeleteThis",
					},
				},
			}
			AnimationData.moveKeyframe(track, 1, 2)
			expect(#track.Keyframes).to.equal(1)
			expect(track.Data[2].Value).to.equal("KeepThis")
		end)

		it("should sort the Keyframes table after moving", function()
			local track = {
				Keyframes = {2, 3},
				Data = {
					[2] = {},
					[3] = {},
				},
			}
			AnimationData.moveKeyframe(track, 3, 1)
			expect(track.Keyframes[1]).to.equal(1)
			expect(track.Keyframes[2]).to.equal(2)
		end)
	end)

	describe("deleteKeyframe", function()
		it("should delete a keyframe", function()
			local track = {
				Keyframes = {1, 2},
				Data = {
					[1] = {},
					[2] = {},
				},
			}
			AnimationData.deleteKeyframe(track, 2)
			expect(#track.Keyframes).to.equal(1)
			expect(track.Data[2]).never.to.be.ok()
		end)

		it("should preserve the old keyframes", function()
			local track = {
				Keyframes = {1, 2},
				Data = {
					[1] = {},
					[2] = {},
				},
			}
			AnimationData.deleteKeyframe(track, 2)
			expect(track.Data[1]).to.be.ok()
		end)
	end)

	describe("setKeyframeData", function()
		it("should set a keyframe's data", function()
			local track = {
				Keyframes = {1},
				Data = {
					[1] = {},
				},
			}
			AnimationData.setKeyframeData(track, 1, {
				Value = CFrame.new(),
				EasingDirection = Enum.PoseEasingDirection.In,
				EasingStyle = Enum.PoseEasingStyle.Linear,
			})
			expect(track.Data[1]).to.be.ok()
			expect(track.Data[1].Value).to.equal(CFrame.new())
			expect(track.Data[1].EasingDirection).to.equal(Enum.PoseEasingDirection.In)
			expect(track.Data[1].EasingStyle).to.equal(Enum.PoseEasingStyle.Linear)
		end)

		it("should merge with the keyframe's existing data", function()
			local track = {
				Keyframes = {1},
				Data = {
					[1] = {
						Value = CFrame.new()
					},
				},
			}
			AnimationData.setKeyframeData(track, 1, {
				EasingDirection = Enum.PoseEasingDirection.In,
				EasingStyle = Enum.PoseEasingStyle.Linear,
			})
			expect(track.Data[1]).to.be.ok()
			expect(track.Data[1].Value).to.equal(CFrame.new())
			expect(track.Data[1].EasingDirection).to.equal(Enum.PoseEasingDirection.In)
			expect(track.Data[1].EasingStyle).to.equal(Enum.PoseEasingStyle.Linear)
		end)
	end)

	describe("addEvent", function()
		it("should add an event to the Events table", function()
			local events = {
				Keyframes = {},
				Data = {},
			}
			AnimationData.addEvent(events, 1, "TestEvent", "TestValue")
			expect(events.Data[1]).to.be.ok()
			expect(events.Data[1].TestEvent).to.equal("TestValue")
			expect(#events.Keyframes).to.equal(1)
		end)

		it("should be able to add events to multiple keyframes", function()
			local events = {
				Keyframes = {},
				Data = {},
			}
			AnimationData.addEvent(events, 1, "TestEvent", "TestValue")
			AnimationData.addEvent(events, 2, "TestEvent", "OtherValue")
			expect(events.Data[1].TestEvent).to.equal("TestValue")
			expect(events.Data[2].TestEvent).to.equal("OtherValue")
			expect(#events.Keyframes).to.equal(2)
		end)

		it("should be able to add multiple events to the same keyframe", function()
			local events = {
				Keyframes = {},
				Data = {},
			}
			AnimationData.addEvent(events, 1, "TestEvent", "TestValue")
			AnimationData.addEvent(events, 1, "OtherEvent", "OtherValue")
			expect(events.Data[1].TestEvent).to.equal("TestValue")
			expect(events.Data[1].OtherEvent).to.equal("OtherValue")
			expect(#events.Keyframes).to.equal(1)
		end)

		it("should not add duplicate events to the same keyframe", function()
			local events = {
				Keyframes = {},
				Data = {},
			}
			AnimationData.addEvent(events, 1, "TestEvent", "TestValue")
			AnimationData.addEvent(events, 1, "TestEvent", "OtherValue")
			expect(events.Data[1].TestEvent).to.equal("TestValue")
		end)
	end)

	describe("removeEvent", function()
		it("should remove an event from the Events table", function()
			local events = {
				Keyframes = {1},
				Data = {
					[1] = {
						TestEvent = "SomeValue",
					},
				},
			}
			AnimationData.removeEvent(events, 1, "TestEvent")
			expect(events.Data[1]).never.to.be.ok()
			expect(#events.Keyframes).to.equal(0)
		end)
	end)

	describe("moveEvents", function()
		it("should move all events at the old frame to the new frame", function()
			local events = {
				Keyframes = {1},
				Data = {
					[1] = {
						TestEvent = "SomeValue",
						OtherEvent = "OtherValue",
					},
				},
			}
			AnimationData.moveEvents(events, 1, 2)
			expect(events.Data[1]).never.to.be.ok()
			expect(events.Data[2]).to.be.ok()
			expect(events.Data[2].TestEvent).to.equal("SomeValue")
			expect(events.Data[2].OtherEvent).to.equal("OtherValue")
			expect(#events.Keyframes).to.equal(1)
			expect(events.Keyframes[1]).to.equal(2)
		end)

		it("should clobber existing events that are beneath moved events", function()
			local events = {
				Keyframes = {1},
				Data = {
					[1] = {
						TestEvent = "SomeValue",
					},
					[2] = {
						OtherEvent = "OtherValue",
					},
				},
			}
			AnimationData.moveEvents(events, 1, 2)
			expect(events.Data[1]).never.to.be.ok()
			expect(events.Data[2]).to.be.ok()
			expect(events.Data[2].TestEvent).to.equal("SomeValue")
			expect(events.Data[2].OtherEvent).never.to.be.ok()
		end)
	end)

	describe("deleteEvents", function()
		it("should delete all events at the given frame", function()
			local events = {
				Keyframes = {1},
				Data = {
					[1] = {
						TestEvent = "SomeValue",
						OtherEvent = "OtherValue",
					},
				},
			}
			AnimationData.deleteEvents(events, 1)
			expect(events.Data[1]).never.to.be.ok()
			expect(#events.Keyframes).to.equal(0)
		end)
	end)

	describe("setEventValue", function()
		it("should set the value of the event at the given frame and name", function()
			local events = {
				Keyframes = {1},
				Data = {
					[1] = {
						TestEvent = "SomeValue",
						OtherEvent = "OtherValue",
					},
				},
			}
			AnimationData.setEventValue(events, 1, "TestEvent", "NewValue")
			expect(events.Data[1].TestEvent).to.equal("NewValue")
		end)
	end)

	describe("isQuantized", function()
		it("should return true when there are no in-between keyframes", function()
			expect(AnimationData.isQuantized(testAnimationData)).to.equal(true)
		end)

		it("should return false when there are in-between keyframes", function()
			local testLegacyData = {
				Instances = {
					Root = {
						Tracks = {
							["TestTrack"] = {
								Keyframes = {1, 2, 2.1, 3},
							},
						},
					},
				},
			}
			expect(AnimationData.isQuantized(testLegacyData)).to.equal(false)
		end)
	end)

	describe("setKeyframeName", function()
		it("should set the name of a keyframe", function()
			local data = {
				Events = {
					NamedKeyframes = {},
				},
			}
			AnimationData.setKeyframeName(data, 1, "TestName")
			expect(data.Events.NamedKeyframes[1]).to.equal("TestName")
		end)

		it("should remove the name of a keyframe", function()
			local data = {
				Events = {
					NamedKeyframes = {
						[1] = "TestName",
					},
				},
			}
			AnimationData.setKeyframeName(data, 1, nil)
			expect(data.Events.NamedKeyframes[1]).never.to.be.ok()
		end)
	end)

	describe("moveNamedKeyframe", function()
		it("should keep the name at oldFrame if a keyframe still exists there", function()
			local data = {
				Metadata = {
					StartFrame = 0,
					EndFrame = 1,
				},
				Events = {
					NamedKeyframes = {
						[1] = "TestName",
					},
				},
				Instances = {
					Root = {
						Tracks = {
							TestTrack = {
								Keyframes = {1},
							},
						},
					},
				},
			}
			AnimationData.moveNamedKeyframe(data, 1, 2)
			expect(data.Events.NamedKeyframes[1]).to.equal("TestName")
			expect(data.Events.NamedKeyframes[2]).never.to.be.ok()
		end)

		it("should move the name if no other keyframes exist at oldFrame", function()
			local data = {
				Metadata = {
					StartFrame = 0,
					EndFrame = 1,
				},
				Events = {
					NamedKeyframes = {
						[1] = "TestName",
					},
				},
				Instances = {
					Root = {
						Tracks = {
							TestTrack = {
								Keyframes = {2},
							},
						},
					},
				},
			}
			AnimationData.moveNamedKeyframe(data, 1, 2)
			expect(data.Events.NamedKeyframes[2]).to.equal("TestName")
			expect(data.Events.NamedKeyframes[1]).never.to.be.ok()
		end)
	end)

	describe("validateKeyframeNames", function()
		it("should keep all valid keyframe names", function()
			local data = {
				Metadata = {
					StartFrame = 0,
					EndFrame = 3,
				},
				Events = {
					NamedKeyframes = {
						[1] = "TestName",
						[2] = "TestName",
						[3] = "TestName",
					},
				},
				Instances = {
					Root = {
						Tracks = {
							TestTrack = {
								Keyframes = {1, 2, 3},
							},
						},
					},
				},
			}
			AnimationData.validateKeyframeNames(data)
			expect(data.Events.NamedKeyframes[1]).to.equal("TestName")
			expect(data.Events.NamedKeyframes[2]).to.equal("TestName")
			expect(data.Events.NamedKeyframes[3]).to.equal("TestName")
		end)

		it("should delete all invalid keyframe names", function()
			local data = {
				Metadata = {
					StartFrame = 0,
					EndFrame = 3,
				},
				Events = {
					NamedKeyframes = {
						[1] = "TestName",
						[2] = "TestName",
						[3] = "TestName",
					},
				},
				Instances = {
					Root = {
						Tracks = {},
					},
				},
			}
			AnimationData.validateKeyframeNames(data)
			expect(data.Events.NamedKeyframes[1]).never.to.be.ok()
			expect(data.Events.NamedKeyframes[2]).never.to.be.ok()
			expect(data.Events.NamedKeyframes[3]).never.to.be.ok()
		end)
	end)

	if not GetFFlagDebugExtendAnimationLimit() then
		describe("removeExtraKeyframes", function()
			it("should remove keyframes from animations that exceed 30 seconds in length", function()
				local excessAnimationData = {
					Metadata = {
						Name = "Test Animation",
						StartFrame = 0,
						EndFrame = 901,
						FrameRate = 30,
					},
					Instances = {
						Root = {
							Type = "Skeleton",
							Tracks = {
								["TestTrack"] = {
									Keyframes = {1, 901},
									Data = {
										[1] = {
											Value = CFrame.new(0, 1, 0),
											EasingStyle = Enum.PoseEasingStyle.Linear,
											EasingDirection = Enum.PoseEasingDirection.In,
										},
										[901] = {
											Value = CFrame.new(1, 0, 0),
											EasingStyle = Enum.PoseEasingStyle.Linear,
											EasingDirection = Enum.PoseEasingDirection.In,
										},
									},
								},
							},
						},
					},
				}

				local removed = AnimationData.removeExtraKeyframes(excessAnimationData)
				expect(removed).to.equal(true)
				expect(#excessAnimationData.Instances.Root.Tracks.TestTrack.Keyframes).to.equal(1)
				expect(excessAnimationData.Instances.Root.Tracks.TestTrack.Keyframes[1]).to.equal(1)

				local validData = {
					Metadata = {
						Name = "Test Animation",
						StartFrame = 0,
						EndFrame = 900,
						FrameRate = 30,
					},
					Instances = {
						Root = {
							Type = "Skeleton",
							Tracks = {
								["TestTrack"] = {
									Keyframes = {1, 900},
									Data = {
										[1] = {
											Value = CFrame.new(0, 1, 0),
											EasingStyle = Enum.PoseEasingStyle.Linear,
											EasingDirection = Enum.PoseEasingDirection.In,
										},
										[900] = {
											Value = CFrame.new(1, 0, 0),
											EasingStyle = Enum.PoseEasingStyle.Linear,
											EasingDirection = Enum.PoseEasingDirection.In,
										},
									},
								},
							},
						},
					},
				}

				removed = AnimationData.removeExtraKeyframes(validData)
				expect(removed).to.equal(false)
				expect(#validData.Instances.Root.Tracks.TestTrack.Keyframes).to.equal(2)
			end)
		end)
	end
end
