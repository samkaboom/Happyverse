
print("Project Multiverse.lua has began running.")

local TEST_MODE = false

wait(1)

local JobId = game.JobId
local PlaceId = game.PlaceId

local RefreshDebounceTime = 10

local GroupId = 295131561

if game:GetService("RunService"):IsStudio() then TEST_MODE = true end

if TEST_MODE then JobId = math.random(1,999999) end

local TeleportService = game:GetService("TeleportService")



local DataStoreService = game:GetService("DataStoreService")
local MarketPlaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local OurPlaceName

repeat
	pcall(function()
		OurPlaceName = MarketPlaceService:GetProductInfo(PlaceId).Name
	end)
	wait(1)
until OurPlaceName

local GameList = DataStoreService:GetDataStore(tostring(game.GameId))
local CustomizationPlaceId = 88229153869269

local PlayerDesignationDataStore = DataStoreService:GetDataStore("PlayerDesignation")
local ServerOccupied = DataStoreService:GetDataStore("ServerOccupied")
local FollowsDatastore = DataStoreService:GetDataStore("Follows")

local MultiverseInvoke = game:GetService("ReplicatedStorage"):WaitForChild("Multiverse")

local MultiverseEvent = game:GetService("ReplicatedStorage"):WaitForChild("ServerListUpdate")

local ServerAccessCodes = DataStoreService:GetDataStore("ReservedServerAccessCodes")

script:WaitForChild("CustomLoadingScript").Parent = game:GetService("ReplicatedFirst")
script:WaitForChild("CustomLoadingScreen").Parent = ReplicatedStorage

local ServerTemplate = script:WaitForChild("ServerTemplate")
local JobTemplate = script:WaitForChild("JobTemplate")
local BufferTemplate = script:WaitForChild("BufferTemplate")

local FolderOfBuffers = Instance.new("Folder")
FolderOfBuffers.Name = "ServerBuffers"
FolderOfBuffers.Parent = ReplicatedStorage

local FolderOfServers = Instance.new("Folder")
FolderOfServers.Name = "Servers"
FolderOfServers.Parent = ReplicatedStorage

local BackupPlayerList = {}

local ServerBin = Instance.new("Folder");
ServerBin.Name = "ServerBin"
ServerBin.Parent = ReplicatedStorage

local accessCode = game.PrivateServerId ~= "" and ServerAccessCodes:GetAsync(game.PrivateServerId)

local Teleports = workspace:FindFirstChild("Teleporters")

local MasterKey = "GameServerCommunication"
local BackupKey = "GameServerCommunication2"



local AllowTeleports = false

local ServerEnded = false

local recentchange = false

local FollowsCache = {}

delay(15, function()
	AllowTeleports = true
end)

print("Access CODE:", accessCode)

if accessCode == false then accessCode = nil end

if game.PlaceId == CustomizationPlaceId then RefreshDebounceTime = 30 end

-- First time setup

