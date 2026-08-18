

script.Parent.OnServerEvent:Connect(function(player)
	if player:GetRankInGroup(2962831) >= 249 or player.Name == script.Player.Value then
		script.Parent.Parent:Destroy()
	end
end)

local Count = 180

if script.Parent.Parent:FindFirstChild("DirectionalArc") then
	local PlayerG = game.Players:FindFirstChild(script.Player.Value)
	PlayerG.CharacterAdded:Connect(function(char)
		script.Parent.Parent.DirectionalArc.Attachment1 = char:WaitForChild("HumanoidRootPart"):WaitForChild("ThrowableAttachment")
	end)
end	

if script.Parent.Parent:FindFirstChild("Ping") then Count = 3 
	
	spawn(function()
		local ping = script.Parent.Parent:FindFirstChild("Ping").ImageLabel
		while true do
			for i = -0.1, 0.1, 0.025 do
				wait(0.01)
				ping.Position = UDim2.new(0,0,i,0)
			end
			wait()
			for i = 0.1,-0.1, -0.025 do
				wait(0.01)
				ping.Position = UDim2.new(0,0,i,0)
			end
		end
	end)
	
end

while true do
	wait(1)
	Count = Count - 1
	script.TimeLeft.Value = Count
	local Player= game.Players:FindFirstChild(script.Player.Value)
	if not Player then script.Parent.Parent:Destroy() return end
	if Count <= 0 then script.Parent.Parent:Destroy() return end
end