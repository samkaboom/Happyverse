local module = {}

--[[

made by ellis
12/18/2021

to whoever is like reading this, i feel horrible. everyone around me loves me and i dont feel it. the one person i dedicate myself to is someone i can no longer identify, and im not sure i want to spend my life with anyone else. i'll
always just becomparing them to that one person, who was perfect in the little illusion they gave me.

rewritten by sam 
8/11/2026

hi

]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Billboards = workspace:FindFirstChild("Billboards")
if Billboards then

local AdEvent = Instance.new("RemoteEvent")
AdEvent.Name = "Advertisements"
AdEvent.Parent = ReplicatedStorage



local Classifications = {
	"MultiScrolling_Billboard",
	"Scrolling_Billboard_Large",
	"Scrolling_Billboard_Long",
	"Scrolling_Billboard_Regular",
	"Scrolling_Billboard_Short",
	"Static_Billboard_Banner",
	"Static_Billboard_Regular"
}

-- actual ad content, like the images
local Ads = {
	["Starcola"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {7093057478},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {7093057478},
			["Scrolling_Billboard_Short"] = {},

			["MultiScrolling_Billboard"] = {}
		},
	["Maelstrom"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {8430498996},

			["MultiScrolling_Billboard"] = {}
		},
	["Duke"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {8320505369},

			["MultiScrolling_Billboard"] = {}
		},
	["Trypticon"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {8396442920},

			["MultiScrolling_Billboard"] = {}
		},
	["Mornyl"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {8320505990},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {},

			["MultiScrolling_Billboard"] = {}
		},
		["Silke"] = 
			{
				["Static_Billboard_Regular"] = {8284831382, 12192607929},
				["Static_Billboard_Banner"] = {12192578331},

				["Scrolling_Billboard_Large"] = {},
				["Scrolling_Billboard_Long"] = {8420462889},
				["Scrolling_Billboard_Regular"] = {8430972175, 8420462889, 8473532703, 8284831382},
				["Scrolling_Billboard_Short"] = {},

				["MultiScrolling_Billboard"] = {}

			},
	["Terrain"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {8473036612},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {8320508776},

			["MultiScrolling_Billboard"] = {}
		},
	["Ikku"] = 
		{
			["Static_Billboard_Regular"] = {8935004903, 8411565288},
			["Static_Billboard_Banner"] = {8381221282},

			["Scrolling_Billboard_Large"] = {},
			["Scrolling_Billboard_Long"] = {8473214836},
			["Scrolling_Billboard_Regular"] = {8411565288, 8473297947, 8935004903},
			["Scrolling_Billboard_Short"] = {8381221282},

			["MultiScrolling_Billboard"] = {}
		},
	["Terminal"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {8320508322},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {8320508322},

			["MultiScrolling_Billboard"] = {}
		},
	["The Sky"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {},

			["MultiScrolling_Billboard"] = {5587292666}
		},
	["Chug"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {8396451195},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {},

			["MultiScrolling_Billboard"] = {}
		},
	["Spacepop"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {8396434673},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {8396434673},
			["Scrolling_Billboard_Short"] = {},

			["MultiScrolling_Billboard"] = {}
		},
	["Nebula"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {8320506713},
			["Scrolling_Billboard_Short"] = {},

			["MultiScrolling_Billboard"] = {}
		},
}

-- the slots these entities own

local AdsOwned = {
	["Starcola"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {1},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {},

			["MultiScrolling_Billboard"] = {}
		},
	["Duke"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {1,3,5},

			["MultiScrolling_Billboard"] = {}
		},
	["Maelstrom"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {2,4},

			["MultiScrolling_Billboard"] = {}
		},
	["Trypticon"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {2,4,6},

			["MultiScrolling_Billboard"] = {}
		},
	["Mornyl"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {2},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {},

			["MultiScrolling_Billboard"] = {}
		},
		["Silke"] = 
			{
				["Static_Billboard_Regular"] = {},
				["Static_Billboard_Banner"] = {1},

				["Scrolling_Billboard_Large"] = {},
				["Scrolling_Billboard_Long"] = {},
				["Scrolling_Billboard_Regular"] = {6,7,8,9,10,11,12,13},
				["Scrolling_Billboard_Short"] = {},

				["MultiScrolling_Billboard"] = {}
			},
	["Terrain"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {2},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {2,4,6},

			["MultiScrolling_Billboard"] = {}
		},
	["Ikku"] = 
		{
			["Static_Billboard_Regular"] = {1,2,3,4},
			["Static_Billboard_Banner"] = {2},

			["Scrolling_Billboard_Large"] = {},
			["Scrolling_Billboard_Long"] = {1,2,3},
			["Scrolling_Billboard_Regular"] = {1,2,3,4},
			["Scrolling_Billboard_Short"] = {2,4,6},

			["MultiScrolling_Billboard"] = {}
		},
	["Terminal"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {2},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {1,3,5},

			["MultiScrolling_Billboard"] = {}
		},
	["The Sky"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {},

			["MultiScrolling_Billboard"] = {2}
		},
	["Chug"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {1},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {},
			["Scrolling_Billboard_Short"] = {},

			["MultiScrolling_Billboard"] = {}
		},
	["Spacepop"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {1},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {5},
			["Scrolling_Billboard_Short"] = {},

			["MultiScrolling_Billboard"] = {}
		},
	["Nebula"] = 
		{
			["Static_Billboard_Regular"] = {},
			["Static_Billboard_Banner"] = {},

			["Scrolling_Billboard_Large"] = {},
			["Scrolling_Billboard_Long"] = {},
			["Scrolling_Billboard_Regular"] = {4,3,5},
			["Scrolling_Billboard_Short"] = {},

			["MultiScrolling_Billboard"] = {}
		},
}

local function DetermineType(Billboard)
	local billboardType = nil
	local billboardNumber = nil
	for x, v in pairs(Classifications) do
		if Billboard.Name:sub(1,#v) == v then
			billboardType = v
			billboardNumber = tonumber(Billboard.Name:sub(#v+1, #Billboard.Name))
		end
	end
	return billboardType, billboardNumber
end

local function ScrollBillboard(i, v, bType, bNumber)
	local lastAd = v:FindFirstChildOfClass("IntValue") 
	local timer = math.random(7,10)
	local onlyOne = true
	local newAd

	for _, random in pairs(v:GetChildren()) do
		if random:IsA("IntValue") and random~=lastAd then
			onlyOne = false
		end
	end

	if onlyOne then
		newAd = lastAd
		while true do
			wait(timer)
			AdEvent:FireAllClients(v.Name, bType, newAd.Value, lastAd.Value)
		end

	else

		while true do


			for _, random in pairs(v:GetChildren()) do
				if random:IsA("IntValue") and random~= lastAd then
					newAd = random

					AdEvent:FireAllClients(v.Name, bType, newAd.Value, lastAd.Value)
					wait(timer)
					lastAd = newAd
				end
			end
			wait()
		end

	end

end

local function MultiScrollBillboard(i, v, bType, bNumber)
	local lastAd = v:FindFirstChildOfClass("IntValue") 
	local timer = 20
	local onlyOne = true
	local newAd

	for _, random in pairs(v:GetChildren()) do
		if random:IsA("IntValue") and random~=lastAd then
			onlyOne = false
		end
	end

	if onlyOne then
		newAd = lastAd
		while true do
			wait((timer/10)-0.1)
			AdEvent:FireAllClients(v.Name, bType, lastAd.Value, nil, timer)
		end

	else

		while true do


			for _, random in pairs(v:GetChildren()) do
				if random:IsA("IntValue") and random~= lastAd then
					newAd = random

					wait((timer/10)-0.1)
					AdEvent:FireAllClients(v.Name, bType, lastAd.Value, nil, timer)
					lastAd = newAd

				end
			end
			wait()
		end

	end

end



local ActiveAds = {}

do
	for i, Billboard in pairs(Billboards:GetChildren()) do
		local billboardType = nil
		local billboardNumber = nil
		for x, v in pairs(Classifications) do
			if Billboard.Name:sub(1,#v) == v then
				billboardType = v
				billboardNumber = tonumber(Billboard.Name:sub(#v+1, #Billboard.Name))
			end
		end

		if billboardType and billboardNumber then 
			for Company, Table in pairs(AdsOwned) do

				local isAd = false
				for z, b in pairs(Table[billboardType]) do
					if b == billboardNumber then
						isAd = true
					end
				end
				if isAd then
					if #Ads[Company][billboardType] ~= nil or #Ads[Company][billboardType] ~= 0 then
						if ActiveAds[Billboard.Name] == nil then ActiveAds[Billboard.Name] = Billboard end
						for i = 1, #Ads[Company][billboardType], 1 do
							local succ, AdV = pcall(function() return Ads[Company][billboardType][i] end) 
							if succ then local AdVO = Instance.new("IntValue", Billboard)
								AdVO.Name = Company
								AdVO.Value = AdV
							else
								warn("screwed up on", Company)
							end
						end

					end
				end
			end
		end
	end
end

do
	for i, v in pairs(ActiveAds) do
		wait()
		spawn(function()
			local bType, bNumber = DetermineType(v)

			if bType == "Static_Billboard_Regular" then


				local Ad = v:FindFirstChildOfClass("IntValue") 

				AdEvent:FireAllClients(v.Name, bType, Ad.Value)

			elseif bType == "Static_Billboard_Banner" then

				local Ad = v:FindFirstChildOfClass("IntValue") 

				AdEvent:FireAllClients(v.Name, bType, Ad.Value)

			elseif bType == "Scrolling_Billboard_Large" then

				ScrollBillboard(i, v, bType, bNumber)

			elseif bType == "Scrolling_Billboard_Long" then

				ScrollBillboard(i, v, bType, bNumber)

			elseif bType == "Scrolling_Billboard_Regular" then

				ScrollBillboard(i, v, bType, bNumber)


			elseif bType == "Scrolling_Billboard_Short" then

				ScrollBillboard(i, v, bType, bNumber)

			elseif bType == "MultiScrolling_Billboard" then

				MultiScrollBillboard(i, v, bType, bNumber)

			end
		end)
	end
end

game.Players.PlayerAdded:Connect(function(player)

	for i, v in pairs(ActiveAds) do
		wait()
		spawn(function()
			local bType, bNumber = DetermineType(v)

			if bType == "Static_Billboard_Regular" or bType == "Static_Billboard_Banner" then


				local Ad = v:FindFirstChildOfClass("IntValue") 

				AdEvent:FireClient(player, v.Name, bType, Ad.Value)

			elseif bType == "StaticBanner" then

			end
		end)
	end

end)
	
	
return module
	
else
	return {}
	end