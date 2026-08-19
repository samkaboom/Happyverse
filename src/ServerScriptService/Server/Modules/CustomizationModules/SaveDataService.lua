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

return SaveDataService
