local Bin = game:GetService("ReplicatedStorage"):WaitForChild("ServerBuffers")

warn("Server buffer cleaner is on.")
local function Destroyed(x)
	if x.Parent then return false end
	local _, result = pcall(function() x.Parent = x end)
	return result:match("locked") and true or false
end


Bin.ChildAdded:Connect(function(child)
	print("Buffer added, checking and waiting.")
	wait(30)
	if not Destroyed(child) then
		warn("Cleaning out server buffer", child)
		child:Destroy()
	else
		warn("Buffer was already destroyed. System is functioning as usual.")
	end
end)