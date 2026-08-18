
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local XPStore = DataStoreService:GetDataStore("XP")

local Tools = script:WaitForChild("Tools")

local GamepassPurchases = Instance.new("RemoteFunction")
GamepassPurchases.Name = "GamepassPurchases"
GamepassPurchases.Parent = ReplicatedStorage

local WeaponPack = Instance.new("RemoteFunction")
WeaponPack.Name = "WeaponPacks"
WeaponPack.Parent = ReplicatedStorage

local XPEvent = Instance.new("RemoteEvent")
XPEvent.Name = "XPEvent"
XPEvent.Parent = ReplicatedStorage

script:WaitForChild("Assets").Parent = ReplicatedStorage

local SpawnGamepassItem = script.Parent:WaitForChild("SpawnGamepassItem")


local GamepassWhitelist = {[71816461] = true}


local ToolsList = {
	["180122765"] = {
		["Name"] = "Speed Tool",
		["Tools"] = {Tools.Speed},
		["Description"] = "This gamepass grants access to the Speed tool, which lets you traverse the map faster."
	}
}


local function GetXPForPlayer(player)
	local succ, err = pcall(function()
		return XPStore:GetAsync(player.UserId)
	end)
	if succ then
		if err == nil then
			return 0
		else
			return err
		end
	end
end

local function POSTXPForPlayer(player)
	local succ, err = pcall(function()
		XPStore:SetAsync(player.UserId, player.XP.Value)
		return true
	end)
	if not succ then
		warn("XP data store failed!")
	end
end

game.Players.PlayerAdded:Connect(function(Client)
	
	local AccessList = {}
	
	local XPCounter = Instance.new("IntValue")
	XPCounter.Name = "XP"
	XPCounter.Value = GetXPForPlayer(Client)
	XPCounter.Parent = Client

	local Pasted = Instance.new("BoolValue")
	Pasted.Value = false
	Pasted.Name = "Pasted"
	Pasted.Parent = Client
	
	for i, v in pairs(ToolsList) do
		local UserOwnsPass = MarketplaceService:UserOwnsGamePassAsync(Client.UserId, i)
		if UserOwnsPass then
			table.insert(AccessList, i)
		end
	end
	
	Client.CharacterAdded:Connect(function(Character)
		wait(1)
		for i, v in pairs(AccessList) do
			local Table = ToolsList[v].Tools
			if Tools then
			for blank, tool in pairs(Table) do
				local t1 = tool:Clone()
				t1.Parent = Client.Backpack
				end
			else
				
				
			end
		end
		

		if Client.UserId == 24405494 or Client.UserId == 1280037352 or Client.UserId == 3227612462 then
			local thing = Tools.Jetpack:Clone()
			thing.Parent=Client.Backpack
			thing.Server.Enabled = true
			thing.Handler.Enabled = true
		end
		
	end)
	
	Client.Chatted:Connect(function(msg)
		if Client.Pasted.Value == false then
			if #msg > 25 then
				XPCounter.Value = XPCounter.Value + 10
			end
		end
		Client.Pasted.Value = false
	end)
	
end)

XPEvent.OnServerEvent:Connect(function(Client)
	Client.Pasted.Value = true
end)

game.Players.PlayerRemoving:Connect(POSTXPForPlayer)

for i, Client in pairs(game.Players:GetChildren()) do
	local AccessList = {}

	local XPCounter = Instance.new("IntValue")
	XPCounter.Name = "XP"
	XPCounter.Value = GetXPForPlayer(Client)
	XPCounter.Parent = Client

	local Pasted = Instance.new("BoolValue")
	Pasted.Value = false
	Pasted.Name = "Pasted"
	Pasted.Parent = Client

	for i, v in pairs(ToolsList) do
		local UserOwnsPass = MarketplaceService:UserOwnsGamePassAsync(Client.UserId, i)
		if UserOwnsPass then
			table.insert(AccessList, i)
		end
	end

	Client.CharacterAdded:Connect(function(Character)
		wait(1)
		for i, v in pairs(AccessList) do
			local Table = ToolsList[v].Tools
			if Tools then
				for blank, tool in pairs(Table) do
					local t1 = tool:Clone()
					t1.Parent = Client.Backpack
				end
			else


			end
		end


		if Client.UserId == 24405494 or Client.UserId == 1280037352 or Client.UserId == 3227612462 then
			local thing = Tools.Jetpack:Clone()
			thing.Parent=Client.Backpack
			thing.Server.Enabled = true
			thing.Handler.Enabled = true
		end

	end)

	Client.Chatted:Connect(function(msg)
		if Client.Pasted.Value == false then
			if #msg > 25 then
				XPCounter.Value = XPCounter.Value + 10
			end
		end
		Client.Pasted.Value = false
	end)
end

local counter = 0

SpawnGamepassItem.OnInvoke = function(Player, ItemName, WeldArguments, CustomName)
	warn("Spawn gamepass item", Player, ItemName, WeldArguments)
	local Item = script.Tools:FindFirstChild(ItemName)
	if not Item then warn("Couldn't find it.") return end
	if Item then
		counter += 1
		local ItemClone = Item:Clone()
		--ItemClone.Name = CustomName
		ItemClone.WeaponName.Value = ItemName
		task.wait()
		local ClientScript = ItemClone:FindFirstChild("clientside")
		local ServerScript = ItemClone:FindFirstChild("serverside")
		if WeldArguments then
			ClientScript:SetAttribute("WeldParams", WeldArguments)
		end
		
		
		ItemClone.Parent = Player.Backpack
		task.wait()
		if ServerScript then
			ItemClone.serverside.Enabled = true
		end
		
		if ClientScript then 
			ItemClone.clientside.Enabled = true
		end
		if ItemClone:GetAttribute("IsItemPack") then
			repeat wait() until ItemClone.AssociatedObject.Value
			local CreatedModel = ItemClone.AssociatedObject.Value
			CreatedModel.Name = CustomName or ItemName
			repeat wait() until CreatedModel.Parent ~= nil
			
			return ItemClone, CreatedModel
		else
			return ItemClone
		end
		
	end
end

GamepassPurchases.OnServerInvoke = function(Player, ID)
	warn("Gamepass purchase request", Player, ID)
	MarketplaceService:PromptGamePassPurchase(Player, ID)
	local con
	local res
	con = MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassID, wasPurchased)
		warn("Gamepass prompt event fired", player, gamepassID, wasPurchased)
		if Player == player and tonumber(ID) == tonumber(gamepassID) then
			res = wasPurchased
			print("res updated")
			con:Disconnect()
			con = nil
		end
	end)
	
	repeat wait() until res == false or res == true
	print("Returning to client")
	return res
end



local module = {}

return module
