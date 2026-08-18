local player = game.Players.LocalPlayer
local Tool = script.Parent
local Mouse = player:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

repeat wait() until player.Character


local pi = math.pi
	local A = 0
	local S = false
	local n_DIST = 13
	local RS = 0.025
	local VAR_SIZE = Vector3.new(1,1,1)
	local _FORM = 0
	local FLOW = {}
	local FlyV
local FlyG
local FlyV2
local SPEED_2 = 75
local UpDownEvent1 = nil
local UpDownEvent2 = nil
local equipped = false

	
	-- I'm not going to dedicate this much fucking server RAM per person. OPTIMIZATION TIME! *batman theme*
	
	Tool.Equipped:Connect(function()
	S = true
	equipped = true
	local Fast = player.Character:FindFirstChild("Fast")
	local TORSO = player.Character.HumanoidRootPart
	local UnequipConnection
	local Humanoid = player.Character.Humanoid
		
		if TORSO:FindFirstChild("FlyV") then
			FlyV = TORSO:FindFirstChild("FlyV")
		else
			FlyV = Instance.new("BodyVelocity")
			FlyV.Name = "FlyV"
			FlyV.MaxForce = Vector3.new(0,99999999,0)
			FlyV.Velocity = Vector3.new(0,0,0)
			FlyV.Parent = TORSO
		end
		
		if TORSO:FindFirstChild("FlyG") then
			FlyG = TORSO:FindFirstChild("FlyG")
		else
			FlyG = Instance.new("BodyGyro")
			FlyG.Name = "FlyG"
			FlyG.MaxTorque = Vector3.new(0,0,0)
			FlyG.Parent = TORSO
		end
		
		
	UpDownEvent1 = UserInputService.InputBegan:Connect(function(input, gameprocessed)
		print("input down", gameprocessed)
		if gameprocessed == false then
			if input.KeyCode == Enum.KeyCode.LeftControl then
				if S == false and equipped == true then FlyV.Velocity = Vector3.new(0,-(SPEED_2/2),0) end
			elseif input.KeyCode == Enum.KeyCode.Space then
				if S == false and equipped == true then FlyV.Velocity = Vector3.new(0,(SPEED_2/2),0) end
			end
		end
	end)
	
	UpDownEvent2 = UserInputService.InputEnded:Connect(function(input, gameprocessed)
		print("input stopped", gameprocessed)
		if gameprocessed == false then
			if input.KeyCode == Enum.KeyCode.LeftControl then
				if S == false and equipped == true then 
					FlyV.Velocity = Vector3.new(0,0,0) 
				end
			elseif input.KeyCode == Enum.KeyCode.Space then
				if S == false and equipped == true then FlyV.Velocity = Vector3.new(0,0,0) end
			end
		end
	end)
		
		
		--actual start of the function
			Tool.Activated:Connect(function()
				S=true
				A=1
		
		
			FlyV.MaxForce = Vector3.new(99999999,99999999, 99999999)
			FlyG.MaxTorque = Vector3.new(9000,9000,9000)
			FlyG.CFrame = CFrame.new(TORSO.Position, Mouse.Hit.Position) * CFrame.fromEulerAnglesXYZ(math.rad(-90),0,0)
			FlyG.P = 15000
		
			local Origin = TORSO.Position
			local Direction = (Mouse.Hit.Position - Origin).Unit
			local params = RaycastParams.new()
			params.IgnoreWater = true
			params.FilterDescendantsInstances = {player.Character}
			local ray = workspace:Raycast(Origin, Direction*300, params) or {Position = Origin + Direction*300}


			
			FlyV.Velocity = CFrame.new(TORSO.Position, ray.Position).LookVector * SPEED_2
			
			local MouseConnect = Mouse.Move:Connect(function()
				if S == true then
					
					FlyG.maxTorque = Vector3.new(9000,9000,9000)
					FlyG.cframe = CFrame.new(TORSO.Position,Mouse.Hit.p) * CFrame.fromEulerAnglesXYZ(math.rad(-90),0,0)
					
					
					local Origin = TORSO.Position
					local Direction = (Mouse.Hit.Position - Origin).Unit
					local params = RaycastParams.new()
					params.IgnoreWater = true
					params.FilterDescendantsInstances = {player.Character}
					local ray = workspace:Raycast(Origin, Direction*300, params) or {Position = Origin + Direction*300}



					FlyV.Velocity = CFrame.new(TORSO.Position, ray.Position).LookVector * SPEED_2
					
					
					
				end
		end)
		
		spawn(function()
			local camera = workspace.CurrentCamera
			repeat
				wait(0.1)
				if S == false then
					FlyG.CFrame = camera.CoordinateFrame
				end
			until equipped == false
		end)
		
		Tool.Deactivated:Connect(function()
				S = false
				A = 0
				if TORSO:FindFirstChild("FloatV") then
					TORSO:FindFirstChild("FloatV"):Destroy()
				end
				MouseConnect:Disconnect()
				FlyV.Velocity = Vector3.new(0,0,0)
				FlyG.P = 3000
			
				FlyV.MaxForce = Vector3.new(0,5000,0)
		
				
				
				TORSO.Velocity = Vector3.new(0,0,0)
				FlyG.CFrame = CFrame.new(TORSO.Position,TORSO.Position + Vector3.new(TORSO.CFrame.lookVector.x,0,TORSO.CFrame.lookVector.z))
				wait(1)
			end)
			end)
			UnequipConnection = Tool.Unequipped:Connect(function()
				
		S = false
		equipped = false
				A = 0
				FlyV:Destroy()
		UnequipConnection:Disconnect()
		UpDownEvent1:Disconnect()
		UpDownEvent2:Disconnect()
				FlyG:Destroy()
				if TORSO:findFirstChild("FlyG") ~= nil then
					TORSO:findFirstChild("FlyG"):Destroy()
				end
				if TORSO:findFirstChild("FlyV") ~= nil then
					TORSO:findFirstChild("FlyV"):Destroy()
				end
				
				
			end)
			
			
	
	
	
			
		end)
	

	
	

--Events

	
			
