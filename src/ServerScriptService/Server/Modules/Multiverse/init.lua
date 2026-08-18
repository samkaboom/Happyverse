
print("Project Multiverse.lua has began running.")

local TEST_MODE = false

wait(6)

local JobId = game.JobId
local PlaceId = game.PlaceId
local PrivateServerId = game.PrivateServerId

_G.RefreshDebounceTime = 20
local AddedWait = 0

local GroupId = 295131561

if game:GetService("RunService"):IsStudio() then TEST_MODE = true end

if TEST_MODE then JobId = math.random(1,999999) end

local TeleportService = game:GetService("TeleportService")

local GroupVerification = require(script.Parent.GroupVerification)



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
local MainLobbyPlaceId = 88229153869269

local PlayerDesignationDataStore = DataStoreService:GetDataStore("PlayerDesignation")
local ServerOccupied = DataStoreService:GetDataStore("ServerOccupied")
local FollowsDatastore = DataStoreService:GetDataStore("Follows")
local LastFilterModeDS = DataStoreService:GetDataStore("FilterMode")
local FilterCache = {}

local MultiverseInvoke = game:GetService("ReplicatedStorage"):WaitForChild("Multiverse")

local MultiverseEvent = game:GetService("ReplicatedStorage"):WaitForChild("ServerListUpdate")

local ServerAccessCodes = DataStoreService:GetDataStore("SuperReservedServerAccessCodes")

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
warn("PRIVATE SERVER ID:", game.PrivateServerId)
local incomingdata = nil
if game.PrivateServerId ~= "" and game.PrivateServerId ~= nil then
	incomingdata = ServerAccessCodes:GetAsync(game.PrivateServerId)
end
warn("INCOMING DATA", incomingdata)
local OurServerType, accessCode = nil, nil
if incomingdata then
	incomingdata = HttpService:JSONDecode(incomingdata)
	warn("ACCESS CODE:", incomingdata[1], "TYPE", incomingdata[2])
	accessCode = incomingdata[1]
	OurServerType = incomingdata[2]
end
warn("OUR SERVER TYPE", OurServerType)

local ServerTypeValForClients = Instance.new("StringValue", ReplicatedStorage)
ServerTypeValForClients.Name = "ServerType"
ServerTypeValForClients.Value = if not OurServerType then "Freeform" else OurServerType

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

if game.PlaceId == CustomizationPlaceId then _G.RefreshDebounceTime = 60 end

local ChattedMessages = ""

-- First time setup

