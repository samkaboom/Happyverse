local TweenService = game:GetService("TweenService")
local deb = false

local startpos = script.Parent.Position

script.Parent.Changed:Connect(function()
	if script.Parent.Visible == true and deb == false then
		deb = true
		script.Parent.Position = startpos
		
		local pos = UDim2.new(-(1-(math.random(2,9)/10)), 0,1+(math.random(5,10)/10), 0)
	
		script.Parent:TweenPosition(pos, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 1, true)
		wait(0.7)
		local t = TweenService:Create(script.Parent, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1, TextStrokeTransparency = 1})
		t:Play()
		wait(0.3)
		script.Parent.Visible = false
		script.Parent.TextTransparency = 0
		script.Parent.TextStrokeTransparency = 0.8
		deb = false
	end
end)