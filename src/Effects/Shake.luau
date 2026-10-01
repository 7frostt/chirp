--!strict
local Shake = {}

local OFFSETS = { -2, -1, 1, 2, 3, -3 }

function Shake.getOffset(index: number, timeVal: number): number
    local seed = math.floor(timeVal * 30) + (index * 17)
    local pos = (seed % #OFFSETS) + 1
    return OFFSETS[pos]
end

return Shake