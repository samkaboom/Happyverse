--[[

██████╗░██████╗░░█████╗░██████╗░  ██████╗░██╗░░░░░░█████╗░░█████╗░███████╗██████╗░
██╔══██╗██╔══██╗██╔══██╗██╔══██╗  ██╔══██╗██║░░░░░██╔══██╗██╔══██╗██╔════╝██╔══██╗
██████╔╝██████╔╝██║░░██║██████╔╝  ██████╔╝██║░░░░░███████║██║░░╚═╝█████╗░░██████╔╝
██╔═══╝░██╔══██╗██║░░██║██╔═══╝░  ██╔═══╝░██║░░░░░██╔══██║██║░░██╗██╔══╝░░██╔══██╗
██║░░░░░██║░░██║╚█████╔╝██║░░░░░  ██║░░░░░███████╗██║░░██║╚█████╔╝███████╗██║░░██║
╚═╝░░░░░╚═╝░░╚═╝░╚════╝░╚═╝░░░░░  ╚═╝░░░░░╚══════╝╚═╝░░╚═╝░╚════╝░╚══════╝╚═╝░░╚═╝

░██╗░░░░░░░██╗██████╗░██╗████████╗████████╗███████╗███╗░░██╗  ██████╗░██╗░░░██╗  ██████╗░██╗░░██╗░░██╗██╗░█████╗░
░██║░░██╗░░██║██╔══██╗██║╚══██╔══╝╚══██╔══╝██╔════╝████╗░██║  ██╔══██╗╚██╗░██╔╝  ██╔══██╗██║░██╔╝░██╔╝██║██╔═══╝░
░╚██╗████╗██╔╝██████╔╝██║░░░██║░░░░░░██║░░░█████╗░░██╔██╗██║  ██████╦╝░╚████╔╝░  ██████╦╝█████═╝░██╔╝░██║██████╗░
░░████╔═████║░██╔══██╗██║░░░██║░░░░░░██║░░░██╔══╝░░██║╚████║  ██╔══██╗░░╚██╔╝░░  ██╔══██╗██╔═██╗░███████║██╔══██╗
░░╚██╔╝░╚██╔╝░██║░░██║██║░░░██║░░░░░░██║░░░███████╗██║░╚███║  ██████╦╝░░░██║░░░  ██████╦╝██║░╚██╗╚════██║╚█████╔╝
░░░╚═╝░░░╚═╝░░╚═╝░░╚═╝╚═╝░░░╚═╝░░░░░░╚═╝░░░╚══════╝╚═╝░░╚══╝  ╚═════╝░░░░╚═╝░░░  ╚═════╝░╚═╝░░╚═╝░░░░░╚═╝░╚════╝░

]]--

local MAX_PROPS = 40

local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
warn("prop placer, waiting for propUI")
local propUI = script.Parent.Parent:WaitForChild("PropPlacer")
local propBin = propUI.PropBin.Bin
local propListBin = propUI.ProplistBox.Bin
local saveListBin = propUI.SaveSlots
local scrollingFrame = propBin
local searchBar = propBin.Parent.Naming.NameButton

--local DataStoreService = game:GetService("DataStoreService")
--local SlotSave = DataStoreService:GetDataStore("SlotSave")

local selectedProp = false
local moving = false
local rotating = false
local propFolder = ReplicatedStorage:WaitForChild("Prop", 5)
if not propFolder then
	warn("PropPlacer disabled: ReplicatedStorage.Prop is missing.")
	return
end
local currentProp = propFolder:WaitForChild("wovProp", 5)
if not currentProp then
	warn("PropPlacer disabled: ReplicatedStorage.Prop.wovProp is missing.")
	return
end
local propsPlacerInvoke = ReplicatedStorage:WaitForChild("PropPlacerInvoke")
local currentSelectedProp = {}

local requestType
local ctrlIsDown = false