local PlaceInformationTable = {
	
	[11150516719] = {
		["Name"] = "other place";
		["DisplayImage"] = "";
		["Description"] = "A garage hideout currently unowned."
	},
	
	[10866495325] = {
		["Name"] = "this place";
		["DisplayImage"] = "";
		["Description"] = "A garage hideout currently unowned."
	},

	[9307491959] = {
		["Name"] = "Garage Hideout";
		["DisplayImage"] = "rbxassetid://11273796440";
		["Description"] = "A garage hideout currently unowned."
	},
	
	[9824293183] = {
		["Name"] = "Customization";
		["DisplayImage"] = "rbxassetid://11273781442";
		["Description"] = "A private place for customization."
	},
	
	[3073983401] = {
		["Name"] = "The Lobby";
		["DisplayImage"] = "rbxassetid://11273781442";
		["Description"] = "The spawn lobby."
	},
	
	
	[9246533234] = {
		["Name"] = "The Limbs";
		["DisplayImage"] = "rbxassetid://11273781442";
		["Description"] = "The main map of the game."
	},
	
	[9238471058] = {
		["Name"] = "The Limbs";
		["DisplayImage"] = "rbxassetid://11273781442";
		["Description"] = "The main map of the game."
	},
	[9107000605] = {
		["Name"] = "The Sweat";
		["DisplayImage"] = "rbxassetid://11273783327";
		["Description"] = "A hardcore gym and fight club owned by Da Pack."
	},
	[9106992440] = {
		["Name"] = "The Warehouse";
		["DisplayImage"] = "rbxassetid://11273781007";
		["Description"] = "A warehouse currently owned by Terminal."
	},
	[9106989723] = {
		["Name"] = "T3XT";
		["DisplayImage"] = "rbxassetid://11273782350";
		["Description"] = "A library currently owned by The Men at Work."
	},
	[9106987178] = {
		["Name"] = "RAID ARCADE";
		["DisplayImage"] = "rbxassetid://11273789281";
		["Description"] = "An arcade currently owned by The Set."
	},
	[9106987348] = {
		["Name"] = "The Subway Station";
		["DisplayImage"] = "rbxassetid://11273790107";
		["Description"] = "A subway station currently owned by (nobody)."
	},
	[9107016943] = {
		["Name"] = "The Mall";
		["DisplayImage"] = "rbxassetid://11273790541";
		["Description"] = "A mall currently owned by The Chain."
	},
	[9106998966] = {
		["Name"] = "The Sky Nightclub";
		["DisplayImage"] = "rbxassetid://11273788964";
		["Description"] = "A nightclub currently owned by Renegade."
	},
	[9106982235] = {
		["Name"] = "LOFI";
		["DisplayImage"] = "rbxassetid://11273789695";
		["Description"] = "An apartment complex currently owned by Terminal."
	},
	[9106987413] = {
		["Name"] = "The High";
		["DisplayImage"] = "rbxassetid://11285689527";
		["Description"] = "An apartment complex currently owned by Sam Dripson."
	},
	[9106992581] = {
		["Name"] = "Ikku Tower";
		["DisplayImage"] = "rbxassetid://11273781442";
		["Description"] = "A corporate tower currently owned by Ikku."
	},
	[9106997203] = {
		["Name"] = "Solstice Casino";
		["DisplayImage"] = "rbxassetid://11273782860";
		["Description"] = "A casino currently owned by Terminal."
	},
	[9107011996] = {
		["Name"] = "Sectorate HQ";
		["DisplayImage"] = "rbxassetid://11273781442";
		["Description"] = "The base establishment for Sectorate operations."
	},
	[9106998792] = {
		["Name"] = "American Dragon";
		["DisplayImage"] = "rbxassetid://11273781442";
		["Description"] = "A japanese themed restaurant that is self-sufficient."
	},
	[9107010783] = {
		["Name"] = "Yakuza HQ";
		["DisplayImage"] = "rbxassetid://11273781442";
		["Description"] = "The headquarters for the Yakuza."
	},
	[9106975876] = {
		["Name"] = "Coffee and Tea";
		["DisplayImage"] = "rbxassetid://11273796826";
		["Description"] = "A cafe currently owned by Lifeline."
	},
	[9107007917] = {
		["Name"] = "The Hideout";
		["DisplayImage"] = "rbxassetid://11273781943";
		["Description"] = "A hideout and ripperdoc station owned by Chrome Calvary."
	},
	[9106975690] = {
		["Name"] = "The 1004";
		["DisplayImage"] = "rbxassetid://11273800175";
		["Description"] = "A japanese themed restaurant owned by Terminal."
	},
	[9106976069] = {
		["Name"] = "LEAD";
		["DisplayImage"] = "rbxassetid://11273796011";
		["Description"] = "A gun store currently owned by Ikku."
	},
	[9106987268] = {
		["Name"] = "Stages";
		["DisplayImage"] = "rbxassetid://11273788487";
		["Description"] = "A club currently owned by Skyline."
	},	
	
	[7775135605] = {
		["Name"] = "Halo 2";
		["DisplayImage"] = "rbxassetid://11273781442";
		["Description"] = "Test"
	},
	
	[8159111166]= {
		["Name"] = "R+D";
		["DisplayImage"] = "rbxassetid://11273781442";
		["Description"] = "research test place."
	},
	[11220296665]= {
		["Name"] = "R+D 2";
		["DisplayImage"] = "rbxassetid://11273781442";
		["Description"] = "research test place."
	},
}








