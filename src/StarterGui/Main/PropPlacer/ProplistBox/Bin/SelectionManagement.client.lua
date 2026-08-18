local bin = script.Parent
local rep = game:GetService("ReplicatedStorage")

local NeutralSize = script.NeutralSize
local ExpandedSize = script.ExpandedSize

local player = game.Players.LocalPlayer


local CtrlIsDown = false

local AmtSelected = {}
local AcessorieSelected = {}

game:GetService("UserInputService").InputBegan:Connect(function(input, gameprocessedEvent)
	
	if gameprocessedEvent == false then
		
		if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
			
			print("control down")
			CtrlIsDown = true
			
		end
		
	end
	
end)

game:GetService("UserInputService").InputEnded:Connect(function(input, gameprocessedEvent)
	if gameprocessedEvent == false then
		if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
			CtrlIsDown = false
			print("control up")
		end
	end
end)

script.Parent.CanvasPosition = Vector2.new(0, 1364.22)

local function RemoveFromTable(v)
	
	for i, x in ipairs(AmtSelected) do
		if x == v then
			table.remove(AmtSelected, i)
			table.remove(AcessorieSelected, i)
		end
	end
	
	for i, x in ipairs(AcessorieSelected) do
		if x == v then
			table.remove(AmtSelected, i)
			table.remove(AcessorieSelected, i)
		end
	end
	
end

script.Parent.Parent.Parent.Parent:WaitForChild("propDelete").Event:Connect(function(value)
	
	RemoveFromTable(value)
	print("Checked", value)

end)

script.Parent.Parent.Parent.Parent:WaitForChild("propDeleteAll").Event:Connect(function(value)

	table.clear(AmtSelected)
	table.clear(AcessorieSelected)
	
end)


local function SetAllClosed(x)
	warn("Setting all closed")
	for i, v in pairs(bin:GetChildren()) do
		if v:IsA("TextButton") and v~=x then
			if v.ItemPack.Value == false then
			v.AccessorySelected.Value = false
			v.BackgroundColor3 = Color3.fromRGB(20,20,39)
				v:TweenSize(UDim2.new(1,0,0.1, NeutralSize.Value), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.3, true)
				RemoveFromTable(v)
			else
				v.AccessorySelected.Value = false
				v.BackgroundColor3 = Color3.fromRGB(15, 39, 19)
				v:TweenSize(UDim2.new(1,0,0.1, NeutralSize.Value), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.3, true)
				RemoveFromTable(v)
			end
		end
	end
end

local function HighlightAccessory(v)

	if v.AccessoryAssociated.Value.Center:FindFirstChildOfClass("SelectionBox") then return end
	local SelectionBox = Instance.new("SelectionBox")
	SelectionBox.Transparency = 0.3
	SelectionBox.LineThickness = 0.05
	SelectionBox.Color3 = Color3.new(0.54902, 0, 1)
	SelectionBox.Parent = v.AccessoryAssociated.Value.PrimaryPart
	SelectionBox.Adornee = v.AccessoryAssociated.Value.PrimaryPart
	
end

local function RemoveAccessoryHighlight(v)
	if v.AccessoryAssociated.Value.PrimaryPart:FindFirstChildOfClass("SelectionBox") then
		v.AccessoryAssociated.Value.PrimaryPart:FindFirstChildOfClass("SelectionBox"):Destroy()
	end
end



function drawPath(Line, P1, P2)
	local Size = workspace.CurrentCamera.ViewportSize
	local startX, startY = P1.AbsolutePosition.X, P1.AbsolutePosition.Y
	warn(startX, startY)
	local endX, endY = P2.X, P2.Y
	local startVector = Vector2.new(startX, startY)
	local endVector = Vector2.new(endX, endY)
	local Distance = (startVector - endVector).Magnitude
	Line.AnchorPoint = Vector2.new(0.5, 0.5)
	Line.Size = UDim2.new(0, Distance, 0, 3)
	Line.Position = UDim2.new(0, (startX + endX) / 2, 0, (startY + endY) / 2)
	Line.Rotation = math.atan2(endY - startY, endX - startX) * (180 / math.pi)
end

local function IndexButton(v)
	
	v.MouseEnter:Connect(function()
		
		if v.AccessorySelected.Value == false then

			v.Hovered.Value = true
			v:TweenSize(UDim2.new(1,0,0.14,ExpandedSize.Value), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)			
			
		end	
		
		HighlightAccessory(v)

	end)
	
	v.MouseLeave:Connect(function()
		
		if v.AccessorySelected.Value == false then
			v.Hovered.Value = false
			v:TweenSize(UDim2.new(1,0,0.1, NeutralSize.Value), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.3, true)
		end
		
		RemoveAccessoryHighlight(v)

	end)
	
	v.MouseButton1Click:Connect(function()
		warn(CtrlIsDown)
		if CtrlIsDown == false then SetAllClosed(v) end --

		if v.AccessorySelected.Value == true then
			
			if v.ItemPack.Value == false then
				
				v.AccessorySelected.Value = false
				v.BackgroundColor3 = Color3.fromRGB(20,20,39)
				v:TweenSize(UDim2.new(1,0,0.1, NeutralSize.Value), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.3, true)
				RemoveFromTable(v)
				
			else
				
				v.AccessorySelected.Value = false
				v.BackgroundColor3 = Color3.fromRGB(9, 69, 134)
				v:TweenSize(UDim2.new(1,0,0.1, NeutralSize.Value), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.3, true)
				RemoveFromTable(v)
				
			end
			
			game.Players.LocalPlayer.PlayerGui:WaitForChild("Main").propTable:Fire(AcessorieSelected)
			
		else
			
			if v.ItemPack.Value == false then
				
				v.AccessorySelected.Value = true
				--v.SlotFrame.Visible = true
				v.BackgroundColor3 = Color3.fromRGB(69, 69, 134)
				v:TweenSize(UDim2.new(1,0,0.14,ExpandedSize.Value), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)
				table.insert(AmtSelected, v)
				table.insert(AcessorieSelected, v.AccessoryAssociated.Value)
				
			else
				
				v.AccessorySelected.Value = true
				--v.SlotFrame.Visible = true
				v.BackgroundColor3 = Color3.fromRGB(25, 66, 31)
				v:TweenSize(UDim2.new(1,0,0.14,ExpandedSize.Value), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)
				table.insert(AmtSelected, v)
				table.insert(AcessorieSelected, v.AccessoryAssociated.Value)
				
			end
			
			game.Players.LocalPlayer.PlayerGui.Main.propTable:Fire(AcessorieSelected)

		end

		if #AmtSelected == 0 then
			game.Players.LocalPlayer.PlayerGui.Main.NoMoreSelected:Fire("none")
		else
			game.Players.LocalPlayer.PlayerGui.Main.NoMoreSelected:Fire("some")
		end
	end)
	
	
	
end


wait()

for i, v in pairs(bin:GetChildren()) do
	if v:IsA("TextButton") then
		IndexButton(v)
	end
end

bin.ChildRemoved:Connect(function(v)
	
end)

bin.ChildAdded:Connect(IndexButton)

