local ShareIdService = {}

local function findNewId(dataStore, label)
	local seed = tick()
	math.randomseed(seed)
	local random = math.random(100000, 999999)
	print(label, random)

	local found = dataStore:GetAsync(tostring(random))

	if found then
		return findNewId(dataStore, label)
	else
		return random
	end
end

function ShareIdService.SaveOutfitId(player, outfitId, characterTable, lockId, outfitIDsDataStore, serializeTable)
	print("OUTFIT ID:", outfitId)
	if outfitId then

		if characterTable["LockedID"] then
			if characterTable["LockedID"] ~= player.UserId then
				warn("Outfit is locked, denying changes.")
				return false
			end
		end

		local success, result = pcall(function()
			local newSlot = {
				["SlotName"] = outfitId,
				["Data"] = characterTable
			}

			local newS = serializeTable(newSlot)
			outfitIDsDataStore:SetAsync(tostring(outfitId), newS)
			return
		end)

		if success then return outfitId else warn(result) return false end

	else

		if lockId then characterTable["LockedID"] = player.UserId else characterTable.LockedID = nil end

		outfitId = findNewId(outfitIDsDataStore, "New OutfitID:")

		local success, result = pcall(function()
			local newSlot = {
				["SlotName"] = outfitId,
				["Data"] = characterTable
			}

			local newS = serializeTable(newSlot)
			outfitIDsDataStore:SetAsync(tostring(outfitId), newS)
			return
		end)
		if success then return outfitId, player.UserId else warn(result) return false end
	end
end

function ShareIdService.LoadOutfitId(player, outfitId, outfitIDsDataStore, deserializeTable, loadCharacter)
	if outfitId then
		local success, result = pcall(function()
			local found = outfitIDsDataStore:GetAsync(tostring(outfitId))
			return found
		end)

		if success then
			if result then
				result = deserializeTable(result)
				result = loadCharacter(player, result)
				return result
			else
				warn("ID", outfitId, "doesn't exist.")
				return result
			end
		else
			warn(result)
			return false
		end

	else
		warn("No Outfit ID provided.")
		return false
	end
end

function ShareIdService.SaveAccessoryId(player, id, selectedAccessories, lockId, accessoryIDsDataStore, serializeTable, serializeAccessoryTable, getMaxAccessoriesForPlayer)
	print("OUTFIT ID:", id)
	if typeof(selectedAccessories) ~= "table" or #selectedAccessories > getMaxAccessoriesForPlayer(player) then return false end
	if id then

		local success, result = pcall(function()
			local newSlot = {
				["SlotName"] = id,
				["Data"] = selectedAccessories
			}

			local newS = serializeTable(newSlot)
			accessoryIDsDataStore:SetAsync(tostring(id), newS)
			return
		end)

		if success then return id else warn(result) return false end

	else
		id = findNewId(accessoryIDsDataStore, "New AccessoryID:")

		local success, result = pcall(function()
			local newSlot = {
				["SlotName"] = id,
				["Data"] = selectedAccessories,
				["Locked"] = true,
			}
			local newS = serializeAccessoryTable(newSlot)
			accessoryIDsDataStore:SetAsync(tostring(id), newS)
			return
		end)
		if success then return id, player.UserId else warn(result) return false end
	end
end