local SavedTable = {
	["PlaceId"] = PlaceId,
	["JobId"] = JobId,
	["AccessCode"] = accessCode,
	["Name"] = game:GetService("MarketplaceService"):GetProductInfo(PlaceId).Name,
	["PlayerList"] = {},
	["Segments"] = {1,1},
	["Dead"] = false,
	["MaxPlayerCount"] = game.Players.MaxPlayers
}

local PlayerListBuilder = {}

local ReservedServerAccessCodes = {}

local PlayerTouchDebounceTable = {}

local GlobalTable = {}

local CachedPlayerFollowTable = {}

local CachedPlayerNames = {}

local LastReceivedPingTable = {}

local RefreshDeb = false


print("SavedTableStartup:", SavedTable)


local function DeleteJobIdBin(PlaceId, JobId)
	local Bin = FolderOfServers:FindFirstChild(tostring(PlaceId))
	if Bin then
		Bin = Bin.Container:FindFirstChild(JobId)
		if Bin then
			Bin:Destroy()
		end
	end
end


local function GetPlayerFromUserId(UserId)
	print("GET PLAYER FROM USER ID:", UserId)
	for i, v in pairs(game.Players:GetPlayers()) do
		if v.UserId == UserId then
			return v
		end
	end
	return nil
end

local function GetNameFromUserId(UserId)
	local succ, result = pcall(function()
		if not CachedPlayerNames[UserId] then
			CachedPlayerNames[UserId] = game.Players:GetNameFromUserIdAsync(UserId)
		end
		return CachedPlayerNames[UserId]
	end)
	
	if succ then return result else 
		
		local PossiblePlayer = GetPlayerFromUserId(UserId)
		if PossiblePlayer then
			CachedPlayerNames[UserId] = PossiblePlayer.Name
		else
			return " - "
		end
	end
	
	
	return CachedPlayerNames[UserId]
end

local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

local UseBackup = false
local CurrentStartPoint = nil
local CurrentEndPoint = nil

