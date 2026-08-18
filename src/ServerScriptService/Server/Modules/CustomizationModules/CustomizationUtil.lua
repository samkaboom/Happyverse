local CustomizationUtil = {}

function CustomizationUtil.FindToolFromItem(player, accessory)
	for _, tool in pairs(player.Backpack:GetChildren()) do
		if tool:FindFirstChild("AssociatedObject") then
			if tool.AssociatedObject.Value == accessory then
				return tool
			end
		end
	end
end

function CustomizationUtil.IsOccupiedSkills(skillsValueSlot)
	local found = false
	for _, value in pairs(skillsValueSlot) do
		warn("FOUND!")
		found = true
		break
	end
	return found
end

function CustomizationUtil.DeepCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		if type(value) == "table" then
			value = CustomizationUtil.DeepCopy(value)
		end
		copy[key] = value
	end
	return copy
end

function CustomizationUtil.Round(value)
	return math.round(value * 100) / 100
end

return CustomizationUtil
