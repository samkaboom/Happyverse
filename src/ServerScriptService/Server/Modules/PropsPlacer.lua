--[[

██████╗░██████╗░░█████╗░██████╗░  ██████╗░██╗░░░░░░█████╗░░█████╗░███████╗██████╗░
██╔══██╗██╔══██╗██╔══██╗██╔══██╗  ██╔══██╗██║░░░░░██╔══██╗██╔══██╗██╔════╝██╔══██╗
██████╔╝██████╔╝██║░░██║██████╔╝  ██████╔╝██║░░░░░███████║██║░░╚═╝█████╗░░██████╔╝
██╔═══╝░██╔══██╗██║░░██║██╔═══╝░  ██╔═══╝░██║░░░░░██╔══██║██║░░██╗██╔══╝░░██╔══██╗
██║░░░░░██║░░██║╚█████╔╝██║░░░░░  ██║░░░░░███████╗██║░░██║╚█████╔╝███████╗██║░░██║
╚═╝░░░░░╚═╝░░╚═╝░╚════╝░╚═╝░░░░░  ╚═╝░░░░░╚══════╝╚═╝░░╚═╝░╚════╝░╚══════╝╚═╝░░╚═╝

░██╗░░░░░░░██╗██████╗░██╗████████╗████████╗███████╗███╗░░██╗  ██████╗░██╗░░░██╗  ██████╗░██╗░░██╗░░██╗██╗░█████╗░
░██║░░██╗░░██║██╔══██╗██║╚══██╔══╝╚══██╔══╝██╔════╝████╗░██║  ██╔══██╗╚██╗░██╔╝  ██╔══██╗██║░██╔╝░██╔╝██║██╔═══╝░
░╚██╗████╗██╔╝██████╔╝██║░░░██║░░░░░░██║░░░█████╗░░██╔██╗██║  ██████╦╝░╚████╔╝░  ██████╦╝█████═╝░██╔╝░██║██████╗░
░░████╔═████║░██╔══██╗██║░░░██║░░░░░░██║░░░██╔══╝░░██║╚████║  ██╔══██╗░░╚██╔╝░░  ██╔══██╗██╔═██╗░███████║t██╔══██╗
░░╚██╔╝░╚██╔╝░██║░░██║██║░░░██║░░░░░░██║░░░███████╗██║░╚███║  ██████╦╝░░░██║░░░  ██████╦╝██║░╚██╗╚════██║╚█████╔╝
░░░╚═╝░░░╚═╝░░╚═╝░░╚═╝╚═╝░░░╚═╝░░░░░░╚═╝░░░╚══════╝╚═╝░░╚══╝  ╚═════╝░░░░╚═╝░░░  ╚═════╝░╚═╝░░╚═╝░░░░░╚═╝░╚════╝░

]]--


-- Get the PlayerProp service
local propPlacer = Instance.new("Folder")
propPlacer.Name = "PlayerProp"
propPlacer.Parent = workspace

-- Define the maximum number of props allowed to be placed
local MAX_PROPS = 40
local MAX_SLOT = 10

-- Get some necessary game services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local PropSave = DataStoreService:GetDataStore("PropSave")
local SlotSave = DataStoreService:GetDataStore("SlotSave")

local Prop = script:WaitForChild("Prop")
Prop.Parent = ReplicatedStorage

-- Define the PropsPlacer object
local PropsPlacer = {}


-- Function that clones a prop and adds it to the player's folder
function PropsPlacer.CloneProp(_, player, model)

	-- Check if the player already has a prop folder
	local playerFolder = propPlacer:FindFirstChild(player.Name)

	if playerFolder then
		-- Check if the player has reached the maximum number of props
		if #playerFolder:GetChildren() >= MAX_PROPS then
			warn("Cannot place prop: player has reached the maximum number of props")
			return
		else
			-- Clone the prop and add it to the player's folder
			local propClone = model:Clone()
			propClone:SetAttribute("Owner", player.Name)
			propClone:SetAttribute("propName", propClone.Name)

			propClone.Parent = playerFolder
			-- Set the prop's position to be in front of the player
			propClone:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,4))
		end

	else

		-- Create a new folder for the player and add the prop to it
		local playerFolder = Instance.new("Folder")
		playerFolder.Name = player.Name
		playerFolder.Parent = propPlacer

		local propClone = model:Clone()
		propClone:SetAttribute("Owner", player.Name)
		propClone:SetAttribute("propName", propClone.Name)

		propClone.Parent = playerFolder
		-- Set the prop's position to be in front of the player
		propClone:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,4))

	end

end

function PropsPlacer.PropMove(_, player, model, cf)
	
	model:SetPrimaryPartCFrame(cf)
	
end

function PropsPlacer.Rotation(_, player, model, cf)

	model:SetPrimaryPartCFrame(cf)

end

