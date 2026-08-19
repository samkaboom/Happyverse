local AccessoryFixService = {}

function AccessoryFixService.FixAccessoriesTest(Player, CharacterTable, cachedAccessoriesUniversal)
		Player.Character.Humanoid.HeadScale.Value = CharacterTable["Scale"]["Head"]
		Player.Character.Humanoid.BodyHeightScale.Value = CharacterTable["Scale"]["Height"]
		Player.Character.Humanoid.BodyWidthScale.Value = CharacterTable["Scale"]["Width"]
		Player.Character.Humanoid.BodyDepthScale.Value = CharacterTable["Scale"]["Depth"]

		local CachedAccessoriesTable = cachedAccessoriesUniversal[Player.UserId]
		if CachedAccessoriesTable then
			for i, AccessoryTable in ipairs(CharacterTable.Accessories) do
				local Accessory = AccessoryTable.Object
				local Weld = Accessory.Handle:FindFirstChildOfClass("Weld")
				local NewC0Relative = Accessory.Handle.CFrame:ToObjectSpace(Weld.Part1.CFrame)

				AccessoryTable["OriginalC0"] = NewC0Relative

				AccessoryTable["OriginalC1"] = CFrame.new(0,0,0)

				Weld.Part1 = Player.Character:FindFirstChild(AccessoryTable.WeldPart)

				Weld.C0 = CachedAccessoriesTable[i].AccessoryWeld.C0
				Weld.C1 = CachedAccessoriesTable[i].AccessoryWeld.C1

				local Mesh = Accessory.Handle:FindFirstChildOfClass("SpecialMesh")
				local newScale = Mesh.Scale
				AccessoryTable.Scale = Mesh.Scale

				local val

				if Weld.Part0.Name == "Head" then
					print("ITS A HAIR, FACE, OR HAT ATTACHMENT")

					-- Use saved head scale, not the externally boosted visual head scale.
					local unboostedHeadScale = CharacterTable["Scale"]["Head"] or 1

					val = Vector3.new(
						unboostedHeadScale,
						unboostedHeadScale,
						unboostedHeadScale
					)
				else
					print("ITS A SHOULDER, NECK, OR BACK ATTACHMENT")
					val = Vector3.new(Player.Character.Humanoid.BodyWidthScale.Value, Player.Character.Humanoid.BodyHeightScale.Value, Player.Character.Humanoid.BodyDepthScale.Value)
				end
				AccessoryTable.RevertScale = Vector3.new(val.X * AccessoryTable.RootScale.X, val.Y * AccessoryTable.RootScale.Y, val.Z * AccessoryTable.RootScale.Z)
			end
		end

		table.remove(cachedAccessoriesUniversal, Player.UserId)
		return CharacterTable
	end,