function ShareIdService.LoadAccessoryId(player, id, dependencies)
	local success, result = pcall(function()
		warn("Getting Accessory ID thingy", id)
		return dependencies.AccessoryIDsDataStore:GetAsync(tostring(id))
	end)
	warn("results:", success, result)
	if success and result then
		warn(result)
		local slotData = dependencies.DeserializeAccessoryTable(result)
		local character = player.Character
		local accCount = 0
		for _, value in pairs(character:GetChildren()) do
			if value:IsA("Accessory") then
				accCount = accCount + 1
			end
		end

		local max = dependencies.GetMaxAccessoriesForPlayer(player)

		warn("MAX:", max)
		if (accCount + #slotData["Data"]) > max then return false end
		for _, accessoryTable in pairs(slotData["Data"]) do
			if not accessoryTable.IsMeshPart then
				if accessoryTable.DistanceFromOriginC0 then
					accessoryTable.DistanceFromOrigin = accessoryTable.DistanceFromOriginC0
					accessoryTable.DistanceFromOriginC0 = nil
				end
				local newAccessory = dependencies.DefaultAccessory:Clone()
				newAccessory.Name = accessoryTable.Name
				newAccessory.AttachmentForward = accessoryTable.AttachmentForward
				newAccessory.AttachmentPos = accessoryTable.AttachmentPos
				newAccessory.AttachmentRight = accessoryTable.AttachmentRight
				newAccessory.AttachmentUp = accessoryTable.AttachmentUp

				accessoryTable.Object = newAccessory
				newAccessory.Handle.OriginalSize.Value = accessoryTable["OriginalSize"]

				newAccessory.Handle.Size = accessoryTable.HandleSize
				newAccessory.Handle.Color = Color3.new(accessoryTable.Color.X, accessoryTable.Color.Y, accessoryTable.Color.Z)

				local newAttachment = newAccessory.Handle:FindFirstChildOfClass("Attachment")
				newAttachment.Name = accessoryTable.Attachment.Name
				newAttachment.Axis = accessoryTable.Attachment.Axis
				newAttachment.SecondaryAxis = accessoryTable.Attachment.SecondaryAxis
				newAttachment.Position = accessoryTable.Attachment.Position
				newAttachment.Orientation = accessoryTable.Attachment.Orientation

				local newMesh = newAccessory.Handle:FindFirstChildOfClass("SpecialMesh")

				newMesh.MeshId = accessoryTable["MeshId"]
				newMesh.TextureId = accessoryTable.TextureId
				newMesh.VertexColor = accessoryTable["Color"]
				newMesh.Offset = accessoryTable.Offset
				newMesh.Scale = accessoryTable.Scale

				newAccessory.Handle.Transparency = accessoryTable["Transparency"]
				newAccessory.Handle.Material = accessoryTable.Material

				character.Humanoid:AddAccessory(newAccessory)

				local newWeld = newAccessory.Handle:FindFirstChildOfClass("Weld")
				newWeld.Part1 = character:FindFirstChild(accessoryTable["WeldPart"])

				newMesh.Offset = accessoryTable.Offset
				newMesh.Scale = accessoryTable.Scale

				dependencies.ApplyParticleData(accessoryTable, newAccessory.Handle)

				newWeld.C0 = accessoryTable.AccessoryWeld.C0
				newWeld.C1 = CFrame.new(0,0,0)

				if not accessoryTable["DistanceFromOrigin"] then
					accessoryTable["DistanceFromOrigin"] = accessoryTable["AccessoryWeld"]["C0"].Position - accessoryTable["OriginalC0"].Position
				end

				if not accessoryTable.RotationsApplied then
					local x, y, z = accessoryTable["AccessoryWeld"]["C0"]:ToEulerAnglesXYZ()
					local x1, y1, z1 = accessoryTable["OriginalC0"]:ToEulerAnglesXYZ()
					accessoryTable["RotationsApplied"] = Vector3.new(x-x1, y-y1, z-z1)
				end
			else
				local humanoid = player.Character.Humanoid
				warn("Meshpart loading found!", accessoryTable.AccessoryId)
				local accessoryId = accessoryTable.AccessoryId
				local insertedAccessory = dependencies.InsertService:LoadAsset(accessoryId)
				insertedAccessory.Parent = workspace
				insertedAccessory = insertedAccessory:FindFirstChildOfClass("Accessory")
				insertedAccessory.Handle.Transparency = accessoryTable.Transparency

				local newVal = Instance.new("IntValue")
				newVal.Value = accessoryId
				newVal.Name = "AccessoryId"
				newVal.Parent = insertedAccessory

				insertedAccessory.Parent = workspace
				humanoid:AddAccessory(insertedAccessory)

				accessoryTable.Object = insertedAccessory

				if accessoryTable.ColorMode == "Overlay" then
					local oTransparency = accessoryTable.OTransparency
					local oColor = accessoryTable.Color or accessoryTable.OColor
					dependencies.CreateOverlay(accessoryTable.Object, oTransparency, oColor)
				end

				dependencies.ApplyParticleData(accessoryTable, insertedAccessory.Handle)
			end
		end

		return slotData["Data"]
	else
		return false
	end
end

return ShareIdService