local FocalPropPointPart = Instance.new("Part")
FocalPropPointPart.Transparency = 0.85
FocalPropPointPart.BrickColor = BrickColor.new("Royal purple")
FocalPropPointPart.Anchored = true
FocalPropPointPart.CanQuery = false
FocalPropPointPart.CanCollide = false
FocalPropPointPart.CanTouch = false
FocalPropPointPart.Size = Vector3.new(0.5, 0.5, 0.5)

local function TweenButtonClick(button) -- this is needed for all buttons, causes the click down and release animation/yielding

	if button:FindFirstChild("Slide") then
		script.Parent.ButtonSoundEffect:Play()
		button.Slide:TweenPosition(UDim2.new(0,0,0,0), "In", "Quad", 0.1, true)
		local tween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {["BackgroundColor3"] = Color3.fromRGB(0, 170, 255)})
		tween:Play()
		local con1
		local con2
		local res = false
		con1 = button.MouseButton1Up:Connect(function()
			con1:Disconnect()
			con2:Disconnect()
			con2 = nil
			con1 = nil
			res = true
		end)
		con2 = button.MouseLeave:Connect(function()
			con1:Disconnect()
			con2:Disconnect()
			con2 = nil
			con1 = nil
			res = false
		end)
		repeat wait() until con1 == nil and con2 == nil
		print(button.Name, "Result!", res)
		button.Slide:TweenPosition(UDim2.new(0,0,-0.1,0), "Out", "Quad", 0.1, true)
		local tween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["BackgroundColor3"] = Color3.fromRGB(255,255,255)})
		tween:Play()
		return  res
	end

end

-- Input handling
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftControl then
		ctrlIsDown = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftControl then
		ctrlIsDown = false
	end
end)


local module = {}

	function module.PropListClone()
	
		-- Loop through the current props and add them to the prop bin
		for _, prop in ipairs(currentProp:GetChildren()) do
			if prop:IsA("Model") then
				local clone = script.Parent.PropsTemplate:Clone()
				clone.Parent = propBin
				clone.propName.Text = prop.Name
				clone.AccessoryAssociated.Value = prop
			
				clone.SlotFrame.Save.MouseButton1Down:Connect(function()
					requestType = "Clone"
					propsPlacerInvoke:InvokeServer(requestType, clone.AccessoryAssociated.Value)
				end)
			
			end
		end
	
	end


	function UpdateInputOfSearchText()

		local InputText= string.upper(searchBar.Text)

		for _,button in pairs(scrollingFrame:GetChildren())do
			if button:IsA("TextButton")then
				if InputText == "" or string.find(string.upper(button.propName.Text),InputText)~=nil then
					button.Visible = true
				else
					button.Visible = false
				end
			end
		end

	end

	searchBar.Changed:Connect(UpdateInputOfSearchText)

	-- Iterate through children of propBin
	for _, child in pairs(propBin:GetChildren()) do
		if child:IsA("TextButton") then
			-- When save button is clicked, set requestType to "Clone" and invoke server
		child.SlotFrame.Save.MouseButton1Down:Connect(function()
			
				requestType = "Clone"
				propsPlacerInvoke:InvokeServer(requestType, child.AccessoryAssociated.Value)
		
			end)
		end
end

