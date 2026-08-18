local module = {}

print("EventSystem.lua indexing")

local RS = game:GetService("ReplicatedStorage")
local HTTPS

local CurrentEvents = Instance.new("Folder")
CurrentEvents.Name = "CurrentEvents"
CurrentEvents.Parent = RS

local EventInvoke = Instance.new("RemoteFunction")
EventInvoke.Name = "EventInvoke"
EventInvoke.Parent = RS

local InviteTemplate = script:WaitForChild("EventInvite")

local DebounceTable = {}

local EventNumber = 0

local function PassTurn(Event)
	if DebounceTable[Event:GetAttribute("Identifier")] == true then return end
	DebounceTable[Event:GetAttribute("Identifier")] = true
	wait(2)
	local all = true
	for i, PlayerCard in pairs(Event:GetChildren()) do
		if PlayerCard.Value == false then
			all = false
		end
	end
	if all then
		for i, PlayerCard in pairs(Event:GetChildren()) do
			PlayerCard.Value = false
		end
		local val = Event:GetAttribute("CurrentTurn")
		val += 1
		Event:SetAttribute("CurrentTurn", val)
	end
	DebounceTable[Event:GetAttribute("Identifier")] = false
end

local function RemovePlayerFromAllEvents(Player)
	print("Remove Player from All Events", Player)
	local EventPlayerWasIn = nil
	for i, v in pairs(CurrentEvents:GetDescendants()) do
		if v.Name == Player.Name then
			EventPlayerWasIn = v.Parent
			v:Destroy()
		end
	end
	
	if EventPlayerWasIn then
		if #EventPlayerWasIn:GetChildren() == 0 then
			EventPlayerWasIn:Destroy()
		end
	end
	
	spawn(function()
		if EventPlayerWasIn then
			PassTurn(EventPlayerWasIn)
		end
	end)
end

local function AddPlayerToEvent(Event, Player)
	print("AddPlayerToEvent", Event, Player)
	local NewPlayer = Instance.new("BoolValue")
	NewPlayer.Name = Player.Name
	if Player:GetRankInGroup(2962831) >= 249 then
		NewPlayer:SetAttribute("Host", true)
	else
		NewPlayer:SetAttribute("Host", false)
	end
	NewPlayer.Parent = Event
end


local function CreateSpontaneous(Host, Others)
	print("Create Spontaneous", Host, Others)
	EventNumber += 1
	local new = Instance.new("Folder")
	new.Name = "Spontaneous Event" .. tostring(EventNumber)
	new:SetAttribute("CurrentTurn", 0)
	new:SetAttribute("Type", "Spontaneous Event")
	new:SetAttribute("Identifier", tostring(math.random(1,99999)))
	local HostPlayer = Instance.new("BoolValue")
	HostPlayer.Name = Host.Name
	HostPlayer:SetAttribute("Host", true)
	HostPlayer.Parent = new
	if Others then
		for i, player in pairs(Others) do
			local NewPlayer = Instance.new("BoolValue")
			NewPlayer.Name = player.Name
			if player:GetRankInGroup(2962831) >= 249 then
				NewPlayer:SetAttribute("Host", true)
			else
				NewPlayer:SetAttribute("Host", false)
			end
			NewPlayer.Parent = new
		end
	end
	new.Parent = CurrentEvents
	DebounceTable[new:GetAttribute("Identifier")] = false
	return new
end

local function FindEvent(PlayerInEvent)
	print("Find Event", PlayerInEvent)
	for i, v in pairs(CurrentEvents:GetChildren()) do
		if v:FindFirstChild(PlayerInEvent.Name) then
			return v
		end
	end
	return false
end

local function IsPlayerHost(Player)
	local Event = FindEvent(Player)
	if Event then
		local box = Event:FindFirstChild(Player.Name)
		if box then
			return box:GetAttribute("Host")
		end
	end
	return false
end


local function InvitePlayer(Sender, Receiver)
	print("Invite Player", Sender, Receiver)
	local newInvite = InviteTemplate:Clone()
	local done = false
	local ReturningEvent = false
	newInvite.Accept.MouseButton1Down:Connect(function()
		RemovePlayerFromAllEvents(Receiver)
		local Event = FindEvent(Sender)
		if Event then
			AddPlayerToEvent(Event, Receiver)
		else
			ReturningEvent = CreateSpontaneous(Sender, {Receiver})
		end
		done = true
	end)
	newInvite.Decline.MouseButton1Down:Connect(function()
		newInvite:Destroy()
		done = true
	end)
	newInvite.Parent = Receiver.PlayerGui.Main.EventSystem.InviteBin
	local i = 1
	repeat wait(1) until i > 30 or done
	if done == false then
		newInvite:Destroy()
		return false
	else
		print("Invite finished!")
		newInvite:Destroy()
		return ReturningEvent
	end
	
end



local function TogglePlayerSubmission(Client, Value)
	local Event = FindEvent(Client)
	if Event then
		Event:FindFirstChild(Client.Name).Value = Value
	end
	-- check if they're all true
	spawn(function()
		
		if Value == false then return end
		local all = true
		for i, PlayerCard in pairs(Event:GetChildren()) do
			if PlayerCard.Value == false then
				all = false
			end
		end
		if all then
			PassTurn(Event)
		end
		
	end)
	return true
end

EventInvoke.OnServerInvoke = function(Client, Request, Argument, Argument2)
	print("Event System : ", Client, Request, Argument)
	if Request == "CreateSpontaneous" then
		return CreateSpontaneous(Client)
	elseif Request == "Invite" then
		return InvitePlayer(Client, Argument)
	elseif Request == "Join" then
		RemovePlayerFromAllEvents(Client)
		AddPlayerToEvent(Argument, Client)
		return true
	elseif Request == "Leave" then
		RemovePlayerFromAllEvents(Client)
		return true
	elseif Request == "Remove" then
		if IsPlayerHost(Client) then
			RemovePlayerFromAllEvents(Argument)
			return true
		else
			return false
		end
	elseif Request == "Submit" then
		return TogglePlayerSubmission(Client, true)
	elseif Request == "Rescind" then
		return TogglePlayerSubmission(Client, false)
	end
end

game.Players.PlayerRemoving:Connect(function(Player)
	RemovePlayerFromAllEvents(Player)
end)


return module
