-- Get a reference to the parent object of the script
local bin = script.Parent

-- Get references to the NeutralSize and ExpandedSize objects
local NeutralSize = script.NeutralSize
local ExpandedSize = script.ExpandedSize

-- Initialize a variable to keep track of whether the control key is pressed
local CtrlIsDown = false

-- Initialize an empty table to keep track of selected items
local AmtSelected = {}

local player = game.Players.LocalPlayer

-- Set the canvas position to a fixed value
script.Parent.CanvasPosition = Vector2.new(0, 1364.22)

-- Define a function to remove an item from the selected table
local function RemoveFromTable(v)
    for i, x in ipairs(AmtSelected) do
        if x == v then
            table.remove(AmtSelected, i)
        end
    end
end

-- Define a function to close all items except the one that is currently clicked
local function SetAllClosed(x)
    warn("Setting all closed")
    for i, v in pairs(bin:GetChildren()) do
        if v:IsA("TextButton") and v~=x then
            if v.ItemPack.Value == false then
                -- If the item is not part of a pack, set its properties accordingly
                v.AccessorySelected.Value = false
                v.SlotFrame.Visible = false
                v.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
                v:TweenSize(UDim2.new(1,0,0.1, NeutralSize.Value), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.3, true)
                RemoveFromTable(v)
            else
                -- If the item is part of a pack, set its properties accordingly
                v.AccessorySelected.Value = false
                v.SlotFrame.Visible = false
                v.BackgroundColor3 = Color3.fromRGB(15, 39, 19)
                v:TweenSize(UDim2.new(1,0,0.1, NeutralSize.Value), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.3, true)
                RemoveFromTable(v)
            end
        end
    end
end

-- Define a function to preview a 3D object in a viewport frame
local ViewportModule = require(script.Parent.Parent.Parent.Parent.Client:WaitForChild("ViewportModel"))

-- This function previews a 3D object in a viewport frame
-- v: the 3D object to preview
function viewportPreview(v)

	print(v)

	local ViewportFrame = script.Parent.Parent.ViewportFrame

	-- Remove any existing camera in the viewport frame
	for i, child in pairs(ViewportFrame:GetChildren()) do
		if child:IsA("Camera") then
			child:Destroy()
		end
	end

	-- Create a new camera for the viewport frame
	local ViewportCamera = Instance.new("Camera")
	ViewportFrame.CurrentCamera = ViewportCamera
	ViewportCamera.Parent = ViewportFrame

	-- Clone the 3D object to display in the viewport
	local ObjectClone = v:Clone()
	ObjectClone.Parent = ViewportCamera

	-- Create a new ViewportModel to display the 3D object
	local vpfModel = ViewportModule.new(ViewportFrame, ViewportCamera)

	-- Set the 3D object as the model to display in the viewport
	local cf, size = ObjectClone:GetBoundingBox()
	vpfModel:SetModel(ObjectClone)

	-- Set up the camera's initial orientation and distance from the 3D object
	local theta = 0
	local orientation = CFrame.new()
	local distance = vpfModel:GetFitDistance(cf.Position)

	-- Continuously update the camera's position to rotate around the 3D object
	game:GetService("RunService").RenderStepped:Connect(function(dt)
		theta = theta + math.rad(50 * dt)
		orientation = CFrame.fromEulerAnglesYXZ(math.rad(-20), theta, 0)
		ViewportCamera.CFrame = CFrame.new(cf.Position) * orientation * CFrame.new(0, 0, distance)
	end)

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
		print ("enter")
		if v.AccessorySelected.Value == false then
			
			v.Hovered.Value = true
			viewportPreview(v.AccessoryAssociated.Value)
			v:TweenSize(UDim2.new(1,0,0.14,ExpandedSize.Value), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)			
			
		end	end)
	v.MouseLeave:Connect(function()
		print("exit")
		if v.AccessorySelected.Value == false then
			v.Hovered.Value = false
			v:TweenSize(UDim2.new(1,0,0.1, NeutralSize.Value), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.3, true)

		end
	end)
	
	v.MouseButton1Click:Connect(function()
		warn(CtrlIsDown)
		if CtrlIsDown == false then SetAllClosed(v) end --
		
		if v.AccessorySelected.Value == true then
			if v.ItemPack.Value == false then
				v.AccessorySelected.Value = false
				v.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
				v:TweenSize(UDim2.new(1,0,0.1, NeutralSize.Value), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.3, true)
				RemoveFromTable(v)
			else
				v.AccessorySelected.Value = false
				v.BackgroundColor3 = Color3.fromRGB(9, 69, 134)
				v:TweenSize(UDim2.new(1,0,0.1, NeutralSize.Value), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.3, true)
				RemoveFromTable(v)
			end
		else 
			if v.ItemPack.Value == false then
				v.AccessorySelected.Value = true
				v.SlotFrame.Visible = true
				v.BackgroundColor3 = Color3.fromRGB(134, 134, 134)
				v:TweenSize(UDim2.new(1,0,0.14,ExpandedSize.Value), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)
				table.insert(AmtSelected, v)
			else
				v.AccessorySelected.Value = true
				v.SlotFrame.Visible = true
				v.BackgroundColor3 = Color3.fromRGB(25, 66, 31)
				v:TweenSize(UDim2.new(1,0,0.14,ExpandedSize.Value), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)
				table.insert(AmtSelected, v)
			end
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

bin.ChildAdded:Connect(IndexButton)

