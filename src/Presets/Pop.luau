--!strict
local PopPreset = {}

function PopPreset.getScale(age: number): number
	local duration = 0.22 -- pop animation duration in seconds
	if age >= duration then
		return 1.0
	end

	local p = math.clamp(age / duration, 0, 1)

	-- cubic pop-in curve with decaying spring bounce (starts ~0.15, peaks ~1.22, settles smoothly to 1.0)
	local baseScale = 1 - (1 - p)^3
	local springOvershoot = math.sin(p * math.pi) * 0.22 * (1 - p)

	return math.clamp(baseScale + springOvershoot, 0.15, 1.25)
end

return PopPreset