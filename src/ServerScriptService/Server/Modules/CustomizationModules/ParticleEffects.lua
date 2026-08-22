local ParticleEffects = {}

function ParticleEffects.ApplyParticleColor(AccessoryTable, ParticleEmitter)
	local startColor = AccessoryTable.ParticleColor
	if ParticleEmitter.Name == "Fire" and startColor ~= Color3.new(1, 1, 1) then
		ParticleEmitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, startColor),
			ColorSequenceKeypoint.new(0.5, Color3.new(startColor.R, startColor.G / 3, startColor.B / 3)),
			ColorSequenceKeypoint.new(1, Color3.new(startColor.R, startColor.G / 10, startColor.B / 10)),
		})
	else
		ParticleEmitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, startColor),
			ColorSequenceKeypoint.new(1, startColor),
		})
	end
end

function ParticleEffects.ConfigureParticleEmitter(AccessoryTable, P)
	if P.Name ~= "Fire" then
		AccessoryTable.ParticleRate = math.clamp(AccessoryTable.ParticleRate, 0, 50)
	end

	if P.Name == "GentleAura" then
		P.Rate = AccessoryTable.ParticleRate
		P.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, AccessoryTable.ParticleTransparency),
			NumberSequenceKeypoint.new(1, 1),
		})
		P.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, AccessoryTable.ParticleSize),
			NumberSequenceKeypoint.new(1, AccessoryTable.ParticleSize),
		})
	elseif P.Name == "HardSmoke" then
		P.Rate = AccessoryTable.ParticleRate
		P.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, AccessoryTable.ParticleTransparency),
			NumberSequenceKeypoint.new(1, 1),
		})
		P.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.3, AccessoryTable.ParticleSize),
			NumberSequenceKeypoint.new(1, math.clamp(AccessoryTable.ParticleSize - 0.1, 0.1, math.huge), 0.5),
		})
	elseif P.Name == "SoftSmoke" then
		P.Rate = AccessoryTable.ParticleRate
		P.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, AccessoryTable.ParticleTransparency),
			NumberSequenceKeypoint.new(1, 1),
		})
		P.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.3, AccessoryTable.ParticleSize),
			NumberSequenceKeypoint.new(1, AccessoryTable.ParticleSize + 0.4, 0.5),
		})
	elseif P.Name == "Lightning" then
		P.Rate = AccessoryTable.ParticleRate
		P.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, AccessoryTable.ParticleTransparency),
			NumberSequenceKeypoint.new(1, AccessoryTable.ParticleTransparency),
		})
		P.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, AccessoryTable.ParticleSize, 0.75),
			NumberSequenceKeypoint.new(0.3, AccessoryTable.ParticleSize + 0.75, 0.5),
			NumberSequenceKeypoint.new(0.5, math.abs(AccessoryTable.ParticleSize - 0.25), 0.375),
			NumberSequenceKeypoint.new(0.7, AccessoryTable.ParticleSize + 0.75, 0.5),
			NumberSequenceKeypoint.new(1, AccessoryTable.ParticleSize, 0.75),
		})
	elseif P.Name == "Fire" then
		P.Rate = AccessoryTable.ParticleRate
		P.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, AccessoryTable.ParticleTransparency),
			NumberSequenceKeypoint.new(1, AccessoryTable.ParticleTransparency),
		})
		P.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, AccessoryTable.ParticleSize),
			NumberSequenceKeypoint.new(1, 0),
		})
	end
end

function ParticleEffects.ApplyParticleData(AccessoryTable, Handle, ParticlesFolder)
	if AccessoryTable.Particle == "None" then
		return
	end

	local Found = ParticlesFolder:FindFirstChild(AccessoryTable.Particle)
	if not Found then
		return
	end

	Found = Found:Clone()
	Found.Parent = Handle
	Found.Enabled = true
	ParticleEffects.ApplyParticleColor(AccessoryTable, Found)
	ParticleEffects.ConfigureParticleEmitter(AccessoryTable, Found)
end

return ParticleEffects
