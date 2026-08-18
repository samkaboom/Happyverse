local module = {}

local _RS = game:GetService("ReplicatedStorage")
local newFunction = Instance.new("RemoteFunction")
newFunction.Name = "D20"
newFunction.Parent = _RS

local InfoFolder = _RS:WaitForChild("Info")

newFunction.OnServerInvoke = function(player)
	if player.Character.Head:FindFirstChild("UI") then task.wait(1) return end
	local UI = script.UI:Clone()
	
	UI.Parent = player.Character.Head
	UI.Adornee = player.Character.Head
	UI.StudsOffsetWorldSpace = Vector3.new(0,(player.Character.Head.Size.Y/2) + 1.5, 0)
	for i = 1, 20, 1 do
		UI.TextLabel.Text = tostring(math.random(1,20))
		task.wait(0.1)
	end
	local result = tostring(math.random(1,20))
	UI.TextLabel.Text = result
	local Folder = InfoFolder:FindFirstChild(player.Name)
	if Folder then
		Folder.lastD20.Value = result
		task.wait(5)
		UI:Destroy()
		return result
	end
end


return module
