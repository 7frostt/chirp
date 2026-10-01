--!strict
local Fade = {}

function Fade.apply(label: TextLabel, accumulatedText: string, currentSpeed: number, char: string)
    local baseText = string.sub(accumulatedText, 1, #accumulatedText - #char)
    label.Text = baseText .. string.format('<font transparency="0.5">%s</font>', char)
    task.wait(currentSpeed * 0.5)
    label.Text = accumulatedText
end

return Fade