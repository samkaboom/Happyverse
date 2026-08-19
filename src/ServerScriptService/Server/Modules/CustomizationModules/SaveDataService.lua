local SaveDataService = {}

function SaveDataService.GetSaveFromSlot(userId, forceTrueGet, slot, newSlots, cachedCharacterData, deserializeTable)
	print("GET SAVE", userId, "FORCETRUEGET?", forceTrueGet, slot)
	local success, response = pcall(function()
		local returned
		if forceTrueGet then
			print("Getting forced new data for", userId, "at slot", slot)
			returned = newSlots:GetAsync(tostring(userId) .. "_" .. tostring(slot))
			if returned then
				returned = deserializeTable(returned)
				return returned
			else
				warn(returned)
				return returned
			end
		else

			local function Execute()
				print("Getting forced new data for", userId, "at slot", slot)
				returned = newSlots:GetAsync(tostring(userId) .. "_" .. tostring(slot))
				if returned then
					returned = deserializeTable(returned)
					cachedCharacterData[tostring(userId)][tostring(slot)] = returned
					return returned
				else
					warn(returned)
					return returned
				end
			end


			warn("cache slot:",cachedCharacterData[tostring(userId)][tostring(slot)])
			if cachedCharacterData[tostring(userId)] == nil then print("No UserId slot"); return Execute() end
			if cachedCharacterData[tostring(userId)][tostring(slot)] == nil then print("No slot in general.");  return Execute() else

				return deserializeTable(cachedCharacterData[tostring(userId)][tostring(slot)])
			end
		end
	end)

	if success then
		return response
	else
		warn(response)
		return false
	end
end

function SaveDataService.GetLegacySave(client, cachedLegacyCharacterData)
	local value = cachedLegacyCharacterData[tostring(client.UserId)]
	if value then
		return value
	else
		return false
	end
end

function SaveDataService.GetAllLegacyData(client, dataStoreService, currentLegacyDataStore, httpService)
	print("getting all data")
	local bigTable = {}
	local found = false
	for i = 1, 24, 1 do
		wait()

		local characterInfoDS = dataStoreService:GetDataStore(currentLegacyDataStore .. tostring(i))
		local result, value = pcall(function()

			local dataStoreValue = characterInfoDS:GetAsync(client.UserId)

			return dataStoreValue
		end)

		if result == false then
			warn("Data store isn't working!")
			return false
		end

		if value then

			local decodedValue = httpService:JSONDecode(value)
			bigTable[i] = decodedValue
			found = true
		else
			bigTable[i] = false
		end
	end
	wait()
	if found == false then
		return false
	else
		return bigTable
	end
end

function SaveDataService.PostSave(userId, tableToSave, slot, ignoreCache, newSlots, cachedCharacterData, cachedPlayerSlotNames, serializeTable)
	local success, response = pcall(function()
		local actualTable = serializeTable(tableToSave)
		warn("POSTING NOW", userId, slot)
		newSlots:SetAsync(tostring(userId) .. "_" .. tostring(slot), actualTable)

		if cachedCharacterData[tostring(userId)] == nil then cachedCharacterData[tostring(userId)] = {}; print("Had no cached data so POSTSave made it") end
		if ignoreCache == nil or ignoreCache == false then cachedCharacterData[tostring(userId)][tostring(slot)] = tableToSave end
		cachedPlayerSlotNames[userId][tostring(slot)] = tableToSave.SlotName
		return tableToSave
	end)

	if success then return true else warn(response) return false end
end

function SaveDataService.GetTutorial(player, tutorialDataStore)
	local success, res = pcall(function()
		return tutorialDataStore:GetAsync(player.UserId)
	end)
	if success then
		if res == nil then res = false end
		return res
	else
		return true
	end
end

function SaveDataService.SetTutorial(player, val, tutorialDataStore)
	local success, res = pcall(function()
		tutorialDataStore:SetAsync(player.UserId, val)
		return
	end)
	return true
end

function SaveDataService.SaveCharacter(player, characterData, slotName, slot, postSave, cachedPlayerSlotNames, deepCopy)
	print("Save", player, characterData, slotName, slot)

	local newSlot = {
		["SlotName"] = slotName,
		["Data"] = deepCopy(characterData)
	}
	print("NEW SLOT:", newSlot)
	local postreturn = postSave(player.UserId, newSlot, slot)
	cachedPlayerSlotNames[player.UserId][tostring(slot)] = slotName
	return postreturn
end

function SaveDataService.LoadCharacterSlot(player, slot, getSaveFromSlot, loadCharacter)
	print("Load", player, slot)
	if player.Character:FindFirstChildOfClass("Tool") then return false end
	local currentInformation = getSaveFromSlot(player.UserId, false, slot)
	warn("CURRENT INFORMATION FROM LOAD:", currentInformation)
	if currentInformation == false or currentInformation == nil then return false end
	warn("LOADED SLOT:", currentInformation)

	local returnTable = loadCharacter(player, currentInformation)
	return returnTable
end

function SaveDataService.RestoreAccessoryHistory(player, characterData, getMaxAccessoriesForPlayer, deepCopy, loadCharacter)
	print("RestoreAccessoryHistory", player)
	if player.Character:FindFirstChildOfClass("Tool") then return false end
	if typeof(characterData) ~= "table" or typeof(characterData.Accessories) ~= "table" then return false end

	if #characterData.Accessories > getMaxAccessoriesForPlayer(player) then return false end

	local slotData = {
		["SlotName"] = "UndoRedo",
		["Data"] = deepCopy(characterData)
	}

	return loadCharacter(player, slotData)
end

function SaveDataService.LoadLegacySlot(player, slot, getLegacySave, loadLegacyCharacterSlot)
	print("LoadLegacy", player, slot)
	local currentInformation = getLegacySave(player)

	print("CURRENT INFO", currentInformation)
	if currentInformation == false then return false end
	local specificSlot = currentInformation[slot]
	print("SPECIFIC SLOT", specificSlot)
	if specificSlot then
		local returnTable = loadLegacyCharacterSlot(player, slot, specificSlot)
		return returnTable
	else
		return false
	end
end

function SaveDataService.GetAllData(player, cachedPlayerSlotNames)
	repeat task.wait() until cachedPlayerSlotNames[player.UserId] ~= nil
	return cachedPlayerSlotNames[player.UserId]
end

function SaveDataService.GetAllLegacyDataForPlayer(player, cachedLegacyCharacterData)
	local data = cachedLegacyCharacterData[tostring(player.UserId)]
	if data then
		print("Giving player all legacy data.")
		return data
	else
		warn("No legacy data detected.")
		return false
	end
end

return SaveDataService
