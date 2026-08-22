local Overlays = {}

local FACES = {
	"Front",
	"Back",
	"Left",
	"Right",
	"Top",
	"Bottom",
}

local function NormalizeColor(Color)
	if typeof(Color) == "Vector3" then
		return Color3.new(Color.X, Color.Y, Color.Z)
	end

	return Color
end

function Overlays.Create(accessory: Accessory, Overlay: Texture, Transparency: number, Color: Color3)
	Color = NormalizeColor(Color)

	local Handle = accessory.Handle
	local specialMesh = Handle:FindFirstChildOfClass("SpecialMesh")
	local hasHandleTexture = Handle:FindFirstChildOfClass("Texture") ~= nil

	if specialMesh or hasHandleTexture then
		for _, v in pairs(Handle:GetDescendants()) do
			if v:IsA("Texture") then
				v:Destroy()
			end
		end
	end

	if specialMesh then -- special meshs are special, just 1 is needed
		local newOverlay = Overlay:Clone()
		newOverlay.Color3 = Color
		newOverlay.Transparency = Transparency
		newOverlay.Face = "Front"
		newOverlay.Parent = Handle
	else
		for _, face in pairs(FACES) do
			local newOverlay = Overlay:Clone()
			newOverlay.Color3 = Color
			newOverlay.Transparency = Transparency
			newOverlay.Face = face
			newOverlay.Parent = Handle
		end
	end
end

function Overlays.Delete(Accessory: Accessory)
	for _, v in pairs(Accessory:GetDescendants()) do
		if v:IsA("Texture") then
			v:Destroy()
		end
	end
end

function Overlays.Change(Accessory: Accessory, Transparency: number, Color: Color3)
	Color = NormalizeColor(Color)

	for _, texture in pairs(Accessory:GetDescendants()) do
		if texture:IsA("Texture") then
			texture.Transparency = Transparency
			texture.Color3 = Color
		end
	end
end

return Overlays
