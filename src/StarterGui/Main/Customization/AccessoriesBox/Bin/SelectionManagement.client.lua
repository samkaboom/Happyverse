local bin = script.Parent

local NeutralSize = script.NeutralSize
local ExpandedSize = script.ExpandedSize
local MainGui = bin.Parent.Parent
local RestoreSelection = script:FindFirstChild("RestoreSelection") or Instance.new("BindableEvent")
RestoreSelection.Name = "RestoreSelection"
RestoreSelection.Parent = script


local CtrlIsDown = false

local AmtSelected = {}

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
			RemoveAccessoryHighlight(x)
			table.remove(AmtSelected, i)
			
		end
	end
	
end

local CurrentHighlightedAccessories = {}

local function OccludeHighlight(v)
	local Highlight = v.AccessoryAssociated.Value.Handle:FindFirstChildOfClass("Highlight")
	if Highlight then
		Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		Highlight.FillTransparency = 1
		Highlight.OutlineTransparency = 0.6
	end
end

local function TopHighlight(v)
	local Highlight = v.AccessoryAssociated.Value.Handle:FindFirstChildOfClass("Highlight")
	if Highlight then
		if Highlight.Enabled == false then Highlight.Enabled = true end
		Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		Highlight.FillTransparency = 0.65
		Highlight.OutlineTransparency = 0
	end
end

local function SetAllClosed(x)
	warn("Setting all closed")
	for i, v in pairs(bin:GetChildren()) do
		if v:IsA("TextButton") and v~=x then
			if v.ItemPack.Value == false then
			v.AccessorySelected.Value = false
			v.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
			v:TweenSize(UDim2.new(0.9,0,0,NeutralSize.Value), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.3, true)
				RemoveFromTable(v)
			else
				v.AccessorySelected.Value = false
				v.BackgroundColor3 = Color3.fromRGB(15, 39, 19)
				v:TweenSize(UDim2.new(0.9,0,0,NeutralSize.Value), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.3, true)
				RemoveFromTable(v)
			end
		end
	end
end

local function HighlightAccessory(v)
	local Highlight = v.AccessoryAssociated.Value.Handle:FindFirstChildOfClass("Highlight")
	if Highlight then Highlight.Enabled = true return end
	local SelectionBox = script.Highlight:Clone()
	SelectionBox.Parent = v.AccessoryAssociated.Value.Handle
	SelectionBox.Adornee = v.AccessoryAssociated.Value.Handle
	table.insert(CurrentHighlightedAccessories, SelectionBox)
end

local function SetAllHighlights(val : boolean)
	for i, v in pairs(CurrentHighlightedAccessories) do
		v.Enabled = val
	end
end

function RemoveAccessoryHighlight(v)
	
		local Highlight = v.AccessoryAssociated.Value.Handle:FindFirstChildOfClass("Highlight")
		if Highlight then
			Highlight.Enabled = false
			local index = table.find(CurrentHighlightedAccessories, Highlight)
			if index then
				table.remove(CurrentHighlightedAccessories, index)
			end
		end
		
	
end

function RemoveAllAccessoryHighlights(v)
	for i, v in pairs(CurrentHighlightedAccessories) do
		v.Enabled = false
	end
	table.clear(CurrentHighlightedAccessories)
end

local function SetButtonSelected(v, selected)
	v.AccessorySelected.Value = selected
	if selected then
		if v.ItemPack.Value == false then
			v.BackgroundColor3 = Color3.fromRGB(103, 103, 103)
		else
			v.BackgroundColor3 = Color3.fromRGB(25, 66, 31)
		end
		v:TweenSize(UDim2.new(0.95,0, 0, ExpandedSize.Value), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)
		if not table.find(AmtSelected, v) then
			table.insert(AmtSelected, v)
		end
		HighlightAccessory(v)
	else
		if v.ItemPack.Value == false then
			v.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
		else
			v.BackgroundColor3 = Color3.fromRGB(15, 39, 19)
		end
		v:TweenSize(UDim2.new(0.9,0,0,NeutralSize.Value), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.3, true)
		RemoveFromTable(v)
		RemoveAccessoryHighlight(v)
	end
end

RestoreSelection.Event:Connect(function(framesToSelect)
	RemoveAllAccessoryHighlights()
	for i, v in pairs(bin:GetChildren()) do
		if v:IsA("TextButton") then
			SetButtonSelected(v, false)
		end
	end

	for _, frame in ipairs(framesToSelect or {}) do
		if frame and frame.Parent == bin and frame:IsA("TextButton") then
			SetButtonSelected(frame, true)
		end
	end

	if #AmtSelected == 0 then
		game.Players.LocalPlayer.PlayerGui.Main.NoMoreSelected:Fire("none")
	else
		game.Players.LocalPlayer.PlayerGui.Main.NoMoreSelected:Fire("some")
	end
end)



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
		print ("enter")
		debug.profilebegin("enterMouseButton")
		if v.AccessorySelected.Value == false then
			
			v.Hovered.Value = true
			v:TweenSize(UDim2.new(0.95,0,0,ExpandedSize.Value), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)
			--local vector, onscreen = workspace.CurrentCamera:WorldToScreenPoint(v.AccessoryAssociated.Value.Handle.Position)
		end
			HighlightAccessory(v)
			TopHighlight(v)
		debug.profileend()
	end)
	v.MouseLeave:Connect(function()
		print("exit")
		debug.profilebegin("exitMouseButton")
		if v.AccessorySelected.Value == false then
			v.Hovered.Value = false
			v:TweenSize(UDim2.new(0.9,0,0, NeutralSize.Value), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.3, true)
			
		end
		if not table.find(AmtSelected, v) then
			RemoveAccessoryHighlight(v)
		else
			OccludeHighlight(v)
		end
		debug.profileend()
	end)
	v.MouseButton1Click:Connect(function()
		warn(CtrlIsDown)
		if CtrlIsDown == false then SetAllClosed(v); RemoveAllAccessoryHighlights(); end --
		if v.AccessorySelected.Value == true then
			if v.ItemPack.Value == false then
				v.AccessorySelected.Value = false
				v.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
				v:TweenSize(UDim2.new(0.9,0,0,NeutralSize.Value), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.3, true)
				RemoveFromTable(v)
				RemoveAccessoryHighlight(v)
			else
				v.AccessorySelected.Value = false
				v.BackgroundColor3 = Color3.fromRGB(15, 39, 19)
				v:TweenSize(UDim2.new(0.9,0,0,NeutralSize.Value), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.3, true)
				RemoveFromTable(v)
				
			end
			
		else 
			if v.ItemPack.Value == false then
				v.AccessorySelected.Value = true
				v.BackgroundColor3 = Color3.fromRGB(103, 103, 103)
				v:TweenSize(UDim2.new(0.95,0, 0, ExpandedSize.Value), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)
				table.insert(AmtSelected, v)
				HighlightAccessory(v)
			else
				v.AccessorySelected.Value = true
				v.BackgroundColor3 = Color3.fromRGB(25, 66, 31)
				v:TweenSize(UDim2.new(0.95,0, 0, ExpandedSize.Value), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)
				table.insert(AmtSelected, v)
				
			end
		end
		
		if #AmtSelected == 0 then
			RemoveAllAccessoryHighlights()
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

MainGui:GetPropertyChangedSignal("Visible"):Connect(function()
	local val = MainGui.Visible
	if val == false then
		SetAllHighlights(false)
	else
		SetAllHighlights(true)
	end
end)

bin.ChildAdded:Connect(IndexButton)
