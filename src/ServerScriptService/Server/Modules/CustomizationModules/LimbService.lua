local LimbService = {}

function LimbService.ApplyStoredLimbTransparency(client, limbToRemove, transparency)
	local limb = client.Character:FindFirstChild(limbToRemove)
	if limb then
		if transparency == true then
			limb.Transparency = 1
		else
			limb.Transparency = 0
		end
		local intendedTransparency = limb:FindFirstChild("IntendedTransparency")
		if intendedTransparency then
			if transparency == true then
				intendedTransparency.Value = 1
			else
				intendedTransparency.Value = 0
			end
		else
			intendedTransparency = Instance.new("NumberValue")
			intendedTransparency.Name = "IntendedTransparency"
			if transparency == true then
				intendedTransparency.Value = 1
			else
				intendedTransparency.Value = 0
			end
		end
	end

	return true
end

function LimbService.SetLiveLimbTransparency(player, limbName, setType)
	local limb = player.Character:FindFirstChild(limbName)
	if limb then
		limb.Transparency = setType
	end

	return true
end

return LimbService
