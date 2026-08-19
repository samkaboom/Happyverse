local AccessoryLifecycleService = {}

function AccessoryLifecycleService.AddAccessory(self,Player,Id, dependencies)
		if self[Player.Name] then
			print(Player,Id)

			local function isRealAccessory(accessoryid)
				local suc, ass = pcall(function()
					local ass1 = dependencies.InsertService:LoadAsset(accessoryid)

					if ass1 then
						if ass1:FindFirstChildOfClass("Accessory") then
							return ass1:FindFirstChildOfClass("Accessory")
						else
							print(ass1:FindFirstChild())
							return false
						end
					else
						print(ass1:FindFirstChild())
						return false
					end
				end)

				if suc then
					if ass then
						return ass
					else
						return false
					end
				end
			end
			local result = isRealAccessory(Id)
			print("result:", result)
			if result == false or result == nil then return false end
			if result.Handle:IsA("MeshPart") then
				local newVal = Instance.new("IntValue")
				newVal.Value = Id
				newVal.Name = "AccessoryId"
				newVal.Parent = result
			end
			if result.Handle:IsA("MeshPart") and not result.Handle:FindFirstChildOfClass("WrapLayer") then
				result = dependencies.ConvertToSpecialMesh(Player.Character, result)
				if not result then return false end

				task.wait()

				dependencies.ApplyLiveInsertedHeadAccessoryCounterScale(result, Player.Character)

				return result
			end

			result.Parent = workspace
			Player.Character.Humanoid:AddAccessory(result)

			task.wait()

			dependencies.ApplyLiveInsertedHeadAccessoryCounterScale(result, Player.Character)

			return result
		end
end

	AddItem= function(self, Player, Weapon)
		if self[Player.Name] then
			warn("AddItem", Player, Weapon)
			local GamepassItemTool, GamepassItemCharacter = dependencies.SpawnGamepassItem:Invoke(Player, Weapon, CFrame.new(0,0,0))
			return GamepassItemCharacter
		end
end

function AccessoryLifecycleService.BlankAccessory(self,Player,Id, dependencies)
		if self[Player.Name] then
			print(Player,Id)
			local NewAccessory = dependencies.ServerAssets["Custom Accessory"]:Clone()
			NewAccessory.Handle.Mesh.MeshId = "rbxassetid://" .. tostring(Id)
			NewAccessory.Handle.Mesh.TextureId = "rbxassetid://" .. tostring(10140774759)
			NewAccessory.Parent = workspace
			Player.Character.Humanoid:AddAccessory(NewAccessory)

			task.wait()

			dependencies.ApplyLiveInsertedHeadAccessoryCounterScale(NewAccessory, Player.Character)

			return true
		end
end

function AccessoryLifecycleService.Delete(self,Player,SelectedAccessories, dependencies)
		if self[Player.Name] then
			for i, Table in pairs(SelectedAccessories) do
				local Accessory : Accessory = Table.Object
				if not dependencies.ValidateAccessoryOwner(Player, Accessory) then return end
				if Table.IsItemPack then
					local tool = dependencies.FindToolFromItem(Player, Table.Object)
					if not tool then return false end 
					tool:Destroy()
				end
				Table.Object:Destroy()
			end
			return true
		end
end


function AccessoryLifecycleService.OToggle(self, Player, SelectedAccessories, Value, dependencies)
		return dependencies.AccessoryEditService.SetOverlayMode(Player, SelectedAccessories, Value, dependencies.ValidateAccessoryOwner, dependencies.CreateOverlay, dependencies.DeleteOverlay)
end


function AccessoryLifecycleService.OTransparency(self, Player, SelectedAccessories, Value, dependencies)
		return dependencies.AccessoryEditService.SetOverlayTransparency(Player, SelectedAccessories, Value, dependencies.ValidateAccessoryOwner, dependencies.ChangeOverlay)
end


function AccessoryLifecycleService.OColor(Self, Player, SelectedAccessories, Value, dependencies)
		return dependencies.AccessoryEditService.SetOverlayColor(Player, SelectedAccessories, Value, dependencies.ValidateAccessoryOwner, dependencies.ChangeOverlay)
