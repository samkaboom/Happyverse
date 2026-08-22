--# selene: allow(deprecated)

local CharacterLoader = {}

function CharacterLoader.new(deps)
	local HttpService = deps.HttpService
	local ReplicatedStorage = deps.ReplicatedStorage
	local DefaultAccessory = deps.DefaultAccessory
	local DefaultType = deps.DefaultType
	local DefaultProportion = deps.DefaultProportion
	local HeadScaleMultiplier = deps.HeadScaleMultiplier
	local TargetHeadAssetId = deps.TargetHeadAssetId
	local SpawnGamepassItem = deps.SpawnGamepassItem

	local IsOccupiedSkills = deps.IsOccupiedSkills
	local FindToolFromItem = deps.FindToolFromItem
	local GetClassicClothingTemplate = deps.GetClassicClothingTemplate
	local ApplyHeadBoostAccessoryScale = deps.ApplyHeadBoostAccessoryScale
	local MeshIdMatches = deps.MeshIdMatches
	local CreateOverlay = deps.CreateOverlay
	local ApplyParticleData = deps.ApplyParticleData
	local LoadAssetWithRetry = deps.LoadAssetWithRetry

	local loader = {}

	local function HideCollisionParts(Character)
		for _, obj in ipairs(Character:GetDescendants()) do
			if obj.Name == "CollisionPart" and obj:IsA("BasePart") then
				obj.Transparency = 1
				obj.CastShadow = false
			end
		end
	end

	function loader.LoadCharacter(Player, SlotData)
		print("Load Character", Player, SlotData)
		warn(Player.Name, "Save Data amount:", #HttpService:JSONEncode(SlotData))
		SlotData = SlotData["Data"]

		local Character = Player.Character

		if Character:FindFirstChild("Shirt") == nil then
			local s = Instance.new("Shirt", Character)
			s.Name = "Shirt"
		end
		if Character:FindFirstChild("Pants") == nil then
			local p = Instance.new("Pants", Character)
			p.Name = "Pants"
		end

		if tonumber(SlotData["ShirtTemplate"]) then
			local id = GetClassicClothingTemplate(SlotData["ShirtTemplate"], "Shirt", "ShirtTemplate")

			Character.Shirt.ShirtTemplate = id or "http://www.roblox.com/asset/?id=5574405815"
		else
			Character.Shirt.ShirtTemplate = SlotData["ShirtTemplate"] or "http://www.roblox.com/asset/?id=5574405815"
		end

		if tonumber(SlotData["PantsTemplate"]) then
			local id = GetClassicClothingTemplate(SlotData["PantsTemplate"], "Pants", "PantsTemplate")
			Character.Pants.PantsTemplate = id or "http://www.roblox.com/asset/?id=5574405815"
		else
			Character.Pants.PantsTemplate = SlotData["PantsTemplate"] or "http://www.roblox.com/asset/?id=5574420285"
		end

		-- PUT SOME CODE FOR THE NAME AND BIO SYSTEM

		if SlotData["CharacterInformation"] == nil then
			SlotData["CharacterInformation"] = {
				["CharacterName"] = "",
				["CharacterBio"] = "",
				["CharacterImg"] = "",
				["EmpowermentType"] = "",
				["Empowerment"] = "",
				["EmpowermentTitle"] = "",
				["IsCustomEmpowerment"] = false,
				["Skills"] = {
					{},
					{},
					{},
					{},
					{},
				},
			}
		end

		local Folder = ReplicatedStorage.Info[Player.Name]
		Folder.CName.Value = SlotData["CharacterInformation"]["CharacterName"]
		Folder.CBio.Value = SlotData["CharacterInformation"]["CharacterBio"]
		if SlotData["CharacterInformation"]["CharacterImg"] == nil then
			SlotData["CharacterInformation"]["CharacterImg"] = 0
		end
		if SlotData["CharacterInformation"]["CharacterImg"] ~= 0 then
			Folder.CImage.Value = SlotData["CharacterInformation"]["CharacterImg"]
		end
		Folder.EmpowermentTitle.Value = SlotData["CharacterInformation"]["EmpowermentTitle"]
		Folder.EmpowermentType.Value = SlotData["CharacterInformation"]["EmpowermentType"]
		Folder.Empowerment.Value = SlotData["CharacterInformation"]["Empowerment"]

		for i = 1, 5, 1 do
			local val = SlotData["CharacterInformation"].Skills[i]
			warn("SKILL SLOT:", i, "VAL:", val)
			if IsOccupiedSkills(val) then
				print("MORE THAN 0, HAS INFO")
				Folder["Skill" .. tostring(i) .. "Type"].Value = val.Type
				Folder["Skill" .. tostring(i) .. "Title"].Value = val.Title
				Folder["Skill" .. tostring(i) .. "Description"].Value = val.Skill
			else
				print("REMOVE")
				Folder["Skill" .. tostring(i) .. "Type"].Value = ""
				Folder["Skill" .. tostring(i) .. "Title"].Value = ""
				Folder["Skill" .. tostring(i) .. "Description"].Value = ""
			end
		end

		local Humanoid = Character.Humanoid
		Humanoid.BodyWidthScale.Value = SlotData["Scale"]["Width"]
		Humanoid.BodyHeightScale.Value = SlotData["Scale"]["Height"]
		Humanoid.BodyDepthScale.Value = SlotData["Scale"]["Depth"]
		Humanoid.BodyTypeScale.Value = DefaultType
		Humanoid.BodyProportionScale.Value = DefaultProportion
		local boostedHeadScale = (SlotData["Scale"]["Head"] or 1) * HeadScaleMultiplier
		Humanoid.HeadScale.Value = boostedHeadScale

		local Description = Humanoid:GetAppliedDescription()
		Description.RunAnimation = SlotData.Animations.RunAnimation
		Description.IdleAnimation = SlotData.Animations.IdleAnimation
		Description.WalkAnimation = SlotData.Animations.WalkAnimation
		Description.HeightScale = SlotData.Scale.Height
		Description.HeadScale = boostedHeadScale
		Description.DepthScale = SlotData.Scale.Depth
		Description.WidthScale = SlotData.Scale.Width

		Humanoid:ApplyDescription(Description)

		Humanoid.BodyWidthScale.Value = SlotData["Scale"]["Width"] - 0.01
		Humanoid.BodyHeightScale.Value = SlotData["Scale"]["Height"] - 0.01
		Humanoid.BodyDepthScale.Value = SlotData["Scale"]["Depth"] - 0.01
		Humanoid.BodyTypeScale.Value = 0.8 - 0.01
		Humanoid.HeadScale.Value = boostedHeadScale - 0.01

		Humanoid.BodyWidthScale.Value = SlotData["Scale"]["Width"]
		Humanoid.BodyHeightScale.Value = SlotData["Scale"]["Height"]
		Humanoid.BodyDepthScale.Value = SlotData["Scale"]["Depth"]
		Humanoid.BodyTypeScale.Value = DefaultType
		Humanoid.BodyProportionScale.Value = DefaultProportion
		Humanoid.HeadScale.Value = boostedHeadScale

		Character.Head.face.Texture = "rbxthumb://type=Asset&id=" .. tostring(SlotData["FaceID"]) .. "&w=420&h=420"

		Character["Body Colors"].HeadColor3 =
			Color3.new(SlotData.BodyColors.Head.R, SlotData.BodyColors.Head.G, SlotData.BodyColors.Head.B)
		Character["Body Colors"].RightArmColor3 =
			Color3.new(SlotData.BodyColors.RightArm.R, SlotData.BodyColors.RightArm.G, SlotData.BodyColors.RightArm.B)
		Character["Body Colors"].LeftArmColor3 =
			Color3.new(SlotData.BodyColors.LeftArm.R, SlotData.BodyColors.LeftArm.G, SlotData.BodyColors.LeftArm.B)
		Character["Body Colors"].TorsoColor3 =
			Color3.new(SlotData.BodyColors.Torso.R, SlotData.BodyColors.Torso.G, SlotData.BodyColors.Torso.B)
		Character["Body Colors"].RightLegColor3 =
			Color3.new(SlotData.BodyColors.RightLeg.R, SlotData.BodyColors.RightLeg.G, SlotData.BodyColors.RightLeg.B)
		Character["Body Colors"].LeftLegColor3 =
			Color3.new(SlotData.BodyColors.LeftLeg.R, SlotData.BodyColors.LeftLeg.G, SlotData.BodyColors.LeftLeg.B)

		for _, v in pairs(Character:GetChildren()) do
			if v:IsA("BasePart") or v:IsA("MeshPart") then
				if v.Name ~= "HumanoidRootPart" then
					v.Transparency = 0
				end
			end
		end

		for LimbName, v in pairs(SlotData["LimbRemover"]) do
			if v == true then
				local Limb = Character:FindFirstChild(LimbName)
				if Limb then
					Limb.Transparency = 1
				end
			end
		end

		for _, Accessory in pairs(Character:GetChildren()) do
			if Accessory:IsA("Accessory") then
				Accessory:Destroy()
			elseif Accessory:GetAttribute("displayAccessory") == true then
				FindToolFromItem(Player, Accessory):Destroy()
				Accessory:Destroy()
			end
		end

		local NewAccessoryTable = {}
		local IsIncorrectIndex = false
		for i, AccessoryTable in pairs(SlotData["Accessories"]) do
			--print("i:", i, "table:", AccessoryTable)
			if not tonumber(i) then
				IsIncorrectIndex = true
			end
			if AccessoryTable.DistanceFromOriginC0 then
				AccessoryTable.DistanceFromOrigin = AccessoryTable.DistanceFromOriginC0
				AccessoryTable.DistanceFromOriginC0 = nil
			end

			if not AccessoryTable.IsItemPack and not AccessoryTable.IsMeshPart then -- regular accessories
				local NewAccessory = DefaultAccessory:Clone()
				NewAccessory.Name = AccessoryTable.Name
				NewAccessory.AttachmentForward = AccessoryTable.AttachmentForward
				NewAccessory.AttachmentPos = AccessoryTable.AttachmentPos
				NewAccessory.AttachmentRight = AccessoryTable.AttachmentRight
				NewAccessory.AttachmentUp = AccessoryTable.AttachmentUp

				AccessoryTable.Object = NewAccessory
				NewAccessory.Handle.OriginalSize.Value = AccessoryTable["OriginalSize"]

				NewAccessory.Handle.Size = AccessoryTable.HandleSize
				NewAccessory.Handle.Color =
					Color3.new(AccessoryTable.Color.X, AccessoryTable.Color.Y, AccessoryTable.Color.Z)

				local NewAttachment = NewAccessory.Handle:FindFirstChildOfClass("Attachment")
				NewAttachment.Name = AccessoryTable.Attachment.Name
				NewAttachment.Axis = AccessoryTable.Attachment.Axis
				NewAttachment.SecondaryAxis = AccessoryTable.Attachment.SecondaryAxis
				NewAttachment.Position = AccessoryTable.Attachment.Position
				NewAttachment.Orientation = AccessoryTable.Attachment.Orientation

				local NewMesh = NewAccessory.Handle:FindFirstChildOfClass("SpecialMesh")

				NewMesh.MeshId = AccessoryTable["MeshId"]
				NewMesh.TextureId = AccessoryTable.TextureId

				NewMesh.Offset = AccessoryTable.Offset
				ApplyHeadBoostAccessoryScale(AccessoryTable, NewAccessory, NewMesh)

				if MeshIdMatches(AccessoryTable["MeshId"], TargetHeadAssetId) then
					local collisionPart = NewAccessory:FindFirstChild("CollisionPart", true)
					if collisionPart and collisionPart:IsA("BasePart") then
						collisionPart.Transparency = 1
						collisionPart.CastShadow = false
					end
				end

				NewAccessory.Handle.Transparency = AccessoryTable["Transparency"]
				NewAccessory.Handle.Material = AccessoryTable.Material

				NewAccessory.Parent = workspace
				Character.Humanoid:AddAccessory(NewAccessory)

				local NewWeld = NewAccessory.Handle:FindFirstChildOfClass("Weld")
				NewWeld.Part1 = Character:FindFirstChild(AccessoryTable["WeldPart"])

				NewMesh.Offset = AccessoryTable.Offset
				ApplyHeadBoostAccessoryScale(AccessoryTable, NewAccessory, NewMesh)

				if AccessoryTable.ColorMode == "Overlay" then
					local OTransparency = AccessoryTable.OTransparency
					local OColor = AccessoryTable.OColor or AccessoryTable.Color
					CreateOverlay(AccessoryTable.Object, OTransparency, OColor)
					NewMesh.VertexColor = AccessoryTable["Color"]
				else
					NewMesh.VertexColor = AccessoryTable["Color"]
				end

				ApplyParticleData(AccessoryTable, NewAccessory.Handle)

				--SlotData.Accessories[i].OriginalC0 = NewAccessory.Handle.CFrame:ToObjectSpace(NewWeld.Part1.CFrame)
				--SlotData.Accessories[i].OriginalC1 = CFrame.new(0,0,0)

				NewWeld.C0 = AccessoryTable.AccessoryWeld.C0
				NewWeld.C1 = CFrame.new(0, 0, 0)

				if not AccessoryTable["DistanceFromOrigin"] then
					AccessoryTable["DistanceFromOrigin"] = AccessoryTable["AccessoryWeld"]["C0"].Position
						- AccessoryTable["OriginalC0"].Position
				end

				if not AccessoryTable.RotationsApplied then
					local X, Y, Z = AccessoryTable["AccessoryWeld"]["C0"]:ToEulerAnglesXYZ()
					local X1, Y1, Z1 = AccessoryTable["OriginalC0"]:ToEulerAnglesXYZ()
					AccessoryTable["RotationsApplied"] = Vector3.new(X - X1, Y - Y1, Z - Z1)
				end

				if IsIncorrectIndex == true then
					table.insert(NewAccessoryTable, AccessoryTable)
				end
			elseif AccessoryTable.IsItemPack then -- its an item pack
				print("Item pack item detected", AccessoryTable.Name)
				local _GamepassItemTool, GamepassItemCharacter = SpawnGamepassItem:Invoke(
					Player,
					AccessoryTable.WeaponName,
					AccessoryTable.AccessoryWeld.C0,
					AccessoryTable.Name
				)
				AccessoryTable.Object = GamepassItemCharacter
				AccessoryTable.Object.Handle:FindFirstChild("AccessoryWeld").Part1 =
					Player.Character:FindFirstChild(AccessoryTable.WeldPart)
				wait()
				if IsIncorrectIndex == true then
					table.insert(NewAccessoryTable, AccessoryTable)
				end
			elseif AccessoryTable.IsMeshPart then -- its layered clothing
				warn("Meshpart loading found!", AccessoryTable.AccessoryId)
				local AccessoryId = AccessoryTable.AccessoryId
				local InsertedAccessory = LoadAssetWithRetry(AccessoryId, "LoadCharacter MeshPart")
				if not InsertedAccessory then
					return
				end
				InsertedAccessory.Parent = workspace
				InsertedAccessory = InsertedAccessory:FindFirstChildOfClass("Accessory")
				if not InsertedAccessory then
					return
				end
				InsertedAccessory.Handle.Transparency = AccessoryTable.Transparency

				local newVal = Instance.new("IntValue")
				newVal.Value = AccessoryId
				newVal.Name = "AccessoryId"
				newVal.Parent = InsertedAccessory

				InsertedAccessory.Parent = workspace
				Humanoid:AddAccessory(InsertedAccessory)

				AccessoryTable.Object = InsertedAccessory

				if AccessoryTable.ColorMode == "Overlay" then
					local OTransparency = AccessoryTable.OTransparency
					local OColor = AccessoryTable.Color or AccessoryTable.OColor
					CreateOverlay(AccessoryTable.Object, OTransparency, OColor)
				end

				ApplyParticleData(AccessoryTable, InsertedAccessory.Handle)
			end
		end

		if IsIncorrectIndex == true then
			print("Incorrect index")
			SlotData["Accessories"] = NewAccessoryTable
		end
		HideCollisionParts(Character)

		local collisionConn
		collisionConn = Character.DescendantAdded:Connect(function(obj)
			if obj.Name == "CollisionPart" and obj:IsA("BasePart") then
				obj.Transparency = 1
				obj.CastShadow = false
			end
		end)

		task.delay(2, function()
			if collisionConn then
				collisionConn:Disconnect()
				collisionConn = nil
			end
		end)

		return SlotData
	end

	return loader
end

return CharacterLoader