script.Parent.Parent.NoMoreSelected.Event:Connect(function(arg)
	
	print("Yo")
	
	if arg == "none" then
		for i, v in pairs(player.PlayerGui:GetChildren()) do
			-- Remove existing Handles or ArcHandles objects
			if v:IsA("Handles") or v:IsA("ArcHandles") then
				v:Destroy()
				FocalPropPointPart.Parent = nil
			end
		end
		moving = false
		rotating = false
	else
		
		for i, v in pairs(player.PlayerGui:GetChildren()) do
			-- Remove existing Handles or ArcHandles objects
			if v:IsA("Handles") or v:IsA("ArcHandles") then
				v:Destroy()
				FocalPropPointPart.Parent = nil
			end
		end

	end
	
end)

	script.Parent.Parent.propTable.Event:Connect(function(value)
		print(currentSelectedProp)	
	currentSelectedProp = value
		if currentSelectedProp == nil or #currentSelectedProp == 0 then
		moving = false
		rotating = false
		for i, v in pairs(player.PlayerGui:GetChildren()) do
			if v:IsA("Handles") or v:IsA("ArcHandles") then
				v:Destroy()
				FocalPropPointPart.Parent = nil
			end
		end
		end
	end)


	local function FindFocalPoint()
		local total = #currentSelectedProp
		local SumX = 0
		local SumY = 0
		local SumZ = 0
		for i, AccessoryTable in ipairs(currentSelectedProp) do
			SumX = AccessoryTable.PrimaryPart.Position.X + SumX
			SumY = AccessoryTable.PrimaryPart.Position.Y + SumY
			SumZ = AccessoryTable.PrimaryPart.Position.Z + SumZ
		end

		local Midpoint = Vector3.new(SumX/total, SumY/total, SumZ/total)
		warn("Focal point:", Midpoint)
		return Midpoint
	end

	local function GetRawCFrameData(FocalPointPart)

		local copy = {}

		for k, v in ipairs(currentSelectedProp) do
			copy[k] = {v.PrimaryPart.CFrame, v.PrimaryPart.CFrame:ToObjectSpace(FocalPointPart.CFrame)}
		end

		return copy

	end



	-- Function to handle the "Move" button click
	local function onMoveButtonClick()
	
		if currentSelectedProp then

			if #currentSelectedProp > 0 and moving == true and rotating == false then
			
				local res = TweenButtonClick(propUI.Move)

				for i, v in pairs(player.PlayerGui:GetChildren()) do
					-- Remove existing Handles or ArcHandles objects
					if v:IsA("Handles") or v:IsA("ArcHandles") then
						v:Destroy()
						FocalPropPointPart.Parent = nil
					end
				end

				local pos = FindFocalPoint()
				FocalPropPointPart.CFrame = CFrame.new(pos)
				FocalPropPointPart.Parent = game.Workspace

				local Change = CFrame.new(0, 0, 0)
				local handleProp = FocalPropPointPart

				-- Create a Handles object for the player to use to move the prop
				local moveHandles = Instance.new("Handles")
				moveHandles.Style = Enum.HandlesStyle.Movement
				moveHandles.Adornee = handleProp
				moveHandles.Parent = player.PlayerGui
				-- Store the current CFrame of the prop's PrimaryPart
				currentCFMV = moveHandles.Adornee.CFrame
				local tempCFMV = {}

				-- When the player drags the Handles object, update the position of the PrimaryPart
				moveHandles.MouseDrag:Connect(function (Face, Distance)
					local Change = CFrame.new(0, 0, 0)

					if Face == Enum.NormalId.Front then
						Change = CFrame.new(0, 0, -Distance)
					elseif Face == Enum.NormalId.Back then
						Change = CFrame.new(0, 0, Distance)
					elseif Face == Enum.NormalId.Top then
						Change = CFrame.new(0, Distance, 0)
					elseif Face == Enum.NormalId.Bottom then
						Change = CFrame.new(0, -Distance, 0)
					elseif Face == Enum.NormalId.Left then
						Change = CFrame.new(-Distance, 0, 0)
					elseif Face == Enum.NormalId.Right then
						Change = CFrame.new(Distance, 0, 0)
					end

					moveHandles.Adornee.CFrame = currentCFMV * Change

					for i, v in pairs(currentSelectedProp) do
						local newCF = FocalPropPointPart.CFrame
						local CF = newCF * tempCFMV[i][2]:Inverse()
						CF:ToObjectSpace(v.PrimaryPart.CFrame)
						v:SetPrimaryPartCFrame(CF)
					end
				end)

			moveHandles.MouseButton1Down:Connect(function ()
				
					currentCFMV = moveHandles.Adornee.CFrame
					tempCFMV = GetRawCFrameData(FocalPropPointPart)
				end)

				-- When the player releases the Handles object, update the current CFrame of the PrimaryPart
				moveHandles.MouseButton1Up:Connect(function ()
					currentCFMV = moveHandles.Adornee.CFrame
					table.clear(tempCFMV)

					for i, v in pairs(currentSelectedProp) do
						requestType = "Move"
						propsPlacerInvoke:InvokeServer(requestType, v, v.PrimaryPart.CFrame)
					end
				end)
			end

		end

	end

	local function onRotateButtonClick()

		if currentSelectedProp then

			if #currentSelectedProp > 0 and rotating == true and moving == false then
			
			
				local res = TweenButtonClick(propUI.Rotation)
			
				for i, v in pairs(player.PlayerGui:GetChildren()) do
					-- Remove existing Handles or ArcHandles objects
					if v:IsA("Handles") or v:IsA("ArcHandles") then
						v:Destroy()
						FocalPropPointPart.Parent = nil
					end
				end

				local pos = FindFocalPoint()
				FocalPropPointPart.CFrame = CFrame.new(pos)
				FocalPropPointPart.Parent = game.Workspace

				local handleProp = nil
				handleProp = currentSelectedProp

				-- Create an ArcHandles object for the player to use to rotate the prop
				local rotateHandles = Instance.new("ArcHandles")
				rotateHandles.Adornee = FocalPropPointPart
				rotateHandles.Parent = player.PlayerGui

				-- Store the current CFrame of the prop's PrimaryPart
				currentCFMV = rotateHandles.Adornee.CFrame
				local tempCFMV = {}

				-- When the player drags the ArcHandles object, update the rotation of the PrimaryPart
				rotateHandles.MouseDrag:Connect(function (Axis, RelativeAngle, Delta)
					local function AngleFromAxis(Axis, r)
						return Axis == Enum.Axis.X and { r, 0, 0 }
							or Axis == Enum.Axis.Y and { 0, r, 0 }
							or Axis == Enum.Axis.Z and { 0, 0, r }
					end

					rotateHandles.Adornee.CFrame = currentCFMV * CFrame.fromEulerAnglesXYZ(unpack(AngleFromAxis(Axis, RelativeAngle)))

					for i, v in pairs(currentSelectedProp) do
						local newCF = FocalPropPointPart.CFrame
						local CF = newCF * tempCFMV[i][2]:Inverse()
						CF:ToObjectSpace(v.PrimaryPart.CFrame)
						v:SetPrimaryPartCFrame(CF)
					end
				end)

				rotateHandles.MouseButton1Down:Connect(function ()
					currentCFMV = rotateHandles.Adornee.CFrame
					tempCFMV = GetRawCFrameData(FocalPropPointPart)
				end)

				-- When the player releases the Handles object, update the current CFrame of the PrimaryPart
				rotateHandles.MouseButton1Up:Connect(function ()
					currentCFMV = rotateHandles.Adornee.CFrame
					table.clear(tempCFMV)

					for i, v in pairs(currentSelectedProp) do
						requestType = "Rotate"
						propsPlacerInvoke:InvokeServer(requestType, v, v.PrimaryPart.CFrame)
					end
				end)
			end

		end

	end

	local function onPlayerPropChildAdded(child)
		-- Check if the added child has the same name as the current player
		if child.Name == player.Name then
			local playerProp = child

			-- Listen for when a child is added to the player's "PlayerProp" object
			playerProp.ChildAdded:Connect(function(prop)
				-- Check if the player has reached the maximum number of props allowed
				if #playerProp:GetChildren() <= MAX_PROPS then
					-- Clone a template object to create a new "prop" entry in the player's prop list
					local propEntry = script.Parent.PropsTemplate:Clone()
					propEntry.Parent = propListBin
					propEntry.propName.Text = prop:GetAttribute("propName")
					propEntry.AccessoryAssociated.Value = prop
				
					print("Added")
				
					propEntry.MouseButton1Up:Connect(function()

						onMoveButtonClick()
						onRotateButtonClick()
					
					end)

				end
			
			end)

			-- Listen for when a child is removed from the player's "PlayerProp" object
			playerProp.ChildRemoved:Connect(function(prop)
				for i,v in pairs(propListBin:GetChildren()) do
					if v:IsA("TextButton") and v.AccessoryAssociated.Value == prop then
						v:Destroy()
					end
				end
			end)
		
		end
	
	end

	if game.Workspace.PlayerProp:FindFirstChild(player.Name) then
	
		for i,v in pairs(game.Workspace.PlayerProp:FindFirstChild(player.Name):GetChildren()) do
		
			local propEntry = script.Parent.PropsTemplate:Clone()
			propEntry.Parent = propListBin
			propEntry.propName.Text = v:GetAttribute("propName")
			propEntry.AccessoryAssociated.Value = v
		
			propEntry.MouseButton1Up:Connect(function()

				onMoveButtonClick()
				onRotateButtonClick()

			end)
				
		end
	
		game.Workspace.PlayerProp[player.Name].ChildRemoved:Connect(function(prop)
			for i,v in pairs(propListBin:GetChildren()) do
				if v:IsA("TextButton") and v.AccessoryAssociated.Value == prop then
					v:Destroy()
				end
			end
		end)	
	
	end



	game.Workspace.PlayerProp.ChildAdded:Connect(onPlayerPropChildAdded)
	
	-- Function to handle the "Delete" button click
	local function onDeleteButtonClick(currentSelectedPropOverride)
		if currentSelectedPropOverride then
			
			-- Check if there is a currentSelectedProp
			if currentSelectedPropOverride and #game.Workspace.PlayerProp[player.Name]:GetChildren() <= MAX_PROPS then
			
				local res = TweenButtonClick(propUI:WaitForChild("Delete"))
				if not res then return end
				-- Remove any existing Handles or ArcHandles from PlayerGui
			
				for i, v in pairs(player.PlayerGui:GetChildren()) do
					if v:IsA("Handles") or v:IsA("ArcHandles") then
						v:Destroy()
						FocalPropPointPart.Parent = nil
					end
				end

				for i, v in pairs(currentSelectedPropOverride) do
					print(v)
					script.Parent.Parent.propDelete:Fire(v)
				end

				requestType = "Delete"
				propsPlacerInvoke:InvokeServer(requestType, currentSelectedPropOverride, currentCFMV)
				currentSelectedProp = {nil}
			end

	
	else
		-- Check if there is a currentSelectedProp
		if currentSelectedProp and #game.Workspace.PlayerProp[player.Name]:GetChildren() <= MAX_PROPS then
			
			local res = TweenButtonClick(propUI:WaitForChild("Delete"))
			if not res then return end

			-- Remove any existing Handles or ArcHandles from PlayerGui
			for i, v in pairs(player.PlayerGui:GetChildren()) do
				if v:IsA("Handles") or v:IsA("ArcHandles") then
					v:Destroy()
					FocalPropPointPart.Parent = nil
				end
			end

			for i, v in pairs(currentSelectedProp) do
				print(v)
				script.Parent.Parent.propDelete:Fire(v)
			end

			requestType = "Delete"
			propsPlacerInvoke:InvokeServer(requestType, currentSelectedProp, currentCFMV)
			currentSelectedProp = {nil}

		end

		
	end
