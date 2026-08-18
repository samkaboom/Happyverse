-- distance based and sight-based rendering of clients

local mode = true
local safe = false
-- 
local Client = game.Players.LocalPlayer
repeat task.wait() until Client.Character; local Character = Client.Character

local _RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local RenderDistance = 50
local InnerRenderDistance = 75
local Camera = workspace.CurrentCamera

local SightRaycastParams = RaycastParams.new()

SightRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
SightRaycastParams.IgnoreWater = true

local tblOfCharacters = {}

local function TweenIt(object : BasePart, Property : string, Goal : number)
	
	local goal = {}; goal[Property] = Goal
	local Tween = TweenService:Create(object, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
	Tween:Play()
end

local function SetTransparency(Part : BasePart, Value : number)
	
	TweenIt(Part, "LocalTransparencyModifier", Value)
	
	return
end

local function find(tbl : {}, val : {})
	for i, v in ipairs(tbl) do
		if v == val then
			return i
		end
	end
end



local function SetCharacterOpaque(character : Model)
	print(character.Name, "setting opaque")
	for i, p in pairs(character:GetDescendants()) do
		if p:IsA("BasePart") or p:IsA("MeshPart") or p:IsA("UnionOperation") then
			
				if p.LocalTransparencyModifier == 0 then break end
				SetTransparency(p, 0)
		
		end
	end
	tblOfCharacters[character.Name] = nil
end

local function SetCharacterTransparent(character : Model)
	print(character.Name, "setting transparent")
	for i, p in pairs(character:GetDescendants()) do
		if p:IsA("BasePart") or p:IsA("MeshPart") or p:IsA("UnionOperation") then
		
				if p.LocalTransparencyModifier == 1 then break end
				SetTransparency(p, 1)
		
		end
	end
	tblOfCharacters[character.Name] = character
end

local function CreatePlayerTable(plrs : {}, plr : Player)
	local tbl = {}
	for i, v in pairs(plrs) do
		if v.Character ~= plr then
			table.insert(tbl, v.Character)
		end
	end
	return tbl
end

do
	
	while true do
		
		print("mode:", mode)
			local plrs = game.Players:GetChildren()
		local success, err = pcall(function()
			if mode then
				safe = false
				
				local startOrigin = Camera.CFrame.Position
			
				for i, character in pairs(plrs) do
					repeat task.wait() until character.Character
					character = character.Character
					if character ~= Character then
						local endOrigin = character.HumanoidRootPart.Position
						local rayDirection = (endOrigin - startOrigin)
						local tbl = CreatePlayerTable(plrs, character)
						SightRaycastParams.FilterDescendantsInstances = tbl
						local raycastResult = workspace:Raycast(startOrigin, rayDirection, SightRaycastParams)

						if raycastResult then
							-- part in the way
							
							if raycastResult.Instance:FindFirstAncestor(character.Name) then
								if tblOfCharacters[character.Name] ~= nil then
									if #plrs > 60 then
										_RS.RenderStepped:Wait()
									end
									SetCharacterOpaque(character)
								end

							else
								if rayDirection.magnitude > InnerRenderDistance then
									if tblOfCharacters[character.Name] == nil then
										if #plrs > 60 then
											_RS.RenderStepped:Wait()
										end
										SetCharacterTransparent(character)

									end
								end
							end
						end
					end
				end				
				safe = true
			end
			safe = true
		end)
		if not success then safe = true; warn(err) end
		
		task.wait(0.1)
	
	end
end




