--!strict
local NeonPreset = {}

local NEON_COLORS = {
	"#00F0FF", -- electric cyan
	"#FF007F", -- hot pink / magenta
	"#00FF66", -- acid green
	"#9D00FF", -- laser purple
	"#FFE600", -- neon yellow
	"#FF3366", -- hot coral
	"#0066FF", -- electric blue
	"#FF5500", -- vivid orange
	"#FFFFFF", -- white hot flash
}

function NeonPreset.getOffsetAndColor(age: number, index: number): (number, string?)
	local duration = 0.32
	if age >= duration then
		return 0, nil
	end

	local p = math.clamp(age / duration, 0, 1)

	-- electric strobe flicker
	local flicker = math.sin(p * math.pi * 16 + index)
	local trans = if flicker > 0 then (1 - p) * 0.35 else 0.05

	-- cycle through the 9 neon color palette rapidly during reveal
	local colorIdx = (math.floor(age * 36 + index) % #NEON_COLORS) + 1
	local selectedColor = NEON_COLORS[colorIdx]

	return trans, selectedColor
end

return NeonPreset