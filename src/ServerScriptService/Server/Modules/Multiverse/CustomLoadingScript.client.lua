local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

-- Avoid toggling Roblox's PlayerList CoreGui; Studio can throw inside CoreGui.Settings.Pages.Players.
print("TRYING TO GET TP UI")
local customLoadingScreen = TeleportService:GetArrivingTeleportGui()
if customLoadingScreen then
	print("LOADING SCREEN: TP UI FOUND!")
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	ReplicatedFirst:RemoveDefaultLoadingScreen()
	customLoadingScreen.Parent = playerGui

	do
		local Fade = customLoadingScreen.Fade
		local Messages = {

			"You should have fun!"
			
		}
		Fade.msg.Text = Messages[math.random(1, #Messages)]
		Fade.Loading.Text = "Loading " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "..."
		spawn(function()
			local placename = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
			repeat 
				
				wait(0.3333)
				Fade.Loading.Text = "Loading " .. placename .. "."
				wait(0.333)
				Fade.Loading.Text = "Loading " .. placename .. ".."
				wait(0.333)
				Fade.Loading.Text = "Loading " .. placename .. "..."
			until
			Fade.Visible == false
		end)
		local t=Players.LocalPlayer:WaitForChild("Loaded", 60)
		print("WE'RE LOADED")
		if not t then print("Test failed") end

		for i = 0, 1, 0.01 do
			wait(0.01)
			Fade.BackgroundTransparency = i
			Fade.Loading.TextTransparency = i
			Fade.msg.TextTransparency = i
		end
		Fade.Visible = false
	end

	customLoadingScreen:Destroy()
end
