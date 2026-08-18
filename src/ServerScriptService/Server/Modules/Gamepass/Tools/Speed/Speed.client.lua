-- made by infiniteyield

local Tool = script.Parent
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local UserInputService = game:GetService("UserInputService")
local PlayerGui = Player:WaitForChild("PlayerGui")

local Mouse = Player:GetMouse()

local equipped = false
local event

local speed = script:WaitForChild("speed"):Clone()


Tool.Equipped:Connect(function()
	speed.Parent = PlayerGui
	equipped = true
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if not equipped then return end
	local Humanoid = Character:WaitForChild("Humanoid")
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Humanoid.WalkSpeed = math.clamp(Humanoid.WalkSpeed + 2, 1, 100)
		speed.label.Text = "Speed: "..Humanoid.WalkSpeed.. " | LMB to increase, RMB to decrease"
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		Humanoid.WalkSpeed = math.clamp(Humanoid.WalkSpeed - 2, 1, 100)
		speed.label.Text = "Speed: "..Humanoid.WalkSpeed.. " | LMB to increase, RMB to decrease"
	end
	
end)


Tool.Unequipped:Connect(function()
	equipped = false
	speed.Parent = script
	Character.Humanoid.WalkSpeed = 16
end)