print("Hello world!")

local Client = game.Players.LocalPlayer
local i = Instance.new("IntValue")
i.Name = "CreditsPlayed"
i.Parent = Client

local startfov = workspace.CurrentCamera.FieldOfView

workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
workspace.CurrentCamera.CameraSubject = nil
workspace.CurrentCamera.CFrame = workspace:WaitForChild("CameraPart").CFrame
workspace.CurrentCamera.FieldOfView = 40

local MainUI = script.Parent.Parent
local Credits = Client.PlayerGui:WaitForChild("Credits").Credits
local Music = script.Parent.MenuMusic

Music:Play()
Credits.Visible = true

for i = 0, 0.2, 0.005 do
	wait(0.01)
	Music.Volume = i
end

delay(9.3, function()
	for i = 0, 1, 0.05 do
		wait(0.005)
		Credits.BackgroundTransparency = i
	end
end)

Credits.Logo.Visible=true

for i = 1, 0, -0.05 do
	wait(0.005)
	Credits.Logo.ImageTransparency = i
	Credits.Logo.TextLabel.TextTransparency = i
	Credits.Logo.TextLabel.TextStrokeTransparency = i
end

wait(1)

for i = 0, 1, 0.05 do
	wait(0.005)
	Credits.Logo.ImageTransparency = i
	Credits.Logo.TextLabel.TextTransparency = i
	Credits.Logo.TextLabel.TextStrokeTransparency = i
end

Credits.Logo.Visible = false

wait(2)

Credits.Poff.Visible = true

for i = 1, 0, -0.05 do
	wait(0.005)
	Credits.Poff.TextTransparency = i
	Credits.Poff.TextStrokeTransparency = i
end

wait(1)

for i = 0, 1, 0.05 do
	wait(0.005)
	Credits.Poff.TextTransparency = i
	Credits.Poff.TextStrokeTransparency = i
end

Credits.Poff.Visible = false

wait(2)

Credits.Sam.Visible=true

for i = 1, 0, -0.05 do
	wait(0.005)
	Credits.Sam.TextTransparency = i
	Credits.Sam.TextStrokeTransparency = i
end

wait(1)

for i = 0, 1, 0.05 do
	wait(0.005)
	Credits.Sam.TextTransparency = i
	Credits.Sam.TextStrokeTransparency = i
end

Credits.Sam.Visible = false

wait(2)

Credits.Multiverse.Visible=true

for i = 1, 0, -0.05 do
	wait(0.005)
	if i > 0.8 then Credits.Multiverse.ImageTransparency = i end
	Credits.Multiverse.transparent.ImageTransparency = i
end

wait(1)

for i = 0, 1, 0.05 do
	wait(0.005)
	if i > 0.8 then Credits.Multiverse.ImageTransparency = i end
	Credits.Multiverse.transparent.ImageTransparency = i
end

Credits.Multiverse.Visible = false

wait(2)

Credits.visuals.Visible = true

Credits.sound.Visible = true

spawn(function()
	for i = 1, 0, -0.05 do
		wait(0.005)
		Credits.visuals.TextTransparency = i
		Credits.visuals.TextStrokeTransparency = i
	end

	for i, v in pairs(Credits.visuals:GetDescendants()) do
		spawn(function()
			for i = 1, 0, -0.05 do
				wait(0.005)
				v.TextTransparency = i
				v.TextStrokeTransparency = i
			end
		end)
	end

	wait(3)

	for i, v in pairs(Credits.visuals:GetChildren()) do
		spawn(function()
			for i = 0,1, 0.05 do
				wait(0.005)
				v.TextTransparency = i
				v.TextStrokeTransparency = i
			end
		end)
	end

	wait(0.1)

	for i = 0, 1, 0.05 do
		wait(0.005)
		Credits.visuals.TextTransparency = i
		Credits.visuals.TextStrokeTransparency = i
	end
	
	
	Credits.visuals.Visible = false
end)

spawn(function()
	for i = 1, 0, -0.05 do
		wait(0.005)
		Credits.sound.TextTransparency = i
		Credits.sound.TextStrokeTransparency = i
	end

	for i, v in pairs(Credits.sound:GetChildren()) do
		spawn(function()
			for i = 1, 0, -0.05 do
				wait(0.005)
				v.TextTransparency = i
				v.TextStrokeTransparency = i
			end
		end)
	end

	wait(3)

	for i, v in pairs(Credits.sound:GetChildren()) do
		spawn(function()
			for i = 0,1, 0.05 do
				wait(0.005)
				v.TextTransparency = i
				v.TextStrokeTransparency = i
			end
		end)
	end

	wait(0.1)

	for i = 0, 1, 0.05 do
		wait(0.005)
		Credits.sound.TextTransparency = i
		Credits.sound.TextStrokeTransparency = i
	end
	
	
	Credits.sound.Visible = false
	
	
end)

wait(5)


Credits.visuals.Visible = false
Credits.animators.Visible = true


	for i = 1, 0, -0.05 do
		wait(0.005)
		Credits.animators.TextTransparency = i
		Credits.animators.TextStrokeTransparency = i
	end

	for i, v in pairs(Credits.animators:GetDescendants()) do
		spawn(function()
			for i = 1, 0, -0.05 do
				wait(0.005)
				v.TextTransparency = i
				v.TextStrokeTransparency = i
			end
		end)
	end

	wait(3)

	for i, v in pairs(Credits.animators:GetDescendants()) do
		spawn(function()
			for i = 0,1, 0.05 do
				wait(0.005)
				v.TextTransparency = i
				v.TextStrokeTransparency = i
			end
		end)
	end

	wait(0.1)

	for i = 0, 1, 0.05 do
		wait(0.005)
		Credits.animators.TextTransparency = i
		Credits.animators.TextStrokeTransparency = i
	end


	Credits.animators.Visible = false



task.wait(4)

--Music:Stop()

--Credits:Destroy()
script.Enabled = false
--workspace.CurrentCamera.CameraSubject = Client.Character
--workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
--workspace.CurrentCamera.FieldOfView = startfov

