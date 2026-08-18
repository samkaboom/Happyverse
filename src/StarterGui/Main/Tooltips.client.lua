-- by ellis
-- it causes the little tooltip box to pop up whenever you hover your mouse over textbuttons. it uses two attributes within them, which are strings
-- AnchorType: Left, Right, TopLeft, TopRight (sets where the UI will appear in conjunction to the button to avoid the menu from being off-screen)
-- TooltipMessage: the message to display to the player

print("Tooltips running")
local Client = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local Mouse = Client:GetMouse()
local displayDeb = false

local TooltipUI = script:WaitForChild("Tooltip")
local TooltipMsgBox = TooltipUI:WaitForChild("displayText")

local UIHovering = nil
local deb = false

local lastTrig = tick()

local FrameConnection = nil

local function SpawnUI(msg, AnchorType)
	lastTrig = tick()
	if deb == true then return end
	deb = true
	if FrameConnection then FrameConnection:Disconnect(); FrameConnection = nil end
	TooltipMsgBox.Text = msg
	
	if AnchorType == "Left" then
		TooltipUI.AnchorPoint = Vector2.new(1,0)
	elseif AnchorType == "Right" then
		TooltipUI.AnchorPoint = Vector2.new(0,0)
	elseif AnchorType == "TopLeft" then
		TooltipUI.AnchorPoint = Vector2.new(1,1)
	elseif AnchorType == "TopRight" then
		TooltipUI.AnchorPoint = Vector2.new(0,1)
	end
	TooltipUI.Parent = Client.PlayerGui.Main
	TooltipUI.Visible = true
	FrameConnection = RS.RenderStepped:Connect(function()
		local posX, posY = Mouse.X, Mouse.Y
		TooltipUI.Position = UDim2.new(0,posX, 0, posY)
	end)
end

local function DespawnUI()
	if FrameConnection then FrameConnection:Disconnect(); FrameConnection = nil end
	TooltipUI.Visible = false
	TooltipUI.Parent = script
	deb = false
end

for i, UIObject in pairs(script.Parent:GetDescendants()) do
	if UIObject:IsA("TextButton") then
		local Message = UIObject:GetAttribute("TooltipMessage")
		local AnchorType = UIObject:GetAttribute("AnchorType")
		if Message ~= "" and AnchorType ~= "" then
			UIObject.MouseEnter:Connect(function()
				UIHovering = UIObject
				if (tick() - lastTrig) > 0.5 then task.wait(1); end
				if UIHovering then
					SpawnUI(Message, AnchorType)
				end
			end)
			UIObject.MouseLeave:Connect(function()
				UIHovering = nil
				lastTrig = tick()
				if not UIHovering then
					DespawnUI()
				end
				
			end)
		end
	end
end