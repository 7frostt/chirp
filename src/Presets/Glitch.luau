--!strict
local Glitch = {}

local GLITCH_CHARS = { "#", "$", "%", "&", "?", "@", "*", "!", "X", "0", "1" }
local DURATION = 0.08

function Glitch.getChar(rawChar: string, age: number, index: number): string
    if rawChar == " " or age >= DURATION then
        return rawChar
    end
    local seed = math.floor(os.clock() * 40) + index
    local pos = (seed % #GLITCH_CHARS) + 1
    return GLITCH_CHARS[pos]
end

return Glitch