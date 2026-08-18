script.Parent:GetPropertyChangedSignal("Text"):Connect(function()
	local val = script.Parent.Text
	if #val > 500 then
		script.Parent.Text = val:sub(1,500)
	end
	
	script.Parent.Parent.Desccharacter.Text = tostring(math.abs(#val - 500))
end)