end



function AccessoryLifecycleService.Revert(self,Player,SelectedAccessories, dependencies)
		if self[Player.Name] then
			local CopyOfTable = dependencies.DeepCopy(SelectedAccessories)
			for i, Table in ipairs(CopyOfTable) do

				local Accessory : Accessory = Table.Object
				if not dependencies.ValidateAccessoryOwner(Player, Accessory) then return end
				if not Table.IsMeshPart and not Table.IsItemPack then
					local handle = Accessory.Handle
					local weld = handle:FindFirstChildOfClass("Weld")
					local mesh = handle:FindFirstChildOfClass("SpecialMesh")
					local emitter = handle:FindFirstChildOfClass("ParticleEmitter")
					if emitter then emitter:Destroy() end
					Table["AccessoryWeld"]["C0"] = Table["RevertC0"]

					weld.C0 = Table["OriginalC0"]

					Table["AccessoryWeld"]["C1"] = Table["OriginalC1"]

					weld.C1 = Table["OriginalC1"]

					Table["WeldPart"] = Table["OriginalWeldPart"]
					weld.Part1 = Player.Character[Table["OriginalWeldPart"]]

					Table["Scale"] = Table["RevertScale"]
					mesh.Scale = Table.RevertScale

					Table["MeshId"] = Table["OriginalMeshId"]
					mesh.MeshId = Table["OriginalMeshId"]

					Table["TextureId"] = Table["OriginalTextureId"]
					mesh.TextureId = Table["OriginalTextureId"]

					Table["Color"] = Vector3.new(1,1,1)
					Table["OColor"] = Color3.new(Table["OriginalColor"].X, Table["OriginalColor"].Y, Table["OriginalColor"].Z)
					mesh.VertexColor = Table["OriginalColor"]

					Table["OTransparency"] = 0.5
					Table["ColorMode"] = "VertexColor"
					dependencies.DeleteOverlay(Accessory)

					Table["Transparency"] = Table["OriginalTransparency"]
					handle.Transparency = Table["OriginalTransparency"]

					Table["Material"] = Table["OriginalMaterial"]
					handle.Material = Table["OriginalMaterial"]

					Table["DistanceFromOrigin"] = Vector3.new(0,0,0)

					Table.RotationsApplied = Vector3.new(0,0,0)
				elseif Table.IsMeshPart then
					Table["Color"] = Vector3.new(1,1,1)
					Table["OColor"] = Color3.new(1,1,1)
					Table["OriginalTextureId"] = Table["OriginalTextureId"] or Table["TextureId"]
					Table["TextureId"] = Table["OriginalTextureId"]


					Table.OriginalMaterial = Table.OriginalMaterial or Table.Material
					Table.Material = Table.OriginalMaterial

					Accessory.Handle.TextureID = Table["OriginalTextureId"]
					Accessory.Handle.Material = Table.OriginalMaterial

					Table["OTransparency"] = 0.5
					Table["ColorMode"] = "VertexColor"
					dependencies.DeleteOverlay(Accessory)

					local Wrap = Accessory.Handle:FindFirstChildOfClass("WrapLayer")
					Wrap.Enabled = false; Wrap.Enabled = true


				end
			end


			return CopyOfTable

		end
end