end

	-- Function to handle the "Copy" button click
	local function onCopyButtonClick()
		-- Check if there is a currentSelectedProp
		if currentSelectedProp and #game.Workspace.PlayerProp[player.Name]:GetChildren() <= MAX_PROPS then
		
			local res = TweenButtonClick(propUI:WaitForChild("Copy"))
			if not res then return end

			-- Remove any existing Handles or ArcHandles from PlayerGui
			for i, v in pairs(player.PlayerGui:GetChildren()) do
				if v:IsA("Handles") or v:IsA("ArcHandles") then
					v:Destroy()
					FocalPropPointPart.Parent = nil
				end
			end

			-- Set the request type to "Copy"
			requestType = "Copy"
			-- Invoke the propsPlacerInvoke server function with the currentSelectedProp, requestType, and currentCFMV parameters
			propsPlacerInvoke:InvokeServer(requestType, currentSelectedProp, currentCFMV)
		end
	end

	-- Function to handle the "Rename" button click
	local function onRenameButtonClick()
		if currentSelectedProp then
			local res = TweenButtonClick(propUI:WaitForChild("Rename"))
			if not res then return end
		
			if propUI.RenameUI.Visible == true then
				propUI.RenameUI.Visible = false
			else
				propUI.RenameUI.Visible = true
			end
			
			propUI.RenameUI.Close.MouseButton1Up:Connect(function()
				propUI.RenameUI.Visible = false
			end)
		
			propUI.RenameUI.Insert.Enter.FocusLost:Connect(function()
			
				local c = propUI.RenameUI.Insert.Enter.Text
			
				for i,v in pairs(propUI.ProplistBox.Bin:GetChildren()) do
				
					if v:IsA("TextButton") then
					
						if v.AccessorySelected.Value == true then
						
							v.propName.Text = propUI.RenameUI.Insert.Enter.Text
						
						end
						
					end
				
				end
			
				-- Set the request type to "Rename"
				requestType = "Rename"
				-- Invoke the propsPlacerInvoke server function with the currentSelectedProp, requestType, and currentCFMV parameters
				propsPlacerInvoke:InvokeServer(requestType, currentSelectedProp, c)
						
			end)
			
		
		end
	end

	local function CloseSaveSlots()
		-- Loop through each child in the SaveSlots Bin
		for i, v in pairs(propUI.SaveSlots.Bin:GetChildren()) do
			if v:IsA("TextButton") then
				-- Check if the TextButton has a SlotFrame child
				if v:FindFirstChild("SlotFrame") then
					-- Destroy the SlotFrame
					v.SlotFrame:Destroy()
				end
			end	
		end
	end

	-- Loop through each child in the SaveSlots Bin
	for i, v in pairs(propUI.SaveSlots.Bin:GetChildren()) do
		if v:IsA("TextButton") then
			-- Check if the TextButton has a SlotFrame child
			if v:FindFirstChild("SlotFrame") then
				-- Destroy the SlotFrame
				v.SlotFrame:Destroy()
			end
		end	
	end


	for i, v in pairs(propUI.SaveSlots.Bin:GetChildren()) do
		if v:IsA("TextButton") then

			-- Connect the MouseButton1Down event for each TextButton
			v.MouseButton1Down:Connect(function()

				CloseSaveSlots()

				local c = script.Parent.SlotFrame:Clone()
				c.Parent = v

				-- Connect the MouseButton1Down event for the Save button
				c.Buttons.Save.MouseButton1Down:Connect(function()
				
					-- Show the naming interface
					c.Naming.Visible = true

					-- Connect the FocusLost event for the NameButton
					c.Naming.NameButton.FocusLost:Connect(function(enterPressed)

					if enterPressed then
						
							for i, v in pairs(player.PlayerGui:GetChildren()) do
								if v:IsA("Handles") or v:IsA("ArcHandles") then
									v:Destroy()
									FocalPropPointPart.Parent = nil
								end
							end
							-- Update the displayText with the entered name
						
							v.Slide.displayText.Text = c.Naming.NameButton.Text
							c.Naming.Visible = false
							c.Buttons.Visible = false
						
						
							print(v.Slide.displayText.Text)
							requestType = "Save"		
							propsPlacerInvoke:InvokeServer(requestType, v, v.Slide.displayText.Text)
						
						end

					end)

					-- Connect the MouseButton1Click event for the Close button in the naming interface
					c.Naming.Close.MouseButton1Click:Connect(function()
						c.Naming.Visible = false
						c.Buttons.Visible = false
					end)

				end)

				-- Connect the MouseButton1Down event for the Load button
				c.Buttons.Load.MouseButton1Down:Connect(function()

					-- Destroy any existing Handles or ArcHandles in the PlayerGui
					for i, v in pairs(player.PlayerGui:GetChildren()) do
						if v:IsA("Handles") or v:IsA("ArcHandles") then
							v:Destroy()
							FocalPropPointPart.Parent = nil
						end
					end

					c.Naming.Visible = false
					c.Buttons.Visible = false

					requestType = "Load"				
					propsPlacerInvoke:InvokeServer(requestType, v)

					script.Parent.Parent.propDeleteAll:Fire()

				end)

			end)

		end

	end


	propUI:WaitForChild("SaveSlots").Visible = true	

	propUI:WaitForChild("Move").MouseButton1Down:Connect(function()
		local res = TweenButtonClick(propUI.Move)
		if not res then return end
	
		if moving == true then
			
			for i, v in pairs(player.PlayerGui:GetChildren()) do
				if v:IsA("Handles") or v:IsA("ArcHandles") then
					v:Destroy()
					FocalPropPointPart.Parent = nil
				end
			end
					
			moving = false
			rotating = false
		
		elseif moving == false then
		
			for i, v in pairs(player.PlayerGui:GetChildren()) do
				if v:IsA("Handles") or v:IsA("ArcHandles") then
					v:Destroy()
					FocalPropPointPart.Parent = nil
				end
			end
		
			local pos = FindFocalPoint()
			FocalPropPointPart.CFrame = CFrame.new(pos)
			FocalPropPointPart.Parent = game.Workspace

			local Change = CFrame.new(0, 0, 0)
			local handleProp = FocalPropPointPart

			-- Create a Handles object for the player to use to move the prop
			local moveHandles = Instance.new("Handles")
			moveHandles.Style = Enum.HandlesStyle.Movement
			moveHandles.Adornee = handleProp
			moveHandles.Parent = player.PlayerGui
			-- Store the current CFrame of the prop's PrimaryPart
			currentCFMV = moveHandles.Adornee.CFrame
			local tempCFMV = {}

			-- When the player drags the Handles object, update the position of the PrimaryPart
			moveHandles.MouseDrag:Connect(function (Face, Distance)
				local Change = CFrame.new(0, 0, 0)

				if Face == Enum.NormalId.Front then
					Change = CFrame.new(0, 0, -Distance)
				elseif Face == Enum.NormalId.Back then
					Change = CFrame.new(0, 0, Distance)
				elseif Face == Enum.NormalId.Top then
					Change = CFrame.new(0, Distance, 0)
				elseif Face == Enum.NormalId.Bottom then
					Change = CFrame.new(0, -Distance, 0)
				elseif Face == Enum.NormalId.Left then
					Change = CFrame.new(-Distance, 0, 0)
				elseif Face == Enum.NormalId.Right then
					Change = CFrame.new(Distance, 0, 0)
				end

				moveHandles.Adornee.CFrame = currentCFMV * Change

				for i, v in pairs(currentSelectedProp) do
					local newCF = FocalPropPointPart.CFrame
					local CF = newCF * tempCFMV[i][2]:Inverse()
					CF:ToObjectSpace(v.PrimaryPart.CFrame)
					v:SetPrimaryPartCFrame(CF)
				end
			end)

			moveHandles.MouseButton1Down:Connect(function ()
				currentCFMV = moveHandles.Adornee.CFrame
				tempCFMV = GetRawCFrameData(FocalPropPointPart)
			end)

			-- When the player releases the Handles object, update the current CFrame of the PrimaryPart
			moveHandles.MouseButton1Up:Connect(function ()
				currentCFMV = moveHandles.Adornee.CFrame
				table.clear(tempCFMV)

				for i, v in pairs(currentSelectedProp) do
					requestType = "Move"
					propsPlacerInvoke:InvokeServer(requestType, v, v.PrimaryPart.CFrame)
				end
			end)
			
			moving = true
			rotating = false
		
		end	
	end)

	propUI:WaitForChild("Rotate").MouseButton1Down:Connect(function()
	local res = TweenButtonClick(propUI.Rotate)
	if not res then return end
		if rotating == true then
		
			for i, v in pairs(player.PlayerGui:GetChildren()) do
				if v:IsA("Handles") or v:IsA("ArcHandles") then
					v:Destroy()
					FocalPropPointPart.Parent = nil
				end
			end

		rotating = false
		moving = false
		
		elseif rotating == false then
		
			if currentSelectedProp then

				for i, v in pairs(player.PlayerGui:GetChildren()) do
					-- Remove existing Handles or ArcHandles objects
					if v:IsA("Handles") or v:IsA("ArcHandles") then
						v:Destroy()
						FocalPropPointPart.Parent = nil
					end
				end

				local pos = FindFocalPoint()
				FocalPropPointPart.CFrame = CFrame.new(pos)
				FocalPropPointPart.Parent = game.Workspace

				local handleProp = nil
				handleProp = currentSelectedProp

				-- Create an ArcHandles object for the player to use to rotate the prop
				local rotateHandles = Instance.new("ArcHandles")
				rotateHandles.Adornee = FocalPropPointPart
				rotateHandles.Parent = player.PlayerGui

				-- Store the current CFrame of the prop's PrimaryPart
				currentCFMV = rotateHandles.Adornee.CFrame
				local tempCFMV = {}

				-- When the player drags the ArcHandles object, update the rotation of the PrimaryPart
				rotateHandles.MouseDrag:Connect(function (Axis, RelativeAngle, Delta)
					local function AngleFromAxis(Axis, r)
						return Axis == Enum.Axis.X and { r, 0, 0 }
							or Axis == Enum.Axis.Y and { 0, r, 0 }
							or Axis == Enum.Axis.Z and { 0, 0, r }
					end

					rotateHandles.Adornee.CFrame = currentCFMV * CFrame.fromEulerAnglesXYZ(unpack(AngleFromAxis(Axis, RelativeAngle)))

					for i, v in pairs(currentSelectedProp) do
						local newCF = FocalPropPointPart.CFrame
						local CF = newCF * tempCFMV[i][2]:Inverse()
						CF:ToObjectSpace(v.PrimaryPart.CFrame)
						v:SetPrimaryPartCFrame(CF)
					end
				end)

				rotateHandles.MouseButton1Down:Connect(function ()
					currentCFMV = rotateHandles.Adornee.CFrame
					tempCFMV = GetRawCFrameData(FocalPropPointPart)
				end)

				-- When the player releases the Handles object, update the current CFrame of the PrimaryPart
				rotateHandles.MouseButton1Up:Connect(function ()
					currentCFMV = rotateHandles.Adornee.CFrame
					table.clear(tempCFMV)

					for i, v in pairs(currentSelectedProp) do
						requestType = "Rotate"
						propsPlacerInvoke:InvokeServer(requestType, v, v.PrimaryPart.CFrame)
					end
				end)
			
				rotating = true
				moving = false
			end
		
		end

	end)

	propUI:WaitForChild("Copy").MouseButton1Click:Connect(onCopyButtonClick)
	propUI:WaitForChild("Rename").MouseButton1Click:Connect(onRenameButtonClick)
	propUI:WaitForChild("Delete").MouseButton1Click:Connect(onDeleteButtonClick)

	requestType = "LoadUI"

	if ReplicatedStorage:WaitForChild("PropPlacerInvoke") then
	propsPlacerInvoke:InvokeServer(requestType, propUI:WaitForChild("SaveSlots").Bin)
	
	end

	module.DeleteProp = function(Prop)
		print("PROP:", Prop)
		local Owner = Prop:GetAttribute("Owner")
		if Owner == player.Name then
			onDeleteButtonClick({Prop})
		else
			propsPlacerInvoke:InvokeServer("StaffDelete", Owner, {Prop})
		end
		
	end

	module.KillHandles = function()
		for i, v in pairs(player.PlayerGui:GetChildren()) do
			if v:IsA("Handles") or v:IsA("ArcHandles") then
				v:Destroy()
				FocalPropPointPart.Parent = nil
			end
		end

		rotating = false
		moving = false
	end



	warn("prop placer: returning back to client")

return module
