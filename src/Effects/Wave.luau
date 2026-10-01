--!strict
local Wave = {}

function Wave.getOffset(index: number, timeVal: number): number
    return math.floor(math.sin((timeVal * 8) + (index * 0.4)) * 3.5)
end

return Wave