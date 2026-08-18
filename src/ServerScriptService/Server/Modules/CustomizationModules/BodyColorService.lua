local BodyColorService = {}

function BodyColorService.SetBodyColor(player, bodyPart, color)
	print(player, bodyPart, color)
	local bodyColors = player.Character:FindFirstChild("Body Colors")
	if bodyPart == "All" then
		bodyColors["HeadColor3"] = color
		bodyColors["TorsoColor3"] = color
		bodyColors["LeftLegColor3"] = color
		bodyColors["RightLegColor3"] = color
		bodyColors["LeftArmColor3"] = color
		bodyColors["RightArmColor3"] = color
	else
		bodyColors[bodyPart .. "Color3"] = color
	end

	return color
end

return BodyColorService
