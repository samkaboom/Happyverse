local CharacterLegacyLoadService = {}

function CharacterLegacyLoadService.LoadLegacyCharacterSlot(Client, Slot, value, dependencies)
	print("Loading legacy slot", Slot, "for", Client)

	-- TestStore1 is the one currently used.

	if value ~= nil then
		print("Entry does exist.")
		local Value = dependencies.DeepCopy(value)
		local Character = Client.Character
		print("Slot name:", Value.SlotName)
		local x = Character.Humanoid.HumanoidDescription:Clone()
		x.Shirt = string.match(tostring(Value["ShirtTemplate"]), "%d+")
		x.Pants = string.match(tostring(Value["PantsTemplate"]), "%d+")
		x.WidthScale = Value["Scale"]["Width"]
		x.HeightScale = Value["Scale"]["Height"]
		x.DepthScale = Value["Scale"]["Depth"]
		x.HeadScale = Value["Scale"]["Head"]
		if Value["Animations"] then
			print("ANIMATIONS: Is a new slot")
			x.WalkAnimation = Value["Animations"]["WalkAnimation"]
			x.RunAnimation = Value["Animations"]["RunAnimation"]
			x.JumpAnimation = Value["Animations"]["JumpAnimation"]
			x.FallAnimation = Value["Animations"]["FallAnimation"]
			x.SwimAnimation = Value["Animations"]["SwimAnimation"]
			x.ClimbAnimation = Value["Animations"]["ClimbAnimation"]
			x.IdleAnimation = Value["Animations"]["IdleAnimation"]
		else
			print("ANIMATIONS: Is an old slot")
			Value["Animations"] = {
				["WalkAnimation"] = x.WalkAnimation,
				["RunAnimation"] = x.RunAnimation,
				["JumpAnimation"] = x.JumpAnimation,
				["FallAnimation"] = x.FallAnimation,
				["SwimAnimation"] = x.SwimAnimation,
				["ClimbAnimation"] = x.ClimbAnimation,
				["IdleAnimation"] = x.IdleAnimation,
			}
		end




		--x.TorsoColor = Client.Character["Body Colors"].Torso
		--ApplyStoredAccessories(Client)




		--x.Face = string.match(tostring(Value["FaceID"]), "%d+")
		Client.Character.Humanoid:ApplyDescription(x)
		repeat wait() until Client.Character:FindFirstChild("HumanoidRootPart")


		--Client.Character.Pants.PantsTemplate = Value["PantsTemplate"]
		Client.Character.Head.face.Texture = Value["FaceID"]

		for x, v in pairs(Value["BodyColors"]) do
			print(x, " LOL", v.R, v.G, v.B)
			Character["Body Colors"][x .. "Color3"] = Color3.fromRGB(v.R*255, v.G*255, v.B*255)
		end

		local CharacterTable = {
			["ParticleEmitters"] = {},
			["Rigs"] = {},
			["Accessories"] = {},
			["Animations"] = {
				["WalkAnimation"] = Character.Humanoid.HumanoidDescription.WalkAnimation,
				["RunAnimation"] = Character.Humanoid.HumanoidDescription.RunAnimation,
				["IdleAnimation"] = Character.Humanoid.HumanoidDescription.IdleAnimation,
			},
			["CharacterInformation"] = {
				["CharacterName"] = "",
				["CharacterBio"] = "",
				["EmpowermentType"] = "",
				["IsCustomEmpowerment"] = false,
				["Empowerment"] = "",
				["EmpowermentTitle"] = "",
				["Skills"] = {
					{}, {}, {}, {}, {}
				}
			},
			["ShirtTemplate"] = Client.Character.Shirt.ShirtTemplate,
			["PantsTemplate"] = Client.Character.Pants.PantsTemplate,
			["FaceID"] = string.gsub(Character.Head.face.Texture, "%D", ""),
			["LimbRemover"] = {},
			["Scale"] = {
				["Height"] = Character.Humanoid.BodyHeightScale.Value,
				["Depth"] = Character.Humanoid.BodyDepthScale.Value,
				["Width"] = Character.Humanoid.BodyWidthScale.Value,
				["Head"] = Character.Humanoid.HeadScale.Value
			},
			["BodyColors"] = {
				["Head"] = {
					["R"] = Character["Body Colors"]["HeadColor3"].R,
					["G"] = Character["Body Colors"]["HeadColor3"].G,
					["B"] = Character["Body Colors"]["HeadColor3"].B
				},
				["RightArm"] = {
					["R"] = Character["Body Colors"]["RightArmColor3"].R,
					["G"] = Character["Body Colors"]["RightArmColor3"].G,
					["B"] = Character["Body Colors"]["RightArmColor3"].B
				},
				["LeftArm"] = {
					["R"] = Character["Body Colors"]["LeftArmColor3"].R,
					["G"] = Character["Body Colors"]["LeftArmColor3"].G,
					["B"] = Character["Body Colors"]["LeftArmColor3"].B
				},
				["LeftLeg"] = {
					["R"] = Character["Body Colors"]["LeftLegColor3"].R,
					["G"] = Character["Body Colors"]["LeftLegColor3"].G,
					["B"] = Character["Body Colors"]["LeftLegColor3"].B
				},
				["RightLeg"] = {
					["R"] = Character["Body Colors"]["RightLegColor3"].R,
					["G"] = Character["Body Colors"]["RightLegColor3"].G,
					["B"] = Character["Body Colors"]["RightLegColor3"].B
				},
				["Torso"] = {
					["R"] = Character["Body Colors"]["TorsoColor3"].R,
					["G"] = Character["Body Colors"]["TorsoColor3"].G,
					["B"] = Character["Body Colors"]["TorsoColor3"].B
				},
			},
		}	

		local laface = Character.Head.face.Texture
		if laface:sub(1,25) == "rbxthumb://type=Asset&id=" then
			print("CUSTOM FACE")
			local str = laface:sub(26, #laface-12)
			print("THE NUMBERS MASON", str)
			CharacterTable["FaceID"] = str
		end

		for i, x in pairs(Character:GetChildren()) do
			if x:IsA("Accessory") then x:Destroy() end
		end

		local NewAccessoryTable = {}
		for i, v in pairs(Value["Accessories"]) do

			local newAccessory = dependencies.DefaultAccessory:Clone()
			newAccessory.Name = i
			newAccessory.AttachmentForward = Vector3.new(v.AttachmentForwardX, v.AttachmentForwardY, v.AttachmentForwardZ)
			newAccessory.AttachmentPos = Vector3.new(v.AttachmentPosX, v.AttachmentPosY, v.AttachmentPosZ)
			newAccessory.AttachmentRight = Vector3.new(v.AttachmentRightX, v.AttachmentRightY, v.AttachmentRightZ)
			newAccessory.AttachmentUp = Vector3.new(v.AttachmentUpX, v.AttachmentUpY, v.AttachmentUpZ)
			newAccessory.Handle.Size = Vector3.new(v.HandleSizeX, v.HandleSizeY, v.HandleSizeZ)
			newAccessory.Handle.Color = Color3.new(v.VertexColorRed, v.VertexColorGreen, v.VertexColorBlue)
			newAccessory.Handle.OriginalSize.Value = Vector3.new(v.HandleSizeX, v.HandleSizeY, v.HandleSizeZ)

			local NewAttachment = newAccessory.Handle:FindFirstChildOfClass("Attachment")

			NewAttachment.Orientation = Vector3.new(v.AttachmentOrientationX, v.AttachmentOrientationY, v.AttachmentOrientationZ)
			NewAttachment.Position = Vector3.new(v.AttachmentPositionX, v.AttachmentPositionY, v.AttachmentPositionZ)
			NewAttachment.SecondaryAxis = Vector3.new(v.AttachmentSecondaryAxisX, v.AttachmentSecondaryAxisY, v.AttachmentSecondaryAxisZ)
			NewAttachment.Name = v.AttachmentName

			local NewMesh = newAccessory.Handle:FindFirstChildOfClass("SpecialMesh")

			NewMesh.MeshId = v.MeshId
			NewMesh.TextureId = v.TextureId
			NewMesh.VertexColor = Vector3.new(v.VertexColorRed, v.VertexColorGreen, v.VertexColorBlue)

			NewMesh.Scale = Vector3.new(v.MeshScaleX, v.MeshScaleY, v.MeshScaleZ)

			newAccessory.Handle.OriginalSize.Value = Vector3.new(v.OriginalSizeX, v.OriginalSizeY, v.OriginalSizeZ)

			newAccessory.Parent = workspace
			Client.Character.Humanoid:AddAccessory(newAccessory)

			local function ConvertToAccessoryTable(child)
				wait()
				local handle = child.Handle
				local mesh = handle:FindFirstChildOfClass("SpecialMesh")
				local attachment = handle:FindFirstChildOfClass("Attachment")
				local weld = handle:FindFirstChildOfClass("Weld")

				local SavedTableToApply = {
					["Object"] = child,
					["Name"] = child.Name,
					["MeshId"] = mesh.MeshId,
					["HandleSize"] = handle.Size,
					["TextureId"] = mesh.TextureId,
					["Color"] = mesh.VertexColor,
					["Transparency"] = handle.Transparency,
					["Material"] = handle.Material,
					["Scale"] = mesh.Scale,
					["Offset"] = mesh.Offset,
					["OriginalSize"] = handle:WaitForChild("OriginalSize").Value,
					["AccessoryWeld"] = {["C0"] = handle.CFrame:ToObjectSpace(weld.Part1.CFrame), ["C1"] = CFrame.new(0,0,0)},
					["DistanceFromOrigin"] = Vector3.new(0,0,0),
					["RotationsApplied"] = Vector3.new(0,0,0),
					["DistanceFromOriginC1"] = Vector3.new(0,0,0),
					["WeldPart"] = weld.Part1.Name,
					["OriginalC0"] = handle.CFrame:ToObjectSpace(weld.Part1.CFrame),
					["OriginalC1"] = CFrame.new(0,0,0),
					["RevertScale"] = NewMesh.Scale,
					["RootScale"] =  NewMesh.Scale,
					["OriginalMeshId"] = mesh.MeshId,
					["Particle"] = "None",
					["ParticleColor"] = Color3.fromRGB(255,255,255),
					["ParticleSize"] = 0,
					["ParticleTransparency"] = 0,
					["ParticleRate"] = 0,
					["OriginalTextureId"] = v.OriginalTextureId,
					["OriginalColor"] = Vector3.new(1,1,1),
					["OriginalTransparency"] = handle.Transparency,
					["OriginalMaterial"] = handle.Material,
					["OriginalWeldPart"] = weld.Part1.Name,
					["AttachmentForward"] = child.AttachmentForward,
					["AttachmentPos"] = child.AttachmentPos,
					["AttachmentRight"] = child.AttachmentRight,
					["AttachmentUp"] = child.AttachmentUp,
					["Attachment"] = {["Name"] = attachment.Name, ["Axis"] = attachment.Axis, ["SecondaryAxis"] = attachment.SecondaryAxis, ["Orientation"] = attachment.Orientation, ["Position"] = attachment.Position}
				}

				local HeadScale = CharacterTable.Scale.Head
				local Width = CharacterTable.Scale.Width
				local Depth = CharacterTable.Scale.Depth
				local Height = CharacterTable.Scale.Height

				if handle:FindFirstChild("HairAttachment") or handle:FindFirstChild("FaceFrontAttachment") or handle:FindFirstChild("HatAttachment") then
					SavedTableToApply.RootScale = Vector3.new(SavedTableToApply.RevertScale.X/HeadScale, SavedTableToApply.RevertScale.Y/HeadScale, SavedTableToApply.RevertScale.Z/HeadScale)
				else
					SavedTableToApply.RootScale = Vector3.new(SavedTableToApply.RevertScale.X/Width, SavedTableToApply.RevertScale.Y/Height, SavedTableToApply.RevertScale.Z/Depth)
				end

				local X,Y,Z = SavedTableToApply.OriginalC0:ToEulerAnglesXYZ()

				SavedTableToApply.RootRotation = Vector3.new(X,Y,Z)

				return SavedTableToApply
			end

			local SavedTableToApply = ConvertToAccessoryTable(newAccessory)

			local weld = newAccessory.Handle:FindFirstChildOfClass("Weld")
			print("REVERT SCALE:", SavedTableToApply.RevertScale)
			weld.C0 = (CFrame.new(v.OriginalC0X, v.OriginalC0Y, v.OriginalC0Z, v.OriginalC0R00, v.OriginalC0R01, v.OriginalC0R02, v.OriginalC0R10, v.OriginalC0R11, v.OriginalC0R12, v.OriginalC0R20, v.OriginalC0R21, v.OriginalC0R22) * CFrame.Angles(math.rad(v.RotationX), math.rad(v.RotationY), math.rad(v.RotationZ))) + (Vector3.new(v.PositionX, v.PositionY, v.PositionZ)/10)

			local val
			if newAccessory.Handle:FindFirstChild("HairAttachment") or newAccessory.Handle:FindFirstChild("FaceFrontAttachment") or newAccessory.Handle:FindFirstChild("HatAttachment") then
				val = (Vector3.new(v.SizeX, v.SizeY, v.SizeZ)/10)*Client.Character.Humanoid.HeadScale.Value
			else
				val = (Vector3.new((v.SizeX/10)*Client.Character.Humanoid.BodyWidthScale.Value, (v.SizeY/10)*Client.Character.Humanoid.BodyHeightScale.Value, (v.SizeZ/10)*Client.Character.Humanoid.BodyDepthScale.Value))
			end
			newAccessory.Handle:FindFirstChildOfClass("SpecialMesh").Scale = Vector3.new(v.MeshScaleX, v.MeshScaleY, v.MeshScaleZ) + val
			SavedTableToApply["Scale"] = newAccessory.Handle:FindFirstChildOfClass("SpecialMesh").Scale
			weld.C1 = CFrame.new(v.OriginalC1X, v.OriginalC1Y, v.OriginalC1Z, v.OriginalC1R00, v.OriginalC1R01, v.OriginalC1R02, v.OriginalC1R10, v.OriginalC1R11, v.OriginalC1R12, v.OriginalC1R20, v.OriginalC1R21, v.OriginalC1R22)

			if v.WeldPart1 then
				print("Has")
				weld.Part1 = Client.Character:FindFirstChild(v.WeldPart1)

			else
				print("does not have weldpart property")
				v.WeldPart1 = weld.Part1.Name
				v.OriginalWeldPart1 = weld.Part1.Name

			end


			SavedTableToApply["WeldPart"] = v.WeldPart1
			SavedTableToApply["AccessoryWeld"]["C0"] = newAccessory.Handle.CFrame:ToObjectSpace(weld.Part1.CFrame)

			-- CONVERTING TABLE TO NEW SYSTEM

			table.insert(NewAccessoryTable, SavedTableToApply)
		end

		CharacterTable["Accessories"] = NewAccessoryTable

		if Value["LimbRemover"] ~= nil then
			print("Has Limb remover")
			for i, v in pairs(Client.Character:GetChildren()) do
				if v:IsA("BasePart") or v:IsA("UnionOperation") then
					if v.Name ~= "HumanoidRootPart" then
						if Value["LimbRemover"][v.Name] ~= nil then
							dependencies.LimbRemover(Client, v.Name, Value["LimbRemover"][v.Name])
							CharacterTable["LimbRemover"][v.Name] = true
						else
							v.Transparency = 0
						end
					end
				end
			end
		else
			for i, v in pairs(Client.Character:GetChildren()) do
				if v:IsA("BasePart") or v:IsA("UnionOperation") then
					if v.Name ~= "HumanoidRootPart" then

						v.Transparency = 0

					end
				end
			end
		end		

		return CharacterTable
	else
		print("Entry does not exist.")
		return false
	end
end



return CharacterLegacyLoadService