local function GeneratePlayerPOST(PostData)
	print("Generate player POST data", SavedTable)
	if ServerEnded == true then return end
	if PostData == false then return end
	local succ, result = pcall(function()
		
		
		
		if #SavedTable.PlayerList > 10 then
			local stop = false
			
			local startpoint = CurrentStartPoint or 1
			local endpoint = CurrentEndPoint or 10
			local loopamount = math.ceil((#SavedTable.PlayerList / 10))
			local loopcount = 0
			repeat
				print("Repeat loop", startpoint, endpoint)
				CurrentStartPoint = startpoint
				CurrentEndPoint = endpoint
				wait(RefreshDebounceTime/2)
				loopcount = loopcount + 1
				local tempTable = deepCopy(SavedTable)
				tempTable.Segments = {loopcount, loopamount}
				tempTable.PlayerList = {}
			
				for i = startpoint, endpoint, 1 do
					wait()
					
					if SavedTable.PlayerList[i] == nil then stop = true; print("Breaking update loop", i) break end
					
					table.insert(tempTable.PlayerList, SavedTable.PlayerList[i])
				end
				
				print("Posting", startpoint, endpoint, #tempTable.PlayerList, "Segments:", tempTable.Segments[1], tempTable.Segments[2])
				if UseBackup == false then MessagingService:PublishAsync(MasterKey, tempTable) else MessagingService:PublishAsync(BackupKey, tempTable) end
			
				if stop == false then
					startpoint = endpoint + 1
					endpoint = endpoint + 10
				end
			until stop == true
			print("Finished playerlist for loop")
			CurrentStartPoint = nil
			CurrentEndPoint = nil
		else
			print("POSTING")
			CurrentStartPoint = nil
			CurrentEndPoint = nil
			SavedTable.Segments = {1,1}
			BackupPlayerList = deepCopy(SavedTable.PlayerList)
			if UseBackup == false then MessagingService:PublishAsync(MasterKey, SavedTable) else MessagingService:PublishAsync(BackupKey, SavedTable) end
		end
		
		
		
			
		
		
	end)
	
	if not succ then warn(result); wait(RefreshDebounceTime); if UseBackup == false then UseBackup = true else UseBackup = false end else 
		
	end
end

local function RefreshServers()
	print("Refresh request. Deb:", RefreshDeb)
	if RefreshDeb == true then return end
	RefreshDeb = true
	local succ, result = pcall(function()



		print("Refreshing all servers. Global table:",  GlobalTable)

		if GlobalTable[PlaceId] == nil then GlobalTable[PlaceId] = {} end
		
		GlobalTable[PlaceId][JobId] = SavedTable

		for PlaceIdi, PlaceTable in pairs(GlobalTable) do
			local IDVal = PlaceIdi
			local Information = PlaceInformationTable[IDVal]
			
			local FoundFolder = FolderOfServers:FindFirstChild(tostring(IDVal))
			if not FoundFolder then
				if Information then
					warn("Creating new place bin")
					local Bin = ServerTemplate:Clone()
					Bin.PlaceId.Value = IDVal
					Bin.Name = tostring(IDVal)
					Bin.PlaceName.Value = Information.Name
					Bin.DisplayImage.Value = tostring(Information.DisplayImage)
					Bin.Description.Value = Information.Description
					Bin.Parent = FolderOfServers
				end
			else
				--print("Found folder")
			end

			local count = 0

			for JobIdi, ServerTable in pairs(PlaceTable) do
				count = count + 1
				
				if math.abs(tick() - LastReceivedPingTable[JobIdi]) < 300 then 
					print("Server refresh for loop,", ServerTable)

					local Bin = FolderOfServers:FindFirstChild(tostring(ServerTable.PlaceId))
					if Bin then
						--print("Found bin")
						local ActualBin = Bin.Container:FindFirstChild(ServerTable.JobId)
						if not ActualBin then
							print("Creating new job id bin")
							local Bin2 = JobTemplate:Clone()
							Bin2.Name = ServerTable.JobId
							Bin2.PlaceId.Value = ServerTable.PlaceId
							Bin2.JobId.Value = ServerTable.JobId
							Bin2.MaxPlayerCount.Value = ServerTable.MaxPlayerCount

							if ServerTable.AccessCode then Bin2.AccessCode.Value = ServerTable.AccessCode end
							Bin2.Parent = Bin.Container
							ActualBin = Bin2
						end




						for i, PlayerId in pairs(ServerTable.PlayerList) do
							local PlayerName


							--print("PLAYER FOR LOOP FOR", PlaceIdi, i, PlayerId)

							local FoundPlayerLog = ActualBin.Players:FindFirstChild(GetNameFromUserId(PlayerId))

							if not FoundPlayerLog then
								print("Creating player log", PlayerId)

								local PlayerLog = Instance.new("IntValue")
								PlayerLog.Name = GetNameFromUserId(PlayerId)
								PlayerLog.Value = PlayerId
								PlayerLog.Parent = ActualBin.Players

						--[[else
							print("Found player log", PlayerId.PlayerName)
							FoundPlayerLog.AllowsFollows.Value = PlayerId.AllowsFollows
							FoundPlayerLog.DisplayName.Value = PlayerId.DisplayName
							FoundPlayerLog.PlaceName.Value = PlayerId.PlaceName
							FoundPlayerLog.Role.Value = PlayerId.Role
							FoundPlayerLog.Rank.Value = PlayerId.Rank--]]
							end




						end

						for i, v in pairs(ActualBin.Players:GetChildren()) do
							local f = false
							for z, x in pairs(ServerTable.PlayerList) do
								if v.Value == x then
									f = true
									
								end
							end

							if f == false then
								print("Isnt in the list, destroying", v.Name)
								v:Destroy()
							end
						end


					else
						-- bin statement




					end

				else
					if PlaceIdi ~= PlaceId then
						print("NO SERVER:", ServerTable.Name, "Haven't had a response from this server in awhile. Removing. Job ID:", JobIdi)
						DeleteJobIdBin(PlaceIdi, JobIdi) 
						PlaceTable[JobIdi] = nil
					end

				end

				end
				
				
				
				
			
		end
		
		

	end)

	if not succ then warn(result); RefreshDeb = false return end
	--ListUpdateEvent:FireAllClients()
	RefreshDeb = false
end

local PerformedCustomizaitonSwitch = false

local module = {
	PhysicalTeleport = function(self, player, DestinationName)
		print("PLAYER:", player, "DESTINATION:", DestinationName)
		
		local DestinationBlock
		
		if ReplicatedStorage:FindFirstChild("TeleporterDestinations") then DestinationBlock = ReplicatedStorage:FindFirstChild("TeleporterDestinations"):FindFirstChild(DestinationName) end
		
		if not DestinationBlock then
			DestinationBlock = GetPlayerFromUserId(DestinationName)
			if DestinationBlock then
				
				local succ, result = pcall(function()
					
					local res = FollowsCache[DestinationBlock.UserId]
					if res == nil then
						res = FollowsDatastore:GetAsync(DestinationBlock.UserId)
						FollowsCache[player.UserId] = res
					end
					return res
				end)

				if succ then
					if result ~= nil then
						print("Tp request result for", DestinationBlock.Name, "result:", result)
						if result == false and player:GetRankInGroup(GroupId) < 250 then
							return false
						else
							player.Character.HumanoidRootPart.CFrame = DestinationBlock.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
							return true
						end
					else
						return false
					end
				else
					return false
				end
				
				
			end
		else
			player.Character.HumanoidRootPart.CFrame = DestinationBlock.CFrame
		end
		return true
	end,
	SetFollowPreference = function(self, player, preference)
		FollowsCache[player.UserId] = preference
		local succ, result = pcall(function()
			FollowsDatastore:SetAsync(player.UserId, preference)
		end)
		
		if succ then
			return true
		else 
			return false
		end
	end,
	GetFollowPreference = function(self, player)
		
		if FollowsCache[player.UserId] == nil then
			
			local succ, result = pcall(function()
				return FollowsDatastore:GetAsync(player.UserId)
			end)	
			if succ then return result else return false end
			
		else return FollowsCache[player.UserId] end
		
	end,
	JoinServer = function(self, Player, JoinPlaceId, JoinJobId, JoinAccessCode, Destination, CurrentSlot, FollowingPlayerUserId)
		print("Join request from", Player, "ID:", JoinPlaceId)
		
		if FollowingPlayerUserId then
			print("They're trying to join a player via the leaderboard.")
			local succ, result = pcall(function()
				return FollowsDatastore:GetAsync(FollowingPlayerUserId)
			end)
			
			if succ then
				if result ~= nil then
					if result == false and JoinPlaceId == CustomizationPlaceId then return false end
					if result == false then
						if Player:GetRankInGroup(GroupId) < 250 and Player.UserId ~= 71816461 then print(FollowingPlayerUserId, "has their following turned off.") return false end
					end
				end
			end
		end
		
		
		local teleportOptions = Instance.new("TeleportOptions")
		
		
		local TeleportData = {}

		if Destination then
			TeleportData.Destination = Destination
		end
		if CurrentSlot then
			TeleportData.CurrentSlot = CurrentSlot
		end
		TeleportData.FromPlace = PlaceId

		teleportOptions:SetTeleportData(TeleportData)
		
		if JoinAccessCode ~= nil and JoinAccessCode ~= false then
			teleportOptions.ReservedServerAccessCode = JoinAccessCode
		elseif JoinJobId then
			teleportOptions.ServerInstanceId = JoinJobId
		end
		
		local TeleportAsyncResults = TeleportService:TeleportAsync(JoinPlaceId, {Player}, teleportOptions)
		return TeleportAsyncResults
	end,
	
	JoinNewServer = function(self, Player, JoinPlaceId, Destination, CurrentSlot)
		
		if JoinPlaceId ~= CustomizationPlaceId then
		if AllowTeleports == false then return "AllowServerToGather" end
		if FolderOfBuffers:FindFirstChild(tostring(JoinPlaceId)) then
			
			return "WaitForNew"
			
		elseif #FolderOfServers:FindFirstChild(tostring(JoinPlaceId)).Container:GetChildren() > 0 then
			return "ClickOne"
		
		end
		end
		
		
		local teleportOptions = Instance.new("TeleportOptions")
		
		teleportOptions.ShouldReserveServer = true

		local TeleportData = {}
		
		if Destination then
			TeleportData.Destination = Destination
		end
		if CurrentSlot then
			TeleportData.CurrentSlot = CurrentSlot
		end
		TeleportData.FromPlace = PlaceId

		teleportOptions:SetTeleportData(TeleportData)
		
		local NewVal = Instance.new("IntValue"); NewVal.Name = tostring(JoinPlaceId); NewVal.Parent = FolderOfBuffers
		MessagingService:PublishAsync("ServerBuffer", {["ID"] = JoinPlaceId, ["Value"] = true})

		local TeleportResult = TeleportService:TeleportAsync(JoinPlaceId, {Player}, teleportOptions)
		print("Saved code for new reserved server.")
		ServerAccessCodes:SetAsync(TeleportResult.PrivateServerId, TeleportResult.ReservedServerAccessCode)
		Player.AncestryChanged:Wait()
		FolderOfServers:FindFirstChild(tostring(JoinPlaceId)).Container.ChildAdded:Wait()
		if NewVal then NewVal:Destroy() end
		
		
	end,
	
	CustomizationSwitch = function(self, player, FromPlaceId)
		warn("Last place identifier sent", player, FromPlaceId)
		if PlaceId == CustomizationPlaceId then
			if FromPlaceId == 3073983401 then FromPlaceId = 9238471058 end -- stops them from joining the lobby
			if PerformedCustomizaitonSwitch == false then
				PerformedCustomizaitonSwitch = true
				warn("Performed customization switch.")
				workspace.Teleporters:GetChildren()[1].ID.Value = FromPlaceId
			end
			
		end
	end,
	
	MessagingService:SubscribeAsync("ServerBuffer", function(message)
		message = message.Data
		print("RECEIVED MESSAGE TO DELETE SERVER BUFFER", message.ID, message.Value)
		local Folder = FolderOfBuffers:FindFirstChild(tostring(message.ID))
		
		if message.Value == false then
			if Folder then
				Folder:Destroy()
			end
		else
			if not Folder then
				local NewVal = Instance.new("IntValue"); NewVal.Name = tostring(message.ID); NewVal.Parent = FolderOfBuffers
			end
		end
			
			
		
	end)
}

local Counter = Instance.new("IntValue")
Counter.Name = "RefreshTimer"
Counter.Parent = game:GetService("ReplicatedStorage")

local ListUpdateEvent = Instance.new("RemoteEvent")
ListUpdateEvent.Name = "ListUpdateEvent"
ListUpdateEvent.Parent = ReplicatedStorage









do
	
	
	
	
	
	
	if Teleports then
		
		local function BuildPlayerList(Data)
			if Data.PlaceId == PlaceId then return end
			local SelectedPlaceId = Data.PlaceId
			local SelectedJobId = Data.JobId
			local SegmentCurrent = Data.Segments[1]
			local SegmentMax = Data.Segments[2]
			warn("Received message to build player list from:", Data.Name, "Segments:", SegmentCurrent, SegmentMax)
			if PlayerListBuilder[SelectedPlaceId] == nil then PlayerListBuilder[SelectedPlaceId] = {} end
			if PlayerListBuilder[SelectedPlaceId][SelectedJobId] == nil then PlayerListBuilder[SelectedPlaceId][SelectedJobId] = {} end
			
		
			
			if SegmentCurrent == SegmentMax then
				-- This is the last addition
				warn("This is the last segment. Current amount:", #PlayerListBuilder[SelectedPlaceId][SelectedJobId], Data.Name)
				for i, v in pairs(Data.PlayerList) do
					table.insert(PlayerListBuilder[SelectedPlaceId][SelectedJobId], v)
				end
				
				warn("Second check after adding", #PlayerListBuilder[SelectedPlaceId][SelectedJobId])
				
				Data.PlayerList = deepCopy(PlayerListBuilder[SelectedPlaceId][SelectedJobId])
				GlobalTable[SelectedPlaceId][SelectedJobId] = Data
				table.clear(PlayerListBuilder[SelectedPlaceId][SelectedJobId])
				
			else
				-- It isn't finished, just add
				for i, v in pairs(Data.PlayerList) do
					table.insert(PlayerListBuilder[SelectedPlaceId][SelectedJobId], v)
				end
			end
			
		end
		
		local function ServerMessageReceive(message)
			print("New ping from other server.", message.Data.Name, message.Data.JobId, message.Data)
			local Data = message.Data
			local SelectedPlaceId = Data.PlaceId
			if GlobalTable[SelectedPlaceId] == nil then GlobalTable[SelectedPlaceId] = {} end
			if message.Data.Dead == true then  print("Dead server. Deleting. Job ID:", message.Data.JobId); DeleteJobIdBin(message.Data.PlaceId, message.Data.JobId) GlobalTable[SelectedPlaceId][message.Data.JobId] = nil return end 
			
			
				if Data.Segments[1] == 1 and Data.Segments[2] == 1 then
					GlobalTable[SelectedPlaceId][message.Data.JobId] = message.Data
				else
					BuildPlayerList(Data)
				end
			
			LastReceivedPingTable[message.Data.JobId] = tick()
			RefreshServers()
		end
		
		MessagingService:SubscribeAsync(MasterKey, ServerMessageReceive)
		
		MessagingService:SubscribeAsync(BackupKey, ServerMessageReceive)
		
		
		
		
		spawn(function()
			
			MessagingService:PublishAsync("ServerBuffer", {["ID"] = PlaceId, ["Value"] = false})
			
			GeneratePlayerPOST(true)
			
			while true do
				local success, report = pcall(function()
					repeat wait(1); print("tick") Counter.Value = Counter.Value + 1
					until Counter.Value >= RefreshDebounceTime
					Counter.Value = 0
					if not SavedTable then
						SavedTable = {
							["PlaceId"] = PlaceId,
							["JobId"] = JobId,
							["AccessCode"] = accessCode,
							["Name"] = OurPlaceName,
							["PlayerList"] = deepCopy(BackupPlayerList),
							["Segments"] = {1,1},
							["Dead"] = false,
							["MaxPlayerCount"] = game.Players.MaxPlayers
						}
					end
					GeneratePlayerPOST(true)
				end)
				
				if not success then warn(report) wait(RefreshDebounceTime) end
			end		
		end)
		
		game.Players.PlayerRemoving:Connect(function(player)
			warn("PLAYER REMOVING", player)
			for i, v in pairs(SavedTable.PlayerList) do
				if player.UserId == v then
					table.remove(SavedTable.PlayerList, i)
				end
			end	

			RefreshServers()
			
			pcall(function()
				FollowsDatastore:SetAsync(player.UserId, FollowsCache[player.UserId])
			end)
			FollowsCache[player.UserId] = nil
		end)

		game.Players.PlayerAdded:Connect(function(player)
			
			warn("Inserting new player into PlayerList table", player)
			
			local succ, result = pcall(function()
				return FollowsDatastore:GetAsync(player.UserId)
			end)

			if succ then
				if result == nil then
					FollowsCache[player.UserId] = true
				else
					FollowsCache[player.UserId] = result
				end
			else
				FollowsCache[player.UserId] = true
			end

			local T_Insert = player.UserId 
			local found = false
			for i, v in pairs(SavedTable.PlayerList) do
				if v == player.UserId then
					found = true
					break
				end
			end
			if found == false then
				table.insert(SavedTable.PlayerList, T_Insert)
				recentchange = true
			end

			RefreshServers()
			
		end)
		
		do
			warn("Gathering players for initial list")
			table.clear(SavedTable.PlayerList)

			for i, player in pairs(game.Players:GetChildren()) do
				warn("Found", player.Name, "for initial list.")
				table.insert(SavedTable.PlayerList, player.UserId)
			end

			RefreshServers()
		end
		
		spawn(function()
			
		
		if game.PlaceId == CustomizationPlaceId then repeat wait() until PerformedCustomizaitonSwitch == true end
		for i, v in pairs(Teleports:GetChildren()) do
			local IDVal = v:FindFirstChild("ID")
			if IDVal then
				if not FolderOfServers:FindFirstChild(tostring(IDVal.Value)) then
					local Information = PlaceInformationTable[IDVal.Value]
					if Information then
						local newServerFolder = ServerTemplate:Clone()
						newServerFolder.PlaceId.Value = IDVal.Value
						newServerFolder.Name = tostring(IDVal.Value)
						newServerFolder.PlaceName.Value = Information.Name
						newServerFolder.Description.Value = Information.Description
						newServerFolder.DisplayImage.Value = Information.DisplayImage
						newServerFolder.Parent = FolderOfServers
					end
				end
			end
		end
		end)
		
		
		
	end
	

	
	
	
	


	
end

do
	local PhysicalTeleports = workspace:FindFirstChild("PhysicalTeleports") or workspace:FindFirstChild("PhysicalTeleporters")
	if PhysicalTeleports then
		for i, v in pairs(PhysicalTeleports:GetChildren()) do
			local ProximityPrompt = Instance.new("ProximityPrompt", v)
			ProximityPrompt.HoldDuration = 0.5
			ProximityPrompt.ActionText = "Teleport to " .. v.Name
			ProximityPrompt.Triggered:Connect(function(player)
				player.Character.HumanoidRootPart.CFrame = CFrame.new(v.Destination.Value.X, v.Destination.Value.Y, v.Destination.Value.Z)
			end)
			
		end
		
		
	end
	
	
end

-- cross-server gm's

do
	
	local canMessagedeb = false
	game.Players.PlayerAdded:Connect(function(player)
		if player:GetRankInGroup(2962831) >= 249 then
			player.Chatted:Connect(function(message)
				if message:sub(1,4) == ":gm " then
					if canMessagedeb == true then return end
					canMessagedeb = true
					local InputtedText = message:sub(4, #message)
				
					local Result = TextService:FilterStringAsync(InputtedText, player.UserId, Enum.TextFilterContext.PublicChat)
					if Result then
						local RealText = Result:GetChatForUserAsync(player.UserId)
						MessagingService:PublishAsync("Admin", {["Sender"] = player.Name, ["Message"] = RealText})
						
					end
					wait(15)
					canMessagedeb = false
				end
			end)
		end
	end)
	
	MessagingService:SubscribeAsync("Admin", function(message)
		message = message.Data
		local sender = message.Sender
		local message = message.Message
		for i, v in pairs(game.Players:GetChildren()) do
			local c = script["Global Message"]:Clone()
			c.Fade.message.Text = message
			c.Fade.sender.Text = sender
			c.Parent = v.PlayerGui
			c.Script.Disabled = false
			
		end
	end)
end






game:BindToClose(function()
	-- Server is empty and is going to die
	print("Performing 'dead server' protocol.")
	SavedTable["Dead"] = true
	ServerEnded = true
	local success, result = pcall(function()
		ServerOccupied:SetAsync(PlaceId, false)
	end)
	local function EndServer()
		local succ, msg = pcall(function()
			if UseBackup == false then MessagingService:PublishAsync(MasterKey, SavedTable) else MessagingService:PublishAsync(BackupKey, SavedTable) end
		end)
		if not succ then warn(msg); wait(RefreshDebounceTime/2); if UseBackup == true then UseBackup = false else UseBackup = true end EndServer() end
		
	end
	
	EndServer()
	
	print("It's getting dark. Goodbye.")
end)




		


return module
