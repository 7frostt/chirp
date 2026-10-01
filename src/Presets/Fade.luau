--!strict
local Fade = {}

local DURATION = 0.16

function Fade.getTransparency(age: number): number
    if age >= DURATION then return 0.0 end
    return 1.0 - (age / DURATION)
end

return Fade