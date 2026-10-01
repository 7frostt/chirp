--!strict
local Shake = {}

local GLITCH_SIZES = { -2, -1, 1, 2, 3 }

function Shake.getFormattedChar(char: string, baseSize: number): string
    if char == " " then return char end
    local offset = GLITCH_SIZES[math.random(1, #GLITCH_SIZES)]
    return string.format('<font size="%d">%s</font>', math.max(1, baseSize + offset), char)
end

return Shake