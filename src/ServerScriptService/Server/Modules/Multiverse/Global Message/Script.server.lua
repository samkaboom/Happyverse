for i = 1, 0.4, -0.01 do
	wait(0.02)
	script.Parent.Fade.BackgroundTransparency = i
end

wait(2 + (#script.Parent.Fade.message.Text / 10))

for i = 0.4, 1, 0.01 do
	wait(0.02)
	script.Parent.Fade.BackgroundTransparency = i
end

script.Parent:Destroy()