local PlaceInformationTable = {
	[16022954380]= {
		["Name"] = "The Shallows";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[76800883465932]= {
		["Name"] = "Harmonic Vault";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[133726169233993]= {
		["Name"] = "Obsidian Shrine";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[70549089948008]= {
		["Name"] = "The Witherholt";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[14450222064]= {
		["Name"] = "Castellan Ward";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[16820101062]= {
		["Name"] = "Blacksmoke";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[16737334026]= {
		["Name"] = "Watcher's Row";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[127880360332494]= {
		["Name"] = "Library of Alabastra";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[120313151037448]= {
		["Name"] = "The Mindwraith";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[123482208262598]= {
		["Name"] = "Core of Creation";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[119803004897276]= {
		["Name"] = "Yellow Abbey";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[112332753872711]= {
		["Name"] = "Sunken Moth";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[84063695355472]= {
		["Name"] = "Fort Dawn";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[90763476777088]= {
		["Name"] = "In-Between";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[96473183100769]= {
		["Name"] = "Ashen Crucible";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[79292773154512]= {
		["Name"] = "Orkney Rising";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[108910128947424]= {
		["Name"] = "New Messina";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[107129351430752]= {
		["Name"] = "Hall of Jubilation";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[104785274421883]= {
		["Name"] = "Stillwater Apartments";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[109702489786758]= {
		["Name"] = "Marbrick Forest";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[133750941421087]= {
		["Name"] = "Blackstone Mineshaft";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[95468475320806]= {
		["Name"] = "Lin Jun City";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[78022774582045]= {
		["Name"] = "The Brewed Awakening";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[78022774582045]= {
		["Name"] = "St. Jiang Lian's Cathedral";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[134062149028327]= {
		["Name"] = "Lin Jun Residential";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[108983354484264]= {
		["Name"] = "Sunspire Library";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[133916187791199]= {
		["Name"] = "Tian Di Palace";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[96013919143783]= {
		["Name"] = "Veiled Emporium";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[131426189085289]= {
		["Name"] = "The Airship";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[82970261751299]= {
		["Name"] = "The Train";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[124344702839053]= {
		["Name"] = "Rotstone";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[132298553099601]= {
		["Name"] = "BSNFLK Bop";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[73687410995256]= {
		["Name"] = "Howling Wolf";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[119440617660843]= {
		["Name"] = "Council Hall";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[123996615578683]= {
		["Name"] = "St. Althea's Cathedral";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[18698171098]= {
		["Name"] = "The Gala";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[117944198445997]= {
		["Name"] = "Dawn";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[16335093772] = {
		["Name"] = "Event Areas";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[13501188035] = {
		["Name"] = "Coding Studio 1";
		["DisplayImage"] = 0;
		["Description"] = "A coding studio"
	},
	[12822869744] = {
		["Name"] = "Lobby";
		["DisplayImage"] = 0;
		["Description"] = "Main"
	},
	[13516290197] = {
		["Name"] = "Messina";
		["DisplayImage"] = 14573892892;
		["Description"] = "Main"
	},
	[13516289815] = {
		["Name"] = "Customization Room";
		["DisplayImage"] = 0;
		["Description"] = "Main"
	},
	[15889165808] = {
		["Name"] = "Saint Adram";
		["DisplayImage"] = 0;
		["Description"] = ""
	},
	[13546912069] = {
		["Name"] = "Vale of Cinder";
		["DisplayImage"] = 0;
		["Description"] = "The Deadlands";
	},
	[14536242217] = {
		["Name"] = "Basinfolk";
		["DisplayImage"] = 0;
		["Description"] = "The Deadlands";
	};
	[14573368083] = { --1
		["Name"] = "Home";
		["DisplayImage"] = 14573868359;
		["Description"] = "A home within Archelm";
	};
	[14573425543] = { --2
		["Name"] = "Home";
		["DisplayImage"] = 14573868105;
		["Description"] = "A home within Archelm";
	};
	[14573462989] = { --3
		["Name"] = "Home";
		["DisplayImage"] = 14573867906;
		["Description"] = "A home within Archelm";
	};
	[14573490722] = { --4
		["Name"] = "Home";
		["DisplayImage"] = 14573867636;
		["Description"] = "A home within Archelm";
	};
	[14573503670] = { --5
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Archelm";
	};
	[14583861075] = { --6
		["Name"] = "Home";
		["DisplayImage"] = 14573868359;
		["Description"] = "A home within Archelm";
	};
	[14583890154] = { --7
		["Name"] = "Home";
		["DisplayImage"] = 14573868105;
		["Description"] = "A home within Archelm";
	};
	[14583911927] = { --8
		["Name"] = "Home";
		["DisplayImage"] = 14573867636;
		["Description"] = "A home within Archelm";
	};
	[14583966895] = { --9
		["Name"] = "Home";
		["DisplayImage"] = 14573867906;
		["Description"] = "A home within Archelm";
	};
	[14584009099] = { --10
		["Name"] = "Throne Room";
		["DisplayImage"] = 14573868359;
		["Description"] = "A home within Archelm";
	};
	[14584029109] = { --11
		["Name"] = "The Manor";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home for Archelm's Elite";
	};
	[14584076184] = { --12
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Archelm";
	};
	[14584095821] = { --13
		["Name"] = "Station Orion";
		["DisplayImage"] = 14573868105;
		["Description"] = "The Center of Transportation";
	};
	[14584128094] = { --14
		["Name"] = "Home";
		["DisplayImage"] = 14573868359;
		["Description"] = "A home within Archelm";
	};
	[14584162291] = { --15
		["Name"] = "Home";
		["DisplayImage"] = 14573868105;
		["Description"] = "A home within Archelm";
	};
	[14584196339] = { --16
		["Name"] = "Home";
		["DisplayImage"] = 14573867906;
		["Description"] = "A home within Archelm";
	};
	[14584246178] = { --17
		["Name"] = "Home";
		["DisplayImage"] = 14573867906;
		["Description"] = "A home within Archelm";
	};
	[14584293320] = { --18
		["Name"] = "Home";
		["DisplayImage"] = 14573868105;
		["Description"] = "A home within Archelm";
	};
	[14584335800] = { --19
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Archelm";
	};
	[14584367280] = { --20
		["Name"] = "Home";
		["DisplayImage"] = 14573868359;
		["Description"] = "A home within Archelm";
	};
	[14584437001] = { --21
		["Name"] = "Home";
		["DisplayImage"] = 14573867636;
		["Description"] = "A home within Archelm";
	};
	[14584470521] = { --22
		["Name"] = "Home";
		["DisplayImage"] = 14573868105;
		["Description"] = "A home within Archelm";
	};
	[14584502091] = { --23
		["Name"] = "Home";
		["DisplayImage"] = 14573867906;
		["Description"] = "A home within Archelm";
	};
	[14584533229] = { --24
		["Name"] = "Home";
		["DisplayImage"] = 14573867906;
		["Description"] = "A home within Archelm";
	};
	[14584567998] = { --25
		["Name"] = "Home";
		["DisplayImage"] = 14573868359;
		["Description"] = "A home within Archelm";
	};
	[14584653101] = { --26
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Archelm";
	};
	[14584692185] = { --27
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Archelm";
	};
	[14584720219] = { --28
		["Name"] = "Home";
		["DisplayImage"] = 14573868105;
		["Description"] = "A home within Archelm";
	};
	[14584756869] = { --29
		["Name"] = "Home";
		["DisplayImage"] = 14573867906;
		["Description"] = "A home within Archelm";
	};
	[14584794863] = { --30
		["Name"] = "Home";
		["DisplayImage"] = 14573867636;
		["Description"] = "A home within Archelm";
	};
	[14585015793] = { --31
		["Name"] = "Home";
		["DisplayImage"] = 14573868359;
		["Description"] = "A home within Archelm";
	};
	[14585034285] = { --32
		["Name"] = "Home";
		["DisplayImage"] = 14573868359;
		["Description"] = "A home within Archelm";
	};
	[14585058641] = { --33
		["Name"] = "Home";
		["DisplayImage"] = 14573868105;
		["Description"] = "A home within Archelm";
	};
	[14585085882] = { --34
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Archelm";
	};
	[14585174588] = { --35
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Archelm";
	};
	-- basinfolk interiors
	[14652247271]  = { --36
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Basinfolk";
	};
	[14652287644] = { --37
		["Name"] = "Home";
		["DisplayImage"] = 14573868105;
		["Description"] = "A home within Basinfolk";
	};
	[14652319048] = { --38
		["Name"] = "Home";
		["DisplayImage"] = 14573867471;
		["Description"] = "A home within Basinfolk";
	};
	[14621341731] = { -- The Inn
		["Name"] = "The Inn";
		["DisplayImage"] = 14621771536;
		["Description"] = "A tavern within Archelm";
	};
	[15090002937] = { -- the academy
		["Name"] = "The Academy";
		["DisplayImage"] = 0;
		["Description"] = "";
	};
	[14549103090] = { -- the bank
		["Name"] = "The Bank";
		["DisplayImage"] = 0;
		["Description"] = "";
	};
	[15381264997] = { -- The Underhelm
		["Name"] = "The Underhelm";
		["DisplayImage"] = 0;
		["Description"] = "";
	};
	[14649892844] = { -- The Courthouse
		["Name"] = "The Courthouse";
		["DisplayImage"] = 15382255209;
		["Description"] = "";
	};
	[15432964046] = { -- The Courthouse
		["Name"] = "Sunscorched Arena";
		["DisplayImage"] = 0;
		["Description"] = "";
	};
	[95468475320806] = { -- The Courthouse
		["Name"] = "Lin Jun City";
		["DisplayImage"] = 76573068304304;
		["Description"] = "";
	};
	[86995293172733] = { -- The Courthouse
		["Name"] = "Blacksmoke";
		["DisplayImage"] = 135421909815035;
		["Description"] = "";
	};
	[134062149028327] = { -- The Courthouse
		["Name"] = "Lin Jun Residential";
		["DisplayImage"] = 98994388555426;
		["Description"] = "";
	};
	[78022774582045] = { -- The Courthouse
		["Name"] = "The Brewed Awakening";
		["DisplayImage"] = 102408416153595;
		["Description"] = "";
	};
	[87639394171191] = { -- The Courthouse
		["Name"] = "The Cathedral";
		["DisplayImage"] = 84024762759817;
		["Description"] = "";
	};
	[108983354484264] = { -- The Courthouse
		["Name"] = "The Church of Hope";
		["DisplayImage"] = 0;
		["Description"] = "";
	};
	[133916187791199] = { -- The Courthouse
		["Name"] = "The Palace";
		["DisplayImage"] = 0;
		["Description"] = "";
	};
	[96013919143783] = { -- The Courthouse
		["Name"] = "The Sewers";
		["DisplayImage"] = 0;
		["Description"] = "";
	};
	[82970261751299] = { -- The Courthouse
		["Name"] = "The Train";
		["DisplayImage"] = 0;
		["Description"] = "";
	};
	[94153612486163] = { -- Deep Marbrick
		["Name"] = "Archway Grotto (Marbrick)";
		["DisplayImage"] = 0;
		["Description"] = "";
	};
}

local SavedTable = {
	["PlaceId"] = PlaceId,
	["JobId"] = JobId,
	["AccessCode"] = accessCode,
	["Name"] = game:GetService("MarketplaceService"):GetProductInfo(PlaceId).Name,
	["PlayerCount"] = #game.Players:GetChildren(),
	["DataStoreId"] = JobId,
	["ServerType"] = OurServerType or "Freeform",
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


local function PackPlayers()
	local t = {}
	for i, v in pairs(game.Players:GetChildren()) do
		if v:IsA("Player") then
			table.insert(t, v.UserId)
		end
	end
	return t
end


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
local loopcount = 0

local function GeneratePlayerPOST(PostData)
	print("Generate player POST data", SavedTable)
	if ServerEnded == true then return end
	if PostData == false then return end

	local succ, result = pcall(function()

			print("POSTING")
			PlayerDesignationDataStore:SetAsync(JobId, PackPlayers())
		
			task.wait(AddedWait)
			if UseBackup == false then MessagingService:PublishAsync(MasterKey, SavedTable) else MessagingService:PublishAsync(BackupKey, SavedTable) end
	end)
	
	if not succ then
		AddedWait = tonumber(result:match("%d+")) + 4
		print("ERR with POSTING, new wait time:", AddedWait) warn(result); loopcount -= 1; wait(_G.RefreshDebounceTime); 
		if UseBackup == false then UseBackup = true else UseBackup = false end 
		
	else 
		loopcount = 0
		CurrentStartPoint = nil
		CurrentEndPoint = nil
	end
end

local function RefreshServers()
	print("Refresh request. Deb:", RefreshDeb)
	if RefreshDeb == true then return end
	RefreshDeb = true
	local succ, result = pcall(function()



		print("Refreshing all servers. Global table:",  GlobalTable)

		if GlobalTable[PlaceId] == nil then GlobalTable[PlaceId] = {} end
		local tempList = PackPlayers()
		local tempTable = deepCopy(SavedTable)
		tempTable.PlayerList = tempList
		GlobalTable[PlaceId][JobId] = tempTable

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
				if LastReceivedPingTable[JobIdi] == nil then LastReceivedPingTable[JobIdi] = tick() end
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
							Bin2.ServerType.Value = ServerTable.ServerType or "Canonical"
							Bin2.PlayerCount.Value = ServerTable.PlayerCount

							if ServerTable.AccessCode then Bin2.AccessCode.Value = ServerTable.AccessCode end
							Bin2.Parent = Bin.Container
							ActualBin = Bin2
						end

						ActualBin.Name = ServerTable.JobId
						ActualBin.PlaceId.Value = ServerTable.PlaceId
						ActualBin.JobId.Value = ServerTable.JobId
						ActualBin.MaxPlayerCount.Value = ServerTable.MaxPlayerCount
						ActualBin.ServerType.Value = ServerTable.ServerType or "Canonical"
						ActualBin.PlayerCount.Value = ServerTable.PlayerCount
						
						if ServerTable.AccessCode then ActualBin.AccessCode.Value = ServerTable.AccessCode end


						for i, PlayerId in pairs(ServerTable.PlayerList) do
							local PlayerName
							local FoundPlayerLog = ActualBin.Players:FindFirstChild(GetNameFromUserId(PlayerId))

							if not FoundPlayerLog then
								print("Creating player log", PlayerId)

								local PlayerLog = Instance.new("IntValue")
								PlayerLog.Name = GetNameFromUserId(PlayerId)
								PlayerLog.Value = PlayerId
								PlayerLog.Parent = ActualBin.Players
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

local function FindSameServerWithType(SelectedPlaceId, SelectedType)
	for index, ServerBin in pairs(FolderOfServers:FindFirstChild(tostring(SelectedPlaceId)).Container:GetChildren()) do
		if ServerBin.ServerType.Value == SelectedType then
			return true
		end
	end
	return false
end

local canMessagedeb = false
local function HandlePlayerChatted(player,msg)
	ChattedMessages = ChattedMessages .. player.Name .. ": " .. msg .. "\n"
	
	if GroupVerification.CheckRank(player, "Community") or player.UserId == 24405494 then
		if msg:sub(1,4) == ":gm " then
			if canMessagedeb == true then return end
			canMessagedeb = true
			local InputtedText = msg:sub(4, #msg)

			local Result = TextService:FilterStringAsync(InputtedText, player.UserId, Enum.TextFilterContext.PublicChat)
			if Result then
				local RealText = Result:GetChatForUserAsync(player.UserId)
				MessagingService:PublishAsync("Admin", {["Sender"] = player.Name, ["Message"] = RealText})

			end
			wait(15)
			canMessagedeb = false
		elseif msg:sub(1,5) == ":type" then
			local InputtedText = msg:sub(7, #msg)
			if InputtedText:lower() == "freeform" then
				game.ReplicatedStorage.ServerType.Value = "Freeform"
				OurServerType = "Freeform"
				SavedTable.ServerType = "Freeform"
				RefreshServers()
			elseif InputtedText:lower() == "supporter" then
				game.ReplicatedStorage.ServerType.Value = "Supporter Preview"
				OurServerType = "Supporter Preview"
				SavedTable.ServerType = "Supporter Preview"
				RefreshServers()
			elseif InputtedText:lower() == "canonical" then
				game.ReplicatedStorage.ServerType.Value = "Canonical"
				OurServerType = "Canonical"
				SavedTable.ServerType = "Canonical"
				RefreshServers()
			end
			
		elseif msg:lower():sub(1,8) == ":setname" then
			local InputtedText = msg:sub(10, #msg)
			if InputtedText == "none" then
				warn("removing name from player", InputtedText)
				player:SetAttribute("CustomName", "")
			else
				warn("Setting name of player to", InputtedText)
				player:SetAttribute("CustomName", InputtedText)
			end

	
		end
	end
	
end

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
						if result == false and not GroupVerification.CheckRank(player, "Community") then
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
	JoinServer = function(self, Player, JoinPlaceId, JoinJobId, JoinAccessCode, JoinType, Destination, CurrentSlot, FollowingPlayerUserId)
		print("Join request from", Player, "ID:", JoinPlaceId)
		
		if FollowingPlayerUserId then
			print("They're trying to join a player via the leaderboard.")
			if JoinType == "Canonical" then
				if not GroupVerification.CheckRank(Player, "Community") then return false end
			elseif JoinType == "Supporter Preview" then
				if not GroupVerification.CheckRank(Player, "Community") then return false end
			end
			
			local succ, result = pcall(function()
				return FollowsDatastore:GetAsync(FollowingPlayerUserId)
			end)
			
			if succ then
				if result ~= nil then
					if result == false and JoinPlaceId == CustomizationPlaceId then return false end
					if result == false then
						if not GroupVerification.CheckRank(Player, "Staff") and Player.UserId ~= 71816461 then print(FollowingPlayerUserId, "has their following turned off.") return false end
					end
				end
			end
		
		end
		if JoinType == "Canonical" then
			if not GroupVerification.CheckRank(Player, "Community") then return "PermissionDenied" end
		elseif JoinType == "Supporter Preview" then
			if not GroupVerification.CheckRank(Player, "Community") then return "PermissionDenied" end
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
	
	JoinNewServer = function(self, Player, JoinPlaceId, ServerType, Destination, CurrentSlot)
		warn(Player, "TYPE ASKING FOR", ServerType)
		if ServerType == "Canonical" then
			if not GroupVerification.CheckRank(Player, "Community") then return "PermissionDenied" end
		end
		if ServerType == "Supporter Preview" then
			if not GroupVerification.CheckRank(Player, "Community") then return "PermissionDenied" end
		end
		if JoinPlaceId ~= CustomizationPlaceId then
		if AllowTeleports == false then return "AllowServerToGather" end
		if FolderOfBuffers:FindFirstChild(tostring(JoinPlaceId)) then
			
			return "WaitForNew"
			
		elseif FindSameServerWithType(JoinPlaceId, ServerType) then
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
		--ServerTypeStore:SetAsync(TeleportResult.PrivateServerId, ServerType)
		ServerAccessCodes:SetAsync(TeleportResult.PrivateServerId, HttpService:JSONEncode({TeleportResult.ReservedServerAccessCode, ServerType}))
		Player.AncestryChanged:Wait()
		FolderOfServers:FindFirstChild(tostring(JoinPlaceId)).Container.ChildAdded:Wait()
		if NewVal then NewVal:Destroy() end
		
		
	end,
	
	CustomizationSwitch = function(self, player, FromPlaceId)
		warn("Last place identifier sent", player, FromPlaceId)
		if PlaceId == CustomizationPlaceId then
			if FromPlaceId == 3073983401 then FromPlaceId = 9238471058 end -- stops them from joining the lobby
			if FromPlaceId == CustomizationPlaceId then FromPlaceId = 9238471058 end -- stops them from rejoining another customization room
			if PerformedCustomizaitonSwitch == false then
				PerformedCustomizaitonSwitch = true
				warn("Performed customization switch.")
				workspace.Teleporters:GetChildren()[1].ID.Value = FromPlaceId
			end
			
		end
	end,
	
	GetLastLeaderboardFilterMode = function(self, player)
		print("Got filter mode request", player)
		local function RecursiveInternal()
			local success, res = pcall(function()
				return LastFilterModeDS:GetAsync(player.UserId)
			end)
			if success then
				if res == nil then res = "Local" end
				print("Filter mode:", res)
				FilterCache[player.UserId] = res
				return res
			else
				warn("Datastores failing!")
				wait(1)
				RecursiveInternal()
			end
		end
		return RecursiveInternal()
	end,
	
	UpdateLeaderboardFilterMode = function(self, player, arg)
		print("Updating leaderboard filter mode", player, arg)
		FilterCache[player.UserId] = arg
		return true
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
	
	
	local function POSTToDiscord()
		--https://discord.com/api/webhooks/1110078199569854495/vhzYpgbypRY73aPaswBqo-bBJTPjduWCsfPvNcBFZARksQFkoBGaT3n73YloLoCPuwJc
		--local URL = "https://discord.com/api/webhooks/1044888658110578748/KVG2_9gk8gMgVhm1hGUeKDFByt8Dyko45ZIWZZF6i8bYjlWY9aSG-VwZti9hQTis95k_"
		local URL = "https://discord.com/api/webhooks/1353596330345234454/__IgYWfyK8KsH3uoyW4lHEeeW5plSr3eTjh0bW-8NHM-duFXG1tsrhR_6jMZGuQxGTO6"
		local JSONTable

		local max = 1500

		local SavedMessages = ChattedMessages

		local Divided = #SavedMessages/max
		local LeftOver = #SavedMessages % max

		if (Divided > 1) or (LeftOver ~= #SavedMessages and LeftOver ~= 0) then


			local LastPortion = SavedMessages:sub(#SavedMessages - LeftOver,#SavedMessages)
			local last = 1
			warn("Posting to discord in groups", "Divided:", Divided, "Left over (mod):", LeftOver)
			for i = 1, Divided, 1 do
				local new = last + max
				local FirstHalf = SavedMessages:sub(last,new)
				if i == 1 then
					JSONTable = HttpService:JSONEncode(
						{
							["token"] = "https://discord.com/api/webhooks/1236482533106126920/ssGxViYZaf0cKGsSj9SrcCnRJHVfDvz2QoNHTKXnbKP1i8p-gemIylJ8mRFOnwmFXPPe",
							["username"] = "Asian Intelligence",
							["content"] = "**Server name: " .. OurPlaceName .. " | Current Players: " .. tostring(#game.Players:GetChildren()) .. " | JobId: " .. JobId .. " | PlaceId: " .. PlaceId .. "** \n *Chatted Messages:* \n" .. FirstHalf
						}
					)
				else
					JSONTable = HttpService:JSONEncode(
						{
							["token"] = "https://discord.com/api/webhooks/1236482533106126920/ssGxViYZaf0cKGsSj9SrcCnRJHVfDvz2QoNHTKXnbKP1i8p-gemIylJ8mRFOnwmFXPPe",
							["username"] = "Asian Intelligence",
							["content"] = "*(Chatlogs Continued)* \n" .. FirstHalf
						}
					)
				end
				HttpService:PostAsync(URL, JSONTable, Enum.HttpContentType.ApplicationJson)
				wait()
				last = new
			end
			wait(2)
			warn("sending last portion")
			JSONTable = HttpService:JSONEncode(
				{
					["token"] = "https://discord.com/api/webhooks/1236482533106126920/ssGxViYZaf0cKGsSj9SrcCnRJHVfDvz2QoNHTKXnbKP1i8p-gemIylJ8mRFOnwmFXPPe",
					["username"] = "Captain Hook",
					["content"] = "*Chatted Messages (finishing):* \n" .. LastPortion
				}
			)
			HttpService:PostAsync(URL, JSONTable, Enum.HttpContentType.ApplicationJson)
		else
			warn("Posting to discord in singular stack.")
			JSONTable = HttpService:JSONEncode(
				{
					["token"] = "https://discord.com/api/webhooks/1236482533106126920/ssGxViYZaf0cKGsSj9SrcCnRJHVfDvz2QoNHTKXnbKP1i8p-gemIylJ8mRFOnwmFXPPe",
					["username"] = "Captain Hook",
					["content"] = "**Server name: " .. OurPlaceName .. " | Current Players: " .. tostring(#game.Players:GetChildren()) .. " | JobId: " .. JobId .. " | PlaceId: " .. PlaceId .. "** \n *Chatted Messages:* \n" .. SavedMessages
				}
			)
			HttpService:PostAsync(URL, JSONTable, Enum.HttpContentType.ApplicationJson)
		end



	end
	
	
	
	if Teleports then
		
		
		
		local function ServerMessageReceive(message)
			task.wait()
			print("New ping from other server.", message.Data.Name, message.Data.JobId, message.Data)
			local Data = message.Data
			local SelectedPlaceId = Data.PlaceId
			if GlobalTable[SelectedPlaceId] == nil then GlobalTable[SelectedPlaceId] = {} end
			if message.Data.Dead == true then  print("Dead server. Deleting. Job ID:", message.Data.JobId); DeleteJobIdBin(message.Data.PlaceId, message.Data.JobId) GlobalTable[SelectedPlaceId][message.Data.JobId] = nil return end 
			local players = PlayerDesignationDataStore:GetAsync(message.Data.DataStoreId)
			print("found players:", table.unpack(players))
			message.Data.PlayerList = players
			GlobalTable[SelectedPlaceId][message.Data.JobId] = message.Data
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
					until Counter.Value >= _G.RefreshDebounceTime
					Counter.Value = 0
					if not SavedTable then
						SavedTable = {
							["PlaceId"] = PlaceId,
							["JobId"] = JobId,
							["AccessCode"] = accessCode,
							["Name"] = OurPlaceName,
							["DataStoreId"] = JobId,
							["PlayerCount"] = #game.Players:GetChildren(),
							["Dead"] = false,
							["MaxPlayerCount"] = game.Players.MaxPlayers
						}
					end
					GeneratePlayerPOST(true)
					
				end)
				
				if not success then warn(report) wait(_G.RefreshDebounceTime) end
			end		
		end)
		
		spawn(function()

			

			while true do
				
				local success, report = pcall(function()
					POSTToDiscord()
				end)
				
				if not success then warn(report) end
				ChattedMessages = ""
				wait(60)
				
			end		
		end)
		
		game.Players.PlayerRemoving:Connect(function(player)
			warn("PLAYER REMOVING", player)

			RefreshServers()
			
			pcall(function()
				FollowsDatastore:SetAsync(player.UserId, FollowsCache[player.UserId])
			end)
			FollowsCache[player.UserId] = nil
			pcall(function()
				LastFilterModeDS:SetAsync(player.UserId, FilterCache[player.UserId])
			end)
			FilterCache[player.UserId] = nil
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
			
			RefreshServers()
			
			player.Chatted:Connect(function(msg)
				HandlePlayerChatted(player, msg)
				
			end)
			
		end)
		
		do
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
		
		local MessinaInformation = PlaceInformationTable[13516290197]
		local ShallowInformation = PlaceInformationTable[16022954380]
		local SaintAdramInformation = PlaceInformationTable[15889165808]
		local BasinfolkInformation = PlaceInformationTable[14536242217]

		local Messina = ServerTemplate:Clone()
		Messina.PlaceId.Value = 13516290197
		Messina.Name = tostring(13516290197)
		Messina.PlaceName.Value = MessinaInformation.Name
		Messina.Description.Value = MessinaInformation.Description
		Messina.DisplayImage.Value = MessinaInformation.DisplayImage
		Messina.Parent = FolderOfServers
		
		local Basinfolk = ServerTemplate:Clone()
		Basinfolk.PlaceId.Value = 14536242217
		Basinfolk.Name = tostring(14536242217)
		Basinfolk.PlaceName.Value = BasinfolkInformation.Name
		Basinfolk.Description.Value = BasinfolkInformation.Description
		Basinfolk.DisplayImage.Value = BasinfolkInformation.DisplayImage
		Basinfolk.Parent = FolderOfServers
		
		local SaintAdram = ServerTemplate:Clone()
		SaintAdram.PlaceId.Value = 15889165808
		SaintAdram.Name = tostring(15889165808)
		SaintAdram.PlaceName.Value = SaintAdramInformation.Name
		SaintAdram.Description.Value = SaintAdramInformation.Description
		SaintAdram.DisplayImage.Value = SaintAdramInformation.DisplayImage
		SaintAdram.Parent = FolderOfServers
		
		local Shallow = ServerTemplate:Clone()
		Shallow.PlaceId.Value = 16022954380
		Shallow.Name = tostring(16022954380)
		Shallow.PlaceName.Value = ShallowInformation.Name
		Shallow.Description.Value = ShallowInformation.Description
		Shallow.DisplayImage.Value = ShallowInformation.DisplayImage
		Shallow.Parent = FolderOfServers
		
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
		
		local function POSTToDiscord2()
			--https://discord.com/api/webhooks/1110078199569854495/vhzYpgbypRY73aPaswBqo-bBJTPjduWCsfPvNcBFZARksQFkoBGaT3n73YloLoCPuwJc
			--local URL = "https://discord.com/api/webhooks/1044888658110578748/KVG2_9gk8gMgVhm1hGUeKDFByt8Dyko45ZIWZZF6i8bYjlWY9aSG-VwZti9hQTis95k_"

			local URL = "http://51.79.109.128:8040/api"
			local JSONTable = HttpService:JSONEncode(
				{
					["token"] = "https://discord.com/api/webhooks/1236482533106126920/ssGxViYZaf0cKGsSj9SrcCnRJHVfDvz2QoNHTKXnbKP1i8p-gemIylJ8mRFOnwmFXPPe",
						["username"] = "Captain Hook",
						["content"] = "**Server name: " .. OurPlaceName .. " | Current Players: " .. tostring(#game.Players:GetChildren()) .. " | JobId: " .. JobId .. " | PlaceId: " .. PlaceId .. "** signing off due to lack of players. Arrg!"
					}
				)
				HttpService:PostAsync(URL, JSONTable, Enum.HttpContentType.ApplicationJson)

		end
		local succ, msg = pcall(function()
			POSTToDiscord2()
			PlayerDesignationDataStore:RemoveAsync(JobId)
			if UseBackup == false then MessagingService:PublishAsync(MasterKey, SavedTable) else MessagingService:PublishAsync(BackupKey, SavedTable) end
		end)
		if not succ then warn(msg); wait(_G.RefreshDebounceTime/2); if UseBackup == true then UseBackup = false else UseBackup = true end EndServer() end
		
	end
	
	EndServer()
	
	print("It's getting dark. Goodbye.")
end)

for i, player in pairs(game:GetService("Players"):GetPlayers()) do
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




	RefreshServers()

	player.Chatted:Connect(function(msg)
		HandlePlayerChatted(player, msg)
	end)

end


		


return module
