script.Parent:GetPropertyChangedSignal("Text"):Connect(function()
	local val = script.Parent.Text
	if #val > 300 then
		script.Parent.Text = val:sub(1,300)
	end
	
	script.Parent.Parent.Biocharacter.Text = tostring(math.abs(#val - 300))
end)