local CharacterInfoService = {}

local function filterText(textService, getFilteredBroadcastText, text, userId)
	return getFilteredBroadcastText(textService:FilterStringAsync(text, userId))
end

function CharacterInfoService.SetNameBio(player, nameBioTable, infoFolderRoot, textService, getFilteredBroadcastText)
	local folder = infoFolderRoot[player.Name]

	nameBioTable.Name = filterText(textService, getFilteredBroadcastText, nameBioTable.Name, player.UserId)
	nameBioTable.Bio = filterText(textService, getFilteredBroadcastText, nameBioTable.Bio, player.UserId)
	if nameBioTable.Name == false or nameBioTable.Bio == false then return false end

	folder.CName.Value = nameBioTable.Name
	folder.CBio.Value = nameBioTable.Bio
	folder.CImage.Value = nameBioTable.Image
	wait()
	return nameBioTable
end

function CharacterInfoService.SetEmpowerment(player, empowermentTable, shouldFilter, infoFolderRoot, textService, getFilteredBroadcastText)
	warn(player, empowermentTable, shouldFilter)
	local folder = infoFolderRoot[player.Name]

	if shouldFilter then
		empowermentTable.Description = filterText(textService, getFilteredBroadcastText, empowermentTable.Description, player.UserId)
		empowermentTable.Title = filterText(textService, getFilteredBroadcastText, empowermentTable.Title, player.UserId)
		if empowermentTable.Description == false or empowermentTable.Title == false then return false end
	end

	folder.EmpowermentType.Value = empowermentTable.Type
	folder.Empowerment.Value = empowermentTable.Description
	folder.EmpowermentTitle.Value = empowermentTable.Title
	return empowermentTable
end

function CharacterInfoService.SetSkill(player, skillTable, shouldFilter, slot, infoFolderRoot, textService, getFilteredBroadcastText)
	local folder = infoFolderRoot[player.Name]

	if shouldFilter then
		skillTable.Description = filterText(textService, getFilteredBroadcastText, skillTable.Description, player.UserId)
		skillTable.Title = filterText(textService, getFilteredBroadcastText, skillTable.Title, player.UserId)
		if skillTable.Description == false or skillTable.Title == false then return false end
	end

	folder["Skill" .. tostring(slot) .. "Type"].Value = skillTable.Type
	folder["Skill" .. tostring(slot) .. "Description"].Value = skillTable.Description
	folder["Skill" .. tostring(slot) .. "Title"].Value = skillTable.Title
	return skillTable
end

return CharacterInfoService
