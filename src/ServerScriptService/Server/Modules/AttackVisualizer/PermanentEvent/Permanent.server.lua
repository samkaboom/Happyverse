

script.Parent.OnServerEvent:Connect(function(player)
	if player:GetRankInGroup(2962831) >= 249 or player.Name == script.Player.Value then
		script.Parent.Parent:Destroy()
	end
end)

if script.Parent.Parent:FindFirstChild("DirectionalArc") then
	local PlayerG = game.Players:FindFirstChild(script.Player.Value)
	PlayerG.CharacterAdded:Connect(function(char)
		script.Parent.Parent.DirectionalArc.Attachment1 = char:WaitForChild("HumanoidRootPart"):WaitForChild("ThrowableAttachment")
	end)
end	
	
local Count = 1800

while true do
	wait(1)
	Count = Count - 1
	script.TimeLeft.Value = Count
	local Player= game.Players:FindFirstChild(script.Player.Value)
	if not Player then script.Parent.Parent:Destroy() return end
	
	if Player:GetRankInGroup(2962831) < 249 then
		
		if Count <= 0 then script.Parent.Parent:Destroy() return end
	else
		
	end
	
end