--!strict
local ElasticPreset = {}

function ElasticPreset.getScale(age: number): number
	local duration = 0.38
	if age >= duration then
		return 1.0
	end

	local p = math.clamp(age / duration, 0, 1)

	-- multi-bounce spring damping curve (rubber-band squish & stretch)
	local bounce = math.sin(p * math.pi * 4.5) * math.exp(-p * 5.0) * 0.75
	local baseScale = 1.0 - (1 - p)^2 * 0.85

	return math.clamp(baseScale + bounce, 0.1, 1.75)
end

return ElasticPreset