function AccessoryLifecycleService.Copy(self,Player,SelectedAccessories, dependencies)
		if self[Player.Name] then
			local Character = Player.Character
			local Humanoid = Character.Humanoid


			for i, Table in pairs(SelectedAccessories) do
				warn("Test:", i, Table.Name)
				local Accessory : Accessory = Table.Object
				if not dependencies.ValidateAccessoryOwner(Player, Accessory) then return end
				if not Table.IsItemPack and not Table.IsMeshPart then

					local AccessoryTable = Table

					local NewAccessory = dependencies.DefaultAccessory:Clone()
					NewAccessory.Name = AccessoryTable.Name
					NewAccessory.AttachmentForward = AccessoryTable.AttachmentForward
					NewAccessory.AttachmentPos = AccessoryTable.AttachmentPos
					NewAccessory.AttachmentRight = AccessoryTable.AttachmentRight
					NewAccessory.AttachmentUp = AccessoryTable.AttachmentUp

					AccessoryTable.Object = NewAccessory
					NewAccessory.Handle.OriginalSize.Value = AccessoryTable["OriginalSize"]


					NewAccessory.Handle.Size = AccessoryTable.HandleSize
					NewAccessory.Handle.Color = Color3.new(AccessoryTable.Color.X, AccessoryTable.Color.Y, AccessoryTable.Color.Z)

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
					NewMesh.Scale = AccessoryTable.Scale

					NewAccessory.Handle.Transparency = AccessoryTable["Transparency"]
					NewAccessory.Handle.Material = AccessoryTable.Material

					NewAccessory.Parent = workspace
					Character.Humanoid:AddAccessory(NewAccessory)

					local NewWeld = NewAccessory.Handle:FindFirstChildOfClass("Weld")
					NewWeld.Part1 = Character:FindFirstChild(AccessoryTable["WeldPart"])

					NewMesh.Offset = AccessoryTable.Offset
					NewMesh.Scale = AccessoryTable.Scale

					if AccessoryTable.ColorMode == "Overlay" then
						local OTransparency = AccessoryTable.OTransparency
						local OColor = AccessoryTable.OColor or AccessoryTable.Color
						dependencies.CreateOverlay(AccessoryTable.Object, OTransparency, OColor)
						NewMesh.VertexColor = AccessoryTable["Color"]
					else
						NewMesh.VertexColor = AccessoryTable["Color"]
					end


					dependencies.ApplyParticleData(AccessoryTable, NewAccessory.Handle)


					--SlotData.Accessories[i].OriginalC0 = NewAccessory.Handle.CFrame:ToObjectSpace(NewWeld.Part1.CFrame)
					--SlotData.Accessories[i].OriginalC1 = CFrame.new(0,0,0)

					NewWeld.C0 = AccessoryTable.AccessoryWeld.C0
					NewWeld.C1 = CFrame.new(0,0,0)

					if not AccessoryTable["DistanceFromOrigin"] then
						AccessoryTable["DistanceFromOrigin"] = AccessoryTable["AccessoryWeld"]["C0"].Position - AccessoryTable["OriginalC0"].Position
					end


					if not AccessoryTable.RotationsApplied then
						local X, Y, Z = AccessoryTable["AccessoryWeld"]["C0"]:ToEulerAnglesXYZ()
						local X1, Y1, Z1 = AccessoryTable["OriginalC0"]:ToEulerAnglesXYZ()
						AccessoryTable["RotationsApplied"] = Vector3.new(X-X1, Y-Y1, Z-Z1)
					end

				elseif Table.IsItemPack == true then
					local GamepassItemTool, GamepassItemCharacter = dependencies.SpawnGamepassItem:Invoke(Player, Table.WeaponName, Table.AccessoryWeld.C0, Table.Name)
					Table.Object = GamepassItemCharacter
					wait()
					warn("OBJECT?", Table.Object)
				elseif Table.IsMeshPart == true then
					local AccessoryTable = Table

					warn("Meshpart loading found!", AccessoryTable.AccessoryId)
					local AccessoryId = AccessoryTable.AccessoryId
					local InsertedAccessory = dependencies.InsertService:LoadAsset(AccessoryId)
					InsertedAccessory.Parent = workspace
					InsertedAccessory = InsertedAccessory:FindFirstChildOfClass("Accessory")
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
						local OColor = AccessoryTable.OColor
						dependencies.CreateOverlay(AccessoryTable.Object, OTransparency, OColor)
					end

					dependencies.ApplyParticleData(AccessoryTable, InsertedAccessory.Handle)
				end
			end
			local newT = dependencies.DeepCopy(SelectedAccessories)
			print("test", newT[1].Object)

			return newT
		end
end


return AccessoryLifecycleService
