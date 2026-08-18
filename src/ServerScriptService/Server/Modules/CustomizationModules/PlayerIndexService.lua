local PlayerIndexService = {}

function PlayerIndexService.IndexPlayer(player, customization, cachedCharacterData, cachedPlayerSlotNames, cachedLegacyCharacterData, dependencies)
	if customization[player.Name] == player and cachedCharacterData[tostring(player.UserId)] ~= nil and cachedPlayerSlotNames[player.UserId] ~= nil then warn("ALREADY HAS SOMEHOW") return end
	print("Loading character information for new player:", player)
	customization[player.Name] = player
	cachedCharacterData[tostring(player.UserId)] = {}
	local bigtable = {}
	local slots = dependencies.Constants.BaseSaveSlots
	local saveSlots1, saveSlots2, saveSlots3 = dependencies.MarketplaceService:UserOwnsGamePassAsync(player.UserId, 21918073), dependencies.MarketplaceService:UserOwnsGamePassAsync(player.UserId, 53597806), dependencies.MarketplaceService:UserOwnsGamePassAsync(player.UserId, 144388696)
	if saveSlots1 then
		slots = math.clamp(slots * 2, slots, dependencies.Constants.SpecialMaxSaveSlots)
	end
	if saveSlots2 then
		slots = math.clamp(slots * 2, slots, dependencies.Constants.SpecialMaxSaveSlots)
	end
	if saveSlots3 then
		slots = math.clamp(slots * 2, slots, dependencies.Constants.SpecialMaxSaveSlots)
	end
	if dependencies.vipwhitelist[player.UserId] or dependencies.GroupVerif.CheckRank(player, "Gamemaster") or dependencies.RunService:IsStudio() then
		slots = dependencies.Constants.SpecialMaxSaveSlots
	end

	local success, res = pcall(function()
		return dependencies.SlotNameDS:GetAsync(player.UserId)
	end)
	if success then
		if res == nil then
			warn("Player is not using the more efficient PlayerSlotName Datastore. Converting now.")
			for i = 1, slots do
				local returnedTable = dependencies.GetSaveFromSlot(player.UserId, true, i)
				if returnedTable ~= nil then
					bigtable[tostring(i)] = nil
				end
				bigtable[tostring(i)] = returnedTable
				wait()
			end
			local newTable = {}
			for i, value in pairs(bigtable) do
				newTable[i] = value.SlotName
			end
			wait(2)
			local success, res = pcall(function()
				dependencies.SlotNameDS:SetAsync(player.UserId, newTable)
			end)
			cachedPlayerSlotNames[player.UserId] = newTable
		else
			warn("Player is using the PlayerSlotName Datastore. Updating cache.")
			cachedPlayerSlotNames[player.UserId] = res
		end
	else
		warn("Data stores are down!")
		local gui = dependencies.DatastoresDownGui:Clone()
		gui.Parent = player.PlayerGui
	end

	local returnedLegacySave = dependencies.GetAllLegacyData(player)
	if returnedLegacySave then
		print(player, " has legacy data")
		cachedLegacyCharacterData[tostring(player.UserId)] = returnedLegacySave
	end

	player.CharacterAdded:Connect(function(character)
		task.wait(0.3)
		warn("CUSTOMIZATON : ", "CHARACTER ADDED", player.Name)
		dependencies.NormalizeCharacterAccessories(character)
	end)

	local function executeRegardless()
		task.wait(0.3)
		warn("CUSTOMIZATON : ", "EXECUTE REG.", player.Name)
		dependencies.NormalizeCharacterAccessories(player.Character)
	end

	repeat task.wait() until player.Character
	executeRegardless()
end

function PlayerIndexService.RemovePlayer(player, customization, cachedCharacterData, cachedLegacyCharacterData, cachedPlayerSlotNames, slotNameDS)
	customization[player.Name] = false
	customization[player.Name] = nil
	cachedCharacterData[tostring(player.UserId)] = nil
	cachedLegacyCharacterData[player.UserId] = nil
	slotNameDS:SetAsync(player.UserId, cachedPlayerSlotNames[player.UserId])
	cachedPlayerSlotNames[player.UserId] = nil
end

return PlayerIndexService
