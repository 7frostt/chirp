--!strict
local Pop = {}

local DURATION = 0.14

function Pop.getScale(age: number): number
    if age >= DURATION then return 1.0 end
    local progress = age / DURATION
    return 1.0 + (0.45 * (1 - progress) * math.cos(progress * math.pi * 0.5))
end

return Pop