function AccessoryFixService.FixAccessories(Player, CharacterTable, DescriptionToApply, validateAccessoryOwner)


		Player.Character.Humanoid.HeadScale.Value = CharacterTable["Scale"]["Head"]
		Player.Character.Humanoid.BodyHeightScale.Value = CharacterTable["Scale"]["Height"]
		Player.Character.Humanoid.BodyWidthScale.Value = CharacterTable["Scale"]["Width"]
		Player.Character.Humanoid.BodyDepthScale.Value = CharacterTable["Scale"]["Depth"]

		for index, AccessoryTable in pairs(CharacterTable["Accessories"]) do
			if not AccessoryTable.IsMeshPart then
				local Accessory = AccessoryTable.Object
				if Accessory then
					local Accessory : Accessory = AccessoryTable.Object
					if not validateAccessoryOwner(Player, Accessory) then return end
					local Attachment = Accessory.Handle:FindFirstChildOfClass("Attachment")
					if Attachment then
						local val

						-- itll fix scaling i think

						local Weld = Accessory.Handle:FindFirstChildOfClass("Weld")

						if Weld.Part0.Name == "Head" then
							print("ITS A HAIR, FACE, OR HAT ATTACHMENT")
							val = Vector3.new(Player.Character.Humanoid.HeadScale.Value, Player.Character.Humanoid.HeadScale.Value, Player.Character.Humanoid.HeadScale.Value)
						else
							print("ITS A SHOULDER, NECK, OR BACK ATTACHMENT")
							val = Vector3.new(Player.Character.Humanoid.BodyWidthScale.Value, Player.Character.Humanoid.BodyHeightScale.Value, Player.Character.Humanoid.BodyDepthScale.Value)
						end


						local Mesh = Accessory.Handle:FindFirstChildOfClass("SpecialMesh")
						local originalweldpart = Weld.Part1

						Weld.Part1 = Player.Character:FindFirstChild(AccessoryTable.WeldPart)

						local OriginalSavedC0 = AccessoryTable["OriginalC0"]
						local OriginalSavedC1 = AccessoryTable["OriginalC1"]


						AccessoryTable.RevertScale = Vector3.new(val.X * AccessoryTable.RootScale.X, val.Y * AccessoryTable.RootScale.Y, val.Z * AccessoryTable.RootScale.Z)

						local lastScale = AccessoryTable.Scale
						local newScale = Mesh.Scale
						AccessoryTable.Scale = Mesh.Scale



						local NewC0Relative = Accessory.Handle.CFrame:ToObjectSpace(Weld.Part1.CFrame)
						local LastOriginal = AccessoryTable["OriginalC0"]
						local LastC0 = AccessoryTable.AccessoryWeld.C0

						--NewC0Relative = NewC0Relative - NewC0Relative.Rotation

						local DistanceFromOrigin = AccessoryTable["DistanceFromOrigin"]
						--local newOriX, newOriY, newOriZ = NewC0Relative:ToEulerAnglesXYZ()

						AccessoryTable["RevertC0"] = NewC0Relative

						--AccessoryTable["OriginalC1"] = CFrame.new(0,0,0)


						local original = AccessoryTable.OriginalC0:Inverse()


						local distanceFromOrigin = AccessoryTable.DistanceFromOrigin
						local RotationsApplied = AccessoryTable.RotationsApplied

						local weldPCF = Weld.Part1.CFrame

						if not distanceFromOrigin then
							warn("MAKING DISTANCE FROM ORIGIN")
							AccessoryTable.DistanceFromOrigin = AccessoryTable.AccessoryWeld.C0:ToObjectSpace(original).Position
							distanceFromOrigin = AccessoryTable.DistanceFromOrigin
						end

						if not RotationsApplied then
							warn("MAKING ROTAITON FROM ORIGIN")
							local X, Y, Z =  AccessoryTable["AccessoryWeld"]["C0"]:ToObjectSpace(AccessoryTable.OriginalC0):ToEulerAnglesXYZ()
							AccessoryTable.RotationsApplied = Vector3.new(X,Y,Z)
							RotationsApplied = AccessoryTable.RotationsApplied
						end

						local distanceFromOrigin = AccessoryTable.DistanceFromOrigin
						local RotationsApplied = AccessoryTable.RotationsApplied
						local original = AccessoryTable.OriginalC0:Inverse()
						local weldPCF = Weld.Part1.CFrame
						local rx, ry, rz = RotationsApplied.X, RotationsApplied.Y, RotationsApplied.Z
						local originalrx, originalry, originalrz = AccessoryTable.RootRotation.X, AccessoryTable.RootRotation.Y, AccessoryTable.RootRotation.Z
						local PositionCF = (weldPCF * CFrame.new(original.X - distanceFromOrigin.X, original.Y - distanceFromOrigin.Y, original.Z - distanceFromOrigin.Z)).Position
						local RotationCF = weldPCF.Rotation * CFrame.fromEulerAnglesXYZ(originalrx+rx, originalry+ry, originalrz+rz)
						AccessoryTable.AccessoryWeld.C0 = (RotationCF + PositionCF):ToObjectSpace(weldPCF)
						AccessoryTable.AccessoryWeld.C1 = CFrame.new(0,0,0)
						AccessoryTable.DistanceFromOrigin = Vector3.new(distanceFromOrigin.X, distanceFromOrigin.Y, distanceFromOrigin.Z)
						Weld.C0 = AccessoryTable.AccessoryWeld.C0
						Weld.C1 = AccessoryTable.AccessoryWeld.C1 

					end



				end
			end
		end
		return CharacterTable
end

return AccessoryFixService
