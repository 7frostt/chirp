--!strict
local Pop = {}

function Pop.apply(label: TextLabel, accumulatedText: string, currentSpeed: number, char: string, textSize: number)
    local baseText = string.sub(accumulatedText, 1, #accumulatedText - #char)
    local poppedSize = math.floor(textSize * 1.35)
    
    label.Text = baseText .. string.format('<font size="%d">%s</font>', poppedSize, char)
    task.wait(currentSpeed * 0.5)
    label.Text = accumulatedText
end

return Pop