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

return ShareIdService
