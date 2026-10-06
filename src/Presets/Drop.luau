--!strict
local DropPreset = {}

function DropPreset.getOffset(age: number): (number, number)
	local duration = 0.22
	if age >= duration then
		return 0, 0
	end

	local p = math.clamp(age / duration, 0, 1)
	local dropProgress = (1 - p)^2

	-- micro size boost (max +3px) prevents layout shift while optical transparency handles the drop illusion
	local sizeOffset = math.floor(dropProgress * 3)
	local transOffset = dropProgress * 0.95

	return sizeOffset, transOffset
end

return DropPreset