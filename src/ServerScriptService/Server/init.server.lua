print("Server.lua is running!")

--[[

░██████╗███████╗██████╗░██╗░░░██╗███████╗██████╗░
██╔════╝██╔════╝██╔══██╗██║░░░██║██╔════╝██╔══██╗
╚█████╗░█████╗░░██████╔╝╚██╗░██╔╝█████╗░░██████╔╝
░╚═══██╗██╔══╝░░██╔══██╗░╚████╔╝░██╔══╝░░██╔══██╗
██████╔╝███████╗██║░░██║░░╚██╔╝░░███████╗██║░░██║
╚═════╝░╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝

Written by Ellis

This handles direct input from the Client and directs it to the appropriate module script.

]]


local Modules = script:WaitForChild("Modules")
local GroupId = 295131561

-- Services

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- tick for clients
spawn(function()
	local ticker = Instance.new("NumberValue")
	ticker.Name = "ServerTick"
	ticker.Value = tick()
	ticker.Parent = ReplicatedStorage
	while true do
		wait(1)
		ticker.Value = tick()
	end
end)

-- Events



local CustomizationInvoke = Instance.new("RemoteFunction")
CustomizationInvoke.Name = "Customization"
CustomizationInvoke.Parent = ReplicatedStorage

local CustomizingEvent = Instance.new("RemoteEvent")
CustomizingEvent.Name = "CustomizingEvent"
CustomizingEvent.Parent = ReplicatedStorage

local MultiverseInvoke = Instance.new("RemoteFunction")
MultiverseInvoke.Name = "Multiverse"
MultiverseInvoke.Parent = ReplicatedStorage

local PartyInvoke = Instance.new("RemoteFunction")
PartyInvoke.Name = "PartyInvoke"
PartyInvoke.Parent = ReplicatedStorage

local ServerListUpdate = Instance.new("RemoteEvent")
ServerListUpdate.Name = "ServerListUpdate"
ServerListUpdate.Parent = ReplicatedStorage

local PropPlacerInvoke = Instance.new("RemoteFunction")
PropPlacerInvoke.Name = "PropPlacerInvoke"
PropPlacerInvoke.Parent = ReplicatedStorage

local DisplayRollEvent = Instance.new("RemoteEvent")
DisplayRollEvent.Name = "DisplayRollEvent"
DisplayRollEvent.Parent = ReplicatedStorage

local InfoFolder = Instance.new("Folder")
InfoFolder.Name = "Info"
InfoFolder.Parent = ReplicatedStorage


local DefaultType = 0.25
local DefaultProportions = 0


local playerStats = {} --this keeps a list of the stats for each player that enters the game
local TEST_MODE = true


local ACCOUNT_AGE_REQUIRED = 1
local Customization
local Multiverse
local ChatDetection
local AdManager
local Gamepass
local PurchaseHandling
local AttackVisualizer
local EventSystem
local PropsPlacer
local Help
local Economy
local D20

