--!strict
local GLITCH_CHARS = { "#", "$", "%", "&", "?", "@", "*", "!", "X", "0", "1" }

local Glitch = {}

function Glitch.apply(label: TextLabel, accumulatedText: string, currentSpeed: number)
    if math.random() > 0.4 then
        local randomGlitch = GLITCH_CHARS[math.random(1, #GLITCH_CHARS)]
        label.Text = accumulatedText .. randomGlitch
        task.wait(currentSpeed / 2)
    end
end

return Glitch