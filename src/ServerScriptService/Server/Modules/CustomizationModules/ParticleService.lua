local ParticleService = {}

function ParticleService.ApplyParticleColor(accessoryTable, particleEmitter)
	local startColor = accessoryTable.ParticleColor
	if particleEmitter.Name == "Fire" and startColor ~= Color3.new(1,1,1) then
		particleEmitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, startColor),
			ColorSequenceKeypoint.new(0.5, Color3.new(startColor.R, startColor.G/3, startColor.B/3)),
			ColorSequenceKeypoint.new(1, Color3.new(startColor.R, startColor.G/10, startColor.B/10))
		})
	else
		particleEmitter.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, startColor),
			ColorSequenceKeypoint.new(1, startColor)
		}
	end
end

function ParticleService.ConfigureParticleEmitter(accessoryTable, particleEmitter)
	if particleEmitter.Name ~= "Fire" then
		accessoryTable.ParticleRate = math.clamp(accessoryTable.ParticleRate, 0, 50)
	end

	if particleEmitter.Name == "GentleAura" then
		particleEmitter.Rate = accessoryTable.ParticleRate
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0,1),
			NumberSequenceKeypoint.new(0.5,accessoryTable.ParticleTransparency),
			NumberSequenceKeypoint.new(1,1)
		})
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0,accessoryTable.ParticleSize),
			NumberSequenceKeypoint.new(1,accessoryTable.ParticleSize)
		})
	elseif particleEmitter.Name == "HardSmoke" then
		particleEmitter.Rate = accessoryTable.ParticleRate
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0,1),
			NumberSequenceKeypoint.new(0.5,accessoryTable.ParticleTransparency),
			NumberSequenceKeypoint.new(1,1)
		})
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0,0.3),
			NumberSequenceKeypoint.new(0.3,accessoryTable.ParticleSize),
			NumberSequenceKeypoint.new(1,math.clamp(accessoryTable.ParticleSize-0.1, 0.1, math.huge), 0.5)
		})
	elseif particleEmitter.Name == "SoftSmoke" then
		particleEmitter.Rate = accessoryTable.ParticleRate
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0,1),
			NumberSequenceKeypoint.new(0.5,accessoryTable.ParticleTransparency),
			NumberSequenceKeypoint.new(1,1)
		})
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0,0.3),
			NumberSequenceKeypoint.new(0.3,accessoryTable.ParticleSize),
			NumberSequenceKeypoint.new(1,accessoryTable.ParticleSize+0.4, 0.5)
		})
	elseif particleEmitter.Name == "Lightning" then
		particleEmitter.Rate = accessoryTable.ParticleRate
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0,accessoryTable.ParticleTransparency),
			NumberSequenceKeypoint.new(1,accessoryTable.ParticleTransparency)
		})
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0,accessoryTable.ParticleSize, 0.75),
			NumberSequenceKeypoint.new(0.3,accessoryTable.ParticleSize+0.75,0.5),
			NumberSequenceKeypoint.new(0.5,math.abs(accessoryTable.ParticleSize-0.25),0.375),
			NumberSequenceKeypoint.new(0.7,accessoryTable.ParticleSize+0.75,0.5),
			NumberSequenceKeypoint.new(1,accessoryTable.ParticleSize, 0.75)
		})
	elseif particleEmitter.Name == "Fire" then
		particleEmitter.Rate = accessoryTable.ParticleRate
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0,accessoryTable.ParticleTransparency),
			NumberSequenceKeypoint.new(1,accessoryTable.ParticleTransparency)
		})
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0,accessoryTable.ParticleSize),
			NumberSequenceKeypoint.new(1,0)
		})
	end
end

function ParticleService.ApplyParticleData(accessoryTable, handle, particlesFolder)
	if accessoryTable.Particle == "None" then
		return
	end

	local found = particlesFolder:FindFirstChild(accessoryTable.Particle)
	if not found then
		return
	end

	found = found:Clone()
	found.Parent = handle
	found.Enabled = true
	ParticleService.ApplyParticleColor(accessoryTable, found)
	ParticleService.ConfigureParticleEmitter(accessoryTable, found)
end

return ParticleService
