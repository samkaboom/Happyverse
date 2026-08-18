script.Parent:GetPropertyChangedSignal("Text"):Connect(function()
	local val = script.Parent.Text
	if #val > 40 then
		script.Parent.Text = val:sub(1,40)
	end
	
	script.Parent.Parent.Namecharacter.Text = tostring(math.abs(#val - 40))
end)