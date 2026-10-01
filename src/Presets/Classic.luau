--!strict
local Classic = {}

function Classic.apply(label: TextLabel, accumulatedText: string)
    label.Text = accumulatedText
end

return Classic