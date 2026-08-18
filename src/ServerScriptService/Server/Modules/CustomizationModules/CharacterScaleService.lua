local CharacterScaleService = {}

function CharacterScaleService.SetHeight(player, value, characterTable, fixAccessories)
	print(player, value)
	local character = player.Character
	local humanoid = character.Humanoid
	if humanoid.BodyHeightScale.Value ~= value then
		humanoid.BodyHeightScale.Value = value
		characterTable.Scale.Height = value
		local newTable = fixAccessories(player, characterTable)
		return newTable
	else
		return characterTable
	end
end

function CharacterScaleService.SetBody(player, width, depth, head, characterTable, fixAccessories)
	print(player, width, depth, head)
	local character = player.Character
	local humanoid = character.Humanoid
	local change = false
	if humanoid.BodyWidthScale.Value ~= width or humanoid.BodyDepthScale.Value ~= depth or humanoid.HeadScale.Value ~= head then
		change = true
		print("Change detected")
	end
	if change then
		humanoid.BodyWidthScale.Value = width
		humanoid.BodyDepthScale.Value = depth
		humanoid.HeadScale.Value = head

		characterTable.Scale.Head = head
		characterTable.Scale.Width = width
		characterTable.Scale.Depth = depth

		local newTable = fixAccessories(player, characterTable)

		return newTable

	else
		return characterTable
	end
end

function CharacterScaleService.Proportionalize(player, characterTable, defaultProportion, defaultType, fixAccessories)
	print(player, "Proportionalize")
	local character = player.Character
	local humanoid = character.Humanoid
	local heightv = humanoid.BodyHeightScale.Value
	local width = humanoid.BodyWidthScale
	local depth = humanoid.BodyDepthScale
	local head = humanoid.HeadScale

	if depth.Value == heightv * 0.88 and head.Value == heightv * 0.9 and width.Value == heightv*0.86 then return characterTable end

	local btype = 0.8
	local ptype = 1

	width.Value = heightv * 0.86
	characterTable.Scale.Width = width.Value
	depth.Value = heightv * 0.88
	characterTable.Scale.Depth = depth.Value
	head.Value = heightv * 0.90
	characterTable.Scale.Head = head.Value
	humanoid.BodyProportionScale.Value = defaultProportion
	humanoid.BodyTypeScale.Value = defaultType

	local newTable = fixAccessories(player, characterTable)

	return newTable
end

function CharacterScaleService.SetAnimations(player, idleId, walkId, runId, characterTable, insertService, defaultProportion, defaultType, fixAccessories)
	print(player, idleId, walkId, runId)

	local function isRealAnimation(shirtid)
		local suc, ass = pcall(function()
			local ass1 = insertService:LoadAsset(shirtid)
			ass1.Parent = workspace
			if ass1 then
				if ass1:FindFirstChildOfClass("Animation") then
					return true
				else
					return false
				end
			else
				return false
			end
		end)
	end

	local success, returned = pcall(function()

		local realIdle, realWalk, realRun = isRealAnimation(idleId), isRealAnimation(walkId), isRealAnimation(runId)

		if realIdle == false or realWalk == false or realRun == false then error("One of the assets are not a real Asset ID.") end
		local character = player.Character

		local description = player.Character.Humanoid:GetAppliedDescription()
		description.IdleAnimation = idleId
		description.WalkAnimation = walkId
		description.RunAnimation = runId
		description.HeightScale = characterTable.Scale.Height
		description.HeadScale = characterTable.Scale.Head
		description.WidthScale = characterTable.Scale.Width
		description.DepthScale = characterTable.Scale.Depth
		description.BodyTypeScale = defaultType
		description.ProportionScale = defaultProportion
		description.HeadColor = character["Body Colors"].HeadColor3
		description.TorsoColor = character["Body Colors"].TorsoColor3
		description.LeftArmColor = character["Body Colors"].LeftArmColor3
		description.RightArmColor = character["Body Colors"].RightArmColor3
		description.LeftLegColor = character["Body Colors"].LeftLegColor3
		description.RightLegColor = character["Body Colors"].RightLegColor3

		player.Character.Humanoid:ApplyDescription(description)

		characterTable["Animations"]["RunAnimation"] = runId
		characterTable["Animations"]["IdleAnimation"] = idleId
		characterTable["Animations"]["WalkAnimation"] = walkId
		characterTable = fixAccessories(player, characterTable)
	end)

	if not success then warn(returned) return false end

	return characterTable
end

return CharacterScaleService