DisplayRollEvent.OnServerEvent:Connect(function(player, rollResults, diceSides, modifier)
	-- Define the center position offset
	local centerOffset = Vector3.new(0, 3, 0)
	local offsetSpacing = 2  -- Distance each result will move outwards from the center

	-- Function to calculate color based on roll result
	local function calculateColor(value, min, max)
		local normalizedValue = (value - min) / (max - min)  -- Normalize between 0 and 1
		return Color3.new(1 - normalizedValue, normalizedValue, 0)  -- Interpolate from red to green
	end

	-- Initialize total result
	local totalResult = 0

	-- Loop through each roll result and create a BillboardGui for it
	for i, result in ipairs(rollResults) do

		--player.PlayerGui.BK_System.Roll["Dice Roll"]:Play()

		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Size = UDim2.new(2, 0, 2, 0)
		billboardGui.Adornee = player.Character.Head
		billboardGui.StudsOffset = centerOffset  -- Start from the center
		billboardGui.Parent = player.Character.Head

		-- Create the background icon image
		local iconImage = Instance.new("ImageLabel")
		iconImage.Size = UDim2.new(0.8, 0, 0.8, 0)  -- Slightly larger than the text
		iconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
		iconImage.AnchorPoint = Vector2.new(0.5, 0.5)  -- Center it in the BillboardGui
		iconImage.BackgroundTransparency = 1
		iconImage.Image = "rbxassetid://115061086755656"
		iconImage.ZIndex = 0  -- Behind the text label
		iconImage.Parent = billboardGui

		-- Create the text label to display the roll result
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextScaled = true
		textLabel.TextStrokeTransparency = 0.6
		textLabel.Font = Enum.Font.GrenzeGotisch
		textLabel.ZIndex = 1  -- In front of the icon

		-- Calculate modified result
		local modifiedResult = result
		totalResult = totalResult + modifiedResult  -- Accumulate total result

		-- Set up the text to include the roll result and dice sides
		textLabel.Text = "" .. result.. "\n(d" .. diceSides .. ")"  -- Display result and dice sides
		textLabel.TextColor3 = calculateColor(modifiedResult, 1, diceSides)  -- Set color based on result
		textLabel.Parent = billboardGui

		-- Determine target position: first stays center, others alternate left/right
		local targetOffset
		if i == 1 then
			targetOffset = centerOffset  -- Center for the first roll
		elseif i % 2 == 0 then
			-- Even index: move to the left
			targetOffset = centerOffset - Vector3.new((i // 2) * offsetSpacing, 0, 0)
		else
			-- Odd index: move to the right
			targetOffset = centerOffset + Vector3.new((i // 2) * offsetSpacing, 0, 0)
		end

		-- Tween to animate from center to target position
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(billboardGui, tweenInfo, {StudsOffset = targetOffset})
		tween:Play()

		-- Delay each tween start for a staggered effect
		wait(0.2)

		-- Remove the BillboardGui after 10 seconds
		game.Debris:AddItem(billboardGui, 10)
	end

	-- Display the total result on the HumanoidRootPart
	local totalBillboardGui = Instance.new("BillboardGui")
	totalBillboardGui.Size = UDim2.new(1, 0, 1, 0)
	totalBillboardGui.Adornee = player.Character.HumanoidRootPart
	totalBillboardGui.Parent = player.Character.HumanoidRootPart
	totalBillboardGui.AlwaysOnTop = true

	-- Create text label for total result
	local totalTextLabel = Instance.new("TextLabel")
	totalTextLabel.Size = UDim2.new(1, 0, 1, 0)
	totalTextLabel.BackgroundTransparency = 1
	totalTextLabel.TextScaled = true
	totalTextLabel.TextStrokeTransparency = 0.6
	totalTextLabel.Font = Enum.Font.GrenzeGotisch
	totalTextLabel.Text = "" .. totalResult .."+" .. modifier .. "=" .. totalResult + modifier
	totalTextLabel.TextColor3 = calculateColor(totalResult, 1, diceSides * #rollResults)  -- Adjust color based on total range
	totalTextLabel.Parent = totalBillboardGui

	-- Remove the total BillboardGui after 10 seconds
	game.Debris:AddItem(totalBillboardGui, 10)
end)

spawn(function()
	Customization = require(Modules:WaitForChild("Customization"))
	ChatDetection = require(Modules:WaitForChild("ChatDetection"))
	AdManager = require(Modules:WaitForChild("AdManager"))
	Gamepass = require(Modules:WaitForChild("Gamepass"))
	PurchaseHandling = require(Modules:WaitForChild("PurchaseHandling"))
	AttackVisualizer = require(Modules:WaitForChild("AttackVisualizer"))
	Multiverse = require(Modules:WaitForChild("Multiverse"))
	EventSystem = require(Modules:WaitForChild("EventSystem"))
	PropsPlacer = require(Modules:WaitForChild("PropsPlacer"))
	Help = require(Modules:WaitForChild("Help"))
	Economy = require(Modules:WaitForChild("Economy"))
	D20 = require(Modules:WaitForChild("D20"))
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HeadRotationEvent = Instance.new("RemoteEvent", ReplicatedStorage)
HeadRotationEvent.Name = "HeadRotationEvent"

HeadRotationEvent.OnServerEvent:Connect(function(player, rotY)

	if player.Character and player.Character:FindFirstChild("Head") then

		local head = player.Character:WaitForChild("Head")
		local neck = head:FindFirstChild("Neck")

		if neck then

			neck.C1 = rotY

		end

	end

end)

game.Players.PlayerAdded:Connect(function(player)
	
	repeat task.wait() until Customization

	task.spawn(function() Customization.IndexPlayer(player) end)

	warn(player.Name .. " joined.")
	local newFolder = Instance.new("Folder")
	newFolder.Name = player.Name
	local newName = Instance.new("StringValue")
	newName.Name = "CName"
	newName.Parent = newFolder
	local newBio = Instance.new("StringValue")
	newBio.Name = "CBio"
	newBio.Parent = newFolder
	local newImage = Instance.new("NumberValue")
	newImage.Name = "CImage"
	newImage.Parent = newFolder
	
	local lastBioChanged = Instance.new("NumberValue")
	lastBioChanged.Name = "lastBioChanged"
	lastBioChanged.Value = tick()
	lastBioChanged.Parent = newFolder
	
	local lastEmpChanged = Instance.new("NumberValue")
	lastEmpChanged.Name = "lastEmpChanged"
	lastEmpChanged.Value = tick()
	lastEmpChanged.Parent = newFolder
	
	local lastD20 = Instance.new("NumberValue")
	lastD20.Name = "lastD20"
	lastD20.Value = "0"
	lastD20.Parent = newFolder
	
	local newEmpowerment = Instance.new("StringValue")
	newEmpowerment.Name = "Empowerment"
	newEmpowerment.Parent = newFolder
	local newEmpowermentType = Instance.new("StringValue")
	newEmpowermentType.Name = "EmpowermentType"
	newEmpowermentType.Parent = newFolder
	local newEmpowermentTitle = Instance.new("StringValue")
	newEmpowermentTitle.Name = "EmpowermentTitle"
	newEmpowermentTitle.Parent = newFolder


	local Skill1Title = Instance.new("StringValue")
	Skill1Title.Name = "Skill1Title"
	Skill1Title.Parent = newFolder
	local Skill1Type = Instance.new("StringValue")
	Skill1Type.Name = "Skill1Type"
	Skill1Type.Parent = newFolder
	local Skill1Description = Instance.new("StringValue")
	Skill1Description.Name = "Skill1Description"
	Skill1Description.Parent = newFolder
	
	local Skill2Title = Instance.new("StringValue")
	Skill2Title.Name = "Skill2Title"
	Skill2Title.Parent = newFolder
	local Skill2Type = Instance.new("StringValue")
	Skill2Type.Name = "Skill2Type"
	Skill2Type.Parent = newFolder
	local Skill2Description = Instance.new("StringValue")
	Skill2Description.Name = "Skill2Description"
	Skill2Description.Parent = newFolder
	
	local Skill3Title = Instance.new("StringValue")
	Skill3Title.Name = "Skill3Title"
	Skill3Title.Parent = newFolder
	local Skill3Type = Instance.new("StringValue")
	Skill3Type.Name = "Skill3Type"
	Skill3Type.Parent = newFolder
	local Skill3Description = Instance.new("StringValue")
	Skill3Description.Name = "Skill3Description"
	Skill3Description.Parent = newFolder
	
	local Skill4Title = Instance.new("StringValue")
	Skill4Title.Name = "Skill4Title"
	Skill4Title.Parent = newFolder
	local Skill4Type = Instance.new("StringValue")
	Skill4Type.Name = "Skill4Type"
	Skill4Type.Parent = newFolder
	local Skill4Description = Instance.new("StringValue")
	Skill4Description.Name = "Skill4Description"
	Skill4Description.Parent = newFolder
	
	local Skill5Title = Instance.new("StringValue")
	Skill5Title.Name = "Skill5Title"
	Skill5Title.Parent = newFolder
	local Skill5Type = Instance.new("StringValue")
	Skill5Type.Name = "Skill5Type"
	Skill5Type.Parent = newFolder
	local Skill5Description = Instance.new("StringValue")
	Skill5Description.Name = "Skill5Description"
	Skill5Description.Parent = newFolder
	
	newFolder.Parent = InfoFolder
	
	repeat task.wait() until player.Character
	
	do
		print(player, " spawned in")
		local Shirt = player.Character:WaitForChild("Shirt", 5)
		local Pants = player.Character:WaitForChild("Pants", 5)

		player.Character:WaitForChild("Humanoid"):WaitForChild("BodyTypeScale").Value = DefaultType -- keeps scaling consistent
		player.Character:WaitForChild("Humanoid"):WaitForChild("BodyProportionScale").Value = DefaultProportions

		local Attachment = Instance.new("Attachment");
		Attachment.Name = "ThrowableAttachment"
		Attachment.Orientation = Vector3.new(-45,0,-90)
		newName.Value = ""
		newBio.Value = ""
		newEmpowerment.Value = ""
		newEmpowermentType.Value = ""
		newEmpowermentTitle.Value = ""
		Attachment.Parent = player.Character:WaitForChild("HumanoidRootPart")

		--player.Character:WaitForChild("Humanoid"):WaitForChild("BodyTypeScale").Value = 0.8
		player.Character:WaitForChild("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		if Shirt == nil then
			local NewShirt = Instance.new("Shirt")
			NewShirt.ShirtTemplate = "rbxassetid://234480745"
			NewShirt.Name = "Shirt"
			NewShirt.Parent = player.Character
		end
		if Pants == nil then
			local NewPants = Instance.new("Pants")
			NewPants.PantsTemplate = "rbxassetid://234480878"
			NewPants.Name = "Pants"
			NewPants.Parent = player.Character
		end
	end

	player.CharacterAdded:Connect(function()
		print(player, " spawned in")
		local Shirt = player.Character:WaitForChild("Shirt", 5)
		local Pants = player.Character:WaitForChild("Pants", 5)
		
		player.Character:WaitForChild("Humanoid"):WaitForChild("BodyTypeScale").Value = DefaultType -- keeps scaling consistent
		player.Character:WaitForChild("Humanoid"):WaitForChild("BodyProportionScale").Value = DefaultProportions
		
		local Attachment = Instance.new("Attachment");
		Attachment.Name = "ThrowableAttachment"
		Attachment.Orientation = Vector3.new(-45,0,-90)
		newName.Value = ""
		newBio.Value = ""
		newEmpowerment.Value = ""
		newEmpowermentType.Value = ""
		newEmpowermentTitle.Value = ""
		Attachment.Parent = player.Character:WaitForChild("HumanoidRootPart")
		
		--player.Character:WaitForChild("Humanoid"):WaitForChild("BodyTypeScale").Value = 0.8
		player.Character:WaitForChild("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		if Shirt == nil then
			local NewShirt = Instance.new("Shirt")
			NewShirt.ShirtTemplate = "rbxassetid://234480745"
			NewShirt.Name = "Shirt"
			NewShirt.Parent = player.Character
		end
		if Pants == nil then
			local NewPants = Instance.new("Pants")
			NewPants.PantsTemplate = "rbxassetid://234480878"
			NewPants.Name = "Pants"
			NewPants.Parent = player.Character
		end
		
	end)
	-- player stats

	local leaderstats = Instance.new("Model", player)
	leaderstats.Name = "leaderstats"

	local grouprank = Instance.new("StringValue", leaderstats)
	grouprank.Name = "Rank"
	local rank = player:GetRoleInGroup(2962831) -- Insert the group ID for whatever group you want ranks displayed for here. 
	local truerank = player:GetRankInGroup(2962831)

	if rank ~= 1 then
		if truerank >= 247 then
			grouprank.Value = rank
		else
			if truerank == 5 then
				grouprank.Value = "[UO]"
			elseif truerank == 1 then
				grouprank.Value = "[N/A]"
			else
				grouprank.Value = "Player"
			end

		end
	else
		grouprank.Value = "Unrecorded"
	end



	playerStats[player] = leaderstats



	if TEST_MODE == false then
		if player.AccountAge < ACCOUNT_AGE_REQUIRED or player:GetRankInGroup(GroupId) == 0 then
			player:Kick("Account is too young or you lack the necessary permission to play, such as lacking an approved character.")
		end
	end
	
	

end)


-- Modules




game.Players.PlayerRemoving:Connect(function(player)
	local newFolder = InfoFolder:FindFirstChild(player.Name)
	if newFolder then newFolder:Destroy() end
end)

local function LastBioChangeProcess(player)
	local folder = InfoFolder:WaitForChild(player.Name)
	if folder then
		folder.lastBioChanged.Value = tick()
	end
end

local function LastEmpChangeProcess(player)
	local folder = InfoFolder:WaitForChild(player.Name)
	if folder then
		folder.lastEmpChanged.Value = tick()
	end
end

local OOCTbValues = {}

-- Remote Functions

CustomizationInvoke.OnServerInvoke = function(player, requestType, ...)
	repeat wait() until Multiverse and Customization
	print("CUSTOMIZATION INVOKE: ", player, "TYPE:", requestType)
	
	if requestType == "NameBio" then
		LastBioChangeProcess(player)
		local returned = Customization:NameBio(player, ...)
		return returned 
	elseif requestType == "Shirt" then
		local returned = Customization:Shirt(player, ...)
		return returned
	elseif requestType == "Pants" then
		local returned = Customization:Pants(player,...)
		return returned
	elseif requestType == "Face" then
		local returned = Customization:Face(player,...)
		return returned
	elseif requestType == "Color" then
		local returned = Customization:Color(player, ...)
		return returned
	elseif requestType == "AColor" then
		local returned = Customization:AColor(player, ...)
		return returned
	elseif requestType == "PColor" then
		local returned = Customization:PColor(player, ...)
		return returned
	elseif requestType == "Height" then
		LastBioChangeProcess(player)
		local returned = Customization:Height(player, ...)
		return returned
	elseif requestType == "Body" then
		local returned = Customization:Body(player, ...)
		return returned
	elseif requestType == "Proportionalize" then
		local returned = Customization:Proportionalize(player,...)
		return returned
	elseif requestType == "Animations" then
		local returned = Customization:Animations(player, ...)
		return returned
	elseif requestType == "ATransparency" then
		local returned = Customization:ATransparency(player,...)
		return returned
	elseif requestType == "Material" then
		local returned = Customization:Material(player,...)
		return returned
	elseif requestType == "MeshId" then
		local returned = Customization:MeshId(player,...)
		return returned
	elseif requestType == "Particle" then
		local returned = Customization:Particle(player,...)
		return returned
	elseif requestType == "ParticleAdjust" then
		local returned = Customization:ParticleAdjust(player,...)
		return returned
	elseif requestType == "Texture" then
		local returned = Customization:Texture(player,...)
		return returned
	elseif requestType == "Position" then
		local returned = Customization:Position(player,...)
		return returned
	elseif requestType == "Size" then
		local returned = Customization:Size(player,...)
		return returned
	elseif requestType == "Rotation" then
		local returned = Customization:Rotation(player,...)
		return returned
	elseif requestType == "AddAccessory" then
		local returned = Customization:AddAccessory(player,...)
		return returned
	elseif requestType == "BlankAccessory" then
		local returned = Customization:BlankAccessory(player,...)
		return returned
	elseif requestType == "Revert" then
		local returned = Customization:Revert(player,...)
		return returned
	elseif requestType == "Delete" then
		local returned = Customization:Delete(player,...)
		return returned
	elseif requestType == "Copy" then
		local returned = Customization:Copy(player,...)
		return returned
	elseif requestType == "OToggle" then
		local returned = Customization:OToggle(player, ...)
		return returned
	elseif requestType == "OTransparency" then
		local returned = Customization:OTransparency(player,...)
		return returned
	elseif requestType == "Save" then
		local returned = Customization:Save(player, ...)
		return returned
	elseif requestType == "Load" then
		LastEmpChangeProcess(player)
		LastBioChangeProcess(player)
		local returned = Customization:Load(player, ...)
		return returned
	elseif requestType == "RestoreAccessoryHistory" then
		LastEmpChangeProcess(player)
		LastBioChangeProcess(player)
		local returned = Customization:RestoreAccessoryHistory(player, ...)
		return returned
	elseif requestType == "LoadLegacy" then
		LastEmpChangeProcess(player)
		LastBioChangeProcess(player)
		local returned = Customization:LoadLegacy(player, ...)
		return returned
	elseif requestType == "AllData" then
		local returned = Customization:AllData(player, ...)
		return returned
	elseif requestType == "AllLegacyData" then
		local returned = Customization:AllLegacyData(player, ...)
		return returned
	elseif requestType == "WeldPart" then
		local returned = Customization:WeldPart(player,...)
		return returned
	elseif requestType == "MirrorAccessory" then
		local returned = Customization:MirrorAccessory(player,...)
		return returned
	elseif requestType == "LimbRemover" then
		local returned = Customization:LimbRemover(player,...)
		return returned
	elseif requestType == "SaveOutfitID" then
		local returned = Customization:SaveOutfitID(player,...)
		return returned
	elseif requestType == "LoadOutfitID" then
		LastEmpChangeProcess(player)
		LastBioChangeProcess(player)
		local returned = Customization:LoadOutfitID(player,...)
		return returned
	elseif requestType == "SaveAccessoryID" then
		local returned = Customization:SaveAccessoryID(player,...)
		return returned
	elseif requestType == "LoadAccessoryID" then
		local returned = Customization:LoadAccessoryID(player,...)
		return returned
	elseif  requestType == "Empowerment" then
		LastEmpChangeProcess(player)
		local returned = Customization:Empowerment(player,...)
		return returned
	elseif  requestType == "Skill" then
		LastEmpChangeProcess(player)
		local returned = Customization:Skill(player,...)
		return returned
	elseif requestType == "OOC" then
		
		local function ToggleOOC(val)
			print(player.Name, "OOC", val)
			if val == true then
				OOCTbValues[player.UserId] = {}
				local tb = OOCTbValues[player.UserId]
				for i, v in pairs(player.Character:GetDescendants()) do
					if v:IsA("BasePart") then
						if v.Transparency < 1 then
						
						table.insert(tb, {v, v.Transparency})
						
							v.Transparency = 0.9
						end
					end
				end
			else
				local tb = OOCTbValues[player.UserId]
				for i, v in pairs(tb) do
					v[1].Transparency = v[2]
				end
			end
		end
		ToggleOOC(...)
		return true
	elseif requestType == "AddItem" then
		local returned = Customization:AddItem(player,...)
		return returned
	elseif requestType == "Tutorial" then
		local returned = Customization:Tutorial(player,...)
		return returned
	elseif requestType == "SetTutorial" then
		local returned = Customization:SetTutorial(player,...)
		return returned
	end
end


MultiverseInvoke.OnServerInvoke = function(player, requestType, ...)
	repeat wait() until Multiverse
	print("MULTIVERSE INVOKE: ", player, "TYPE:", requestType)
	
	if requestType == "GetList" then
		local list = Multiverse:GetList(player,...)
		return list
	elseif requestType == "Teleport" then
		local redundant = Multiverse:PhysicalTeleport(player, ...)
		return redundant
	elseif requestType == "JoinServer" then
		local returned = Multiverse:JoinServer(player,...)
		return returned
	elseif requestType == "JoinNewServer" then
		local returned = Multiverse:JoinNewServer(player,...)
		return returned
	elseif requestType == "SetFollowPreference" then
		local returned = Multiverse:SetFollowPreference(player,...)
		return returned
	elseif requestType == "GetFollowPreference" then
		local returned = Multiverse:GetFollowPreference(player,...)
		return returned
	elseif requestType == "CustomizationSwitch" then
		local returned = Multiverse:CustomizationSwitch(player,...)
		return returned
	elseif  requestType == "GetLastLeaderboardFilterMode" then
		local returned = Multiverse:GetLastLeaderboardFilterMode(player)
		return returned
	elseif requestType == "UpdateLeaderboardFilterMode" then
		local returned = Multiverse:UpdateLeaderboardFilterMode(player,...)
		return returned
	end
	
end

PropPlacerInvoke.OnServerInvoke = function(player, requestType, a1, a2, a3)
	
	print("Check", requestType, a1, a2, a3)
	
	if requestType == "Move" then
		PropsPlacer:PropMove(player, a1, a2)
	elseif requestType == "Clone" then
		PropsPlacer:CloneProp(player, a1, a2)
	elseif requestType == "Rotate" then
		PropsPlacer:Rotation(player, a1, a2)
	elseif requestType == "Copy" then
		PropsPlacer:Copy(player, a1, a2)
	elseif requestType == "Delete" then
		PropsPlacer:Delete(player, a1, a2)
	elseif requestType == "Save" then
		PropsPlacer:Save(player, a1, a2)
	elseif requestType == "Load" then
		PropsPlacer:Load(player, a1)
	elseif requestType == "LoadUI" then
		PropsPlacer:LoadUI(player, a1)
	elseif requestType == "Rename" then
		PropsPlacer:Rename(player, a1, a2)
	elseif requestType == "StaffDelete" then
		PropsPlacer:Delete(game.Players:FindFirstChild(a1),a2, a3)
	end
	
end

repeat task.wait() until Customization

for i, v in pairs(game.Players:GetChildren()) do
	Customization.IndexPlayer(v)
end
