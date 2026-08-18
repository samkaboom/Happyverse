local module = {}

print("Attack Visualizer online.")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VisualizerEvent = Instance.new("RemoteEvent")
VisualizerEvent.Name = "AttackVisualizer"
VisualizerEvent.Parent = ReplicatedStorage

local ActiveVisualizations = Instance.new("Folder")
ActiveVisualizations.Name = "ActiveVisualizations"
ActiveVisualizations.Parent = workspace

local Assets = script:WaitForChild("Assets")

local TextService = game:GetService("TextService")

VisualizerEvent.OnServerEvent:Connect(function(Player, Type, AssetName, Color, CFrameUsed, Size, InputtedText, PlayerCentric, GivenCFrame)
	print("Visualization:", Player, Type, AssetName, Color, CFrameUsed, Size, InputtedText)
	-- Type can be either "Temporary" or "Permanent"
	-- Mode is either AOE, AtoB, Throwable or Ping
	-- AssetName is the name of the Asset being used
	-- Color is the color of the asset used
	-- CFrameUsed is the CFrame of the Asset
	-- Size is the size like
	-- InputtedText is the text the player wants to be displayed.
	-- PlayerCentric -- should be attached to the player, AOE only
	
	local CurrentOnes = 0
	local len = Player.Name:len()
	for _, v in ActiveVisualizations:GetChildren() do
		if v.Name:sub(1, len) == Player.Name then
			CurrentOnes += 1
		end
	end
	
	
	if CurrentOnes > 4 then
		Player:Kick("Exploiting")
	end
	
	if AssetName == "AOEPull" or AssetName == "AOEArea" or AssetName == "AOEPush" then
		Size = Vector3.new(math.clamp(Size.X, 0, 30), 0.25, math.clamp(Size.Z, 0, 30))
	elseif AssetName == "AtoBDirectional" then
		Size = Vector3.new(math.clamp(Size.X, 0, 15), math.clamp(Size.Y, 0, 15), math.clamp(Size.Z, 0, 30))
	elseif AssetName == "Throwable" then
		Size = Vector3.new(math.clamp(Size.X, 0, 15), math.clamp(Size.Y, 0, 15), math.clamp(Size.Z, 0, 15))
	elseif AssetName == "Ping" then
		Size = Vector3.new(math.clamp(Size.X, 0, 1), math.clamp(Size.Y, 0, 1), math.clamp(Size.Z, 0, 1))
	end
	
	local AssetToUse = Assets:FindFirstChild(AssetName):Clone()
	AssetToUse.Name = Player.Name .. "'s visualization"
	
	AssetToUse.CFrame = CFrameUsed
	AssetToUse.Size = Size
	
	if PlayerCentric then
		if AssetName == "AOEPull" or AssetName == "AOEArea" or AssetName == "AOEPush" then
			local Weld = Instance.new("Weld")
			Weld.Part0 = Player.Character.HumanoidRootPart
			Weld.Part1 = AssetToUse
			Weld.C0 = GivenCFrame:Inverse()
			Weld.C1 = CFrameUsed:Inverse()
			AssetToUse.Anchored = false
			Weld.Parent = AssetToUse
		end
	end		
			
	if AssetName == "AOEPull" or AssetName == "AOEPush" then
		local CurrentWidth = AssetToUse.Size.X
		local CornerTakeoff = (CurrentWidth/2)-((CurrentWidth/2)/4)
		AssetToUse.Back.Position = Vector3.new(0,-0.5, CurrentWidth/2)
		AssetToUse.Front.Position = Vector3.new(0,-0.5, -(CurrentWidth/2))
		AssetToUse.Left.Position = Vector3.new(-(CurrentWidth/2),-0.5, 0)
		AssetToUse.Right.Position = Vector3.new(CurrentWidth/2,-0.5, 0)
		AssetToUse.BackRight.Position = Vector3.new(CornerTakeoff, -0.5, CornerTakeoff)
		AssetToUse.BackLeft.Position = Vector3.new(-CornerTakeoff, -0.5, CornerTakeoff)
		AssetToUse.FrontRight.Position = Vector3.new(CornerTakeoff, -0.5, -CornerTakeoff)
		AssetToUse.FrontLeft.Position = Vector3.new(-CornerTakeoff, -0.5, -CornerTakeoff)
	elseif AssetName == "AtoBDirectional" then
		AssetToUse.Back.Position = Vector3.new(0,0,AssetToUse.Size.Z/2)
		AssetToUse.Front.Position = Vector3.new(0,0,-(AssetToUse.Size.Z/2))
		AssetToUse.DirectionalStraight.TextureLength = AssetToUse.Size.Z/2
		AssetToUse.DirectionalStraight.Width0 = AssetToUse.Size.X
		AssetToUse.DirectionalStraight.Width1 = AssetToUse.Size.Y
	elseif AssetName == "Throwable" then
		AssetToUse.DirectionalArc.Attachment1 = Player.Character.HumanoidRootPart:WaitForChild("ThrowableAttachment")
		AssetToUse.DirectionalArc.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color), ColorSequenceKeypoint.new(1, Color)})
	elseif AssetName == "Ping" then
			AssetToUse.Ping.ImageLabel.ImageColor3 = Color
		
	end
	
	--[[for i, v in pairs(AssetToUse:GetChildren()) do
		if v:IsA("Beam") then
			v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color), ColorSequenceKeypoint.new(1, Color)})
		end
	end--]]
	
	AssetToUse.Color = Color
	

	
	if Type == "Temporary" then
		local c = script.TemporaryEvent:Clone()
		c.Temporary.Player.Value = Player.Name
		c.Parent = AssetToUse
		c.Temporary.Disabled = false
	elseif Type == "Permanent" then
		local c = script.PermanentEvent:Clone()
		c.Permanent.Player.Value = Player.Name
		c.Parent = AssetToUse
		c.Permanent.Disabled = false
	end
	
	if InputtedText then
		spawn(function()
			local Result = TextService:FilterStringAsync(InputtedText, Player.UserId, Enum.TextFilterContext.PublicChat)
			if Result then
				local RealText = Result:GetNonChatStringForBroadcastAsync()
				local c = script.DisplayText:Clone()
				c.text.Text = RealText
				c.Parent = AssetToUse
				c.Adornee = AssetToUse
				if AssetName ~= "AOEArea" or AssetName ~= "AOEPull" or AssetName ~= "AOEPush" then
					c.StudsOffsetWorldSpace = Vector3.new(0,-2,0)
				end
			end
		end)
		
	end
	
	local human = Instance.new("Humanoid")
	human.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	human.Parent = AssetToUse
	
	AssetToUse.Parent = ActiveVisualizations
	
	return true
end)

return module
