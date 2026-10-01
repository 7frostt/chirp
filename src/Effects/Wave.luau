--!strict
local Wave = {}

function Wave.getFormattedChar(char: string, index: number, timeVal: number, baseSize: number): string
    if char == " " then return char end
    local waveOffset = math.sin((timeVal * 8) + (index * 0.5)) * 3
    local newSize = math.floor(baseSize + waveOffset)
    return string.format('<font size="%d">%s</font>', math.max(1, newSize), char)
end

return Wave