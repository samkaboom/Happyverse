local module = {}

local HttpService = game:GetService("HttpService")
local MarketPlaceService = game:GetService("MarketplaceService")
local PlaceId = game.PlaceId
local HelpRoleID = tostring(1123390121480298506)

local newPing = Instance.new("RemoteEvent")
newPing.Name = "Help"
newPing.Parent = game:GetService("ReplicatedStorage")


local OurPlaceName

repeat
	pcall(function()
		OurPlaceName = MarketPlaceService:GetProductInfo(PlaceId).Name
	end)
	wait(1)
until OurPlaceName



local function POSTToDiscord(SendingUser, playerDiscord, Comment)
print("Submitting new help request:", SendingUser, playerDiscord, Comment)
	--local URL = "https://discord.com/api/webhooks/1044888658110578748/KVG2_9gk8gMgVhm1hGUeKDFByt8Dyko45ZIWZZF6i8bYjlWY9aSG-VwZti9hQTis95k_"
	-- https://discord.com/api/webhooks/1143723850165665913/slyHZnM2Plx-pTndACLzu_8D2D7YrLXI1G7_KIM0fDuggZbWH_ROajE6IQrXebar6f45
	local URL = "https://hooks.hyra.io/api/webhooks/1143723850165665913/slyHZnM2Plx-pTndACLzu_8D2D7YrLXI1G7_KIM0fDuggZbWH_ROajE6IQrXebar6f45"
	local JSONTable

	local max = 1000
	Comment = Comment:sub(1,max)

		warn("Posting to discord in singular stack.")
		JSONTable = HttpService:JSONEncode(
			{
				["username"] = "The Moddinator",
				["content"] = "<@&1142682925381456015> \n **Server name: " .. OurPlaceName .. "** \n Player: " .. SendingUser.Name .. " \n Player Discord: @" .. playerDiscord .. " \n Comment:" .. Comment
			}
		)
	HttpService:PostAsync(URL, JSONTable, Enum.HttpContentType.ApplicationJson)
	

end


newPing.OnServerEvent:Connect(POSTToDiscord)


return module