function PropsPlacer.Rename(_, player, model, rename)

	for _, v in pairs(model) do
		
		print(v)
		v:SetAttribute("propName", rename)

	end

end

function PropsPlacer.Delete(_, player, model, cf)
	
	for _, v in pairs(model) do

		v:Destroy()

	end
	
end

function PropsPlacer.Copy(_, player, model, cf)
	
	local playerFolder = propPlacer:FindFirstChild(player.Name)

	if playerFolder then
		
		for _, v in pairs(model) do
				
			if #playerFolder:GetChildren() >= MAX_PROPS then
				return
			else
				local new = v:Clone()
				new.Parent = playerFolder
				new:SetAttribute("Owner", player.Name)
				new:SetAttribute("propName", new.Name)
			end
		
		end
		
	end
		
end

function PropsPlacer.Save(_, player, slot, test)

	local playerFolder = propPlacer:FindFirstChild(player.Name)
	print("Save..", player.UserId.."-"..slot.Name)
	
	slot.Slide.displayText.Text = test
	
	local sdata = {}
		
	for i,v in pairs(slot.Parent:GetChildren()) do

		if v:IsA("TextButton") then

			local slotdata = {
				Name = v.Name,
				Text = v.Slide.displayText.Text
			}

			table.insert(sdata, slotdata)

		end
	end

	SlotSave:SetAsync(player.UserId, {sdata})		
	print(sdata)
	
	if playerFolder then
		
		local pdata = {

			PlaceId = game.PlaceId,
			Prop = {}
			
		}
		
		for i,v in pairs(playerFolder:GetChildren()) do
			
			local proplist = {
				Name = v.Name,
				FixNamed = v:GetAttribute("propName"),
				Pos = {v.PrimaryPart.CFrame.X, v.PrimaryPart.CFrame.Y, v.PrimaryPart.CFrame.Z},
				Rot = {v.PrimaryPart.Rotation.X, v.PrimaryPart.Rotation.Y, v.PrimaryPart.Rotation.Z},
			}
			
			table.insert(pdata["Prop"], proplist)
			
		end
		
		print(pdata)
		PropSave:SetAsync(player.UserId.."-"..slot.Name, {pdata})		
		
	end

end

function PropsPlacer.Load(_, player, slot)
		
	local playerFolder = propPlacer:FindFirstChild(player.Name)
	local propData = PropSave:GetAsync(player.UserId.."-"..slot.Name)
	print(propData)
	
	print("Load..", player.UserId.."-"..slot.Name)
		
	if playerFolder then
		
		if propData[1]["PlaceId"] == game.PlaceId then
			
			playerFolder:ClearAllChildren()
			
			for i,v in pairs(propData[1]["Prop"]) do
				
				local propName = v["Name"]
				
				local Prop = ReplicatedStorage.Prop.wovProp[propName]:Clone()
				local CF = CFrame.new(v["Pos"][1],v["Pos"][2],v["Pos"][3]) * CFrame.Angles(math.rad(v["Rot"][1]), math.rad(v["Rot"][2]), math.rad(v["Rot"][3]))
				Prop:SetAttribute("Owner", player.Name)
				Prop:SetAttribute("propName", v["FixNamed"])
				Prop.Parent = playerFolder
				Prop:SetPrimaryPartCFrame(CF)

			end
			
		end
		
	else
		
		if propData[1]["PlaceId"] == game.PlaceId then
			
			local folder = Instance.new("Folder", player)
			folder.Parent = game.Workspace.PlayerProp

			for i,v in pairs(propData[1]["Prop"]) do

				local propName = v["Name"][1]

				local Prop = ReplicatedStorage.Prop.wovProp[propName]:Clone()
				local CF = CFrame.new(v["Pos"][1],v["Pos"][2],v["Pos"][3]) * CFrame.Angles(math.rad(v["Rot"][1]), math.rad(v["Rot"][2]), math.rad(v["Rot"][3]))
				print(CF)
				Prop:SetAttribute("Owner", player.Name)
				Prop:SetAttribute("propName", v["FixNamed"])
				Prop.Parent = folder
				Prop:SetPrimaryPartCFrame(CF)

			end
			
		end
		
	end
	
end

function PropsPlacer.LoadUI(_, player, slot)

	
	local sSave = SlotSave:GetAsync(player.UserId)
	print(player.UserId, sSave)
	
	if sSave ~= nil then
		
		for i,v in pairs(sSave[1]) do

			if slot:FindFirstChild(sSave[1][i]["Name"]) then

				slot:FindFirstChild(sSave[1][i]["Name"]).Slide.displayText.Text = sSave[1][i]["Text"]	

			end

		end
		
	end
	

end

game.Players.PlayerRemoving:Connect(function(player)
	local folder = propPlacer:FindFirstChild(player.Name)
	if folder then
		folder:Destroy()
	end
end)



return PropsPlacer
