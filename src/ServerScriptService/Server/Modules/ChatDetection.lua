local module = {}

print("Hello world!")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isTyping = Instance.new("RemoteEvent")
isTyping.Name = "isTyping"
isTyping.Parent = ReplicatedStorage

isTyping.OnServerEvent:Connect(function(client, typing)
	if type(typing) == "boolean" then
		if typing == false then
			if client.Character then
				local UI = client.Character:FindFirstChild("TypingGui")
				if UI then
					UI:Destroy()
				end
			end
		else
			if client.Character then
				local UIClone = script.TypingGui:Clone()
				UIClone.Parent = client.Character
				UIClone.Adornee = client.Character.Head
			end
		end
	end
end)

return module
