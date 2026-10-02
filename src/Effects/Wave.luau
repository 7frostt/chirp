local Wave = {}

-- returns (sizeOffset, transparencyOffset)
function Wave.getOffset(index: number, time: number): (number, number)
    local speed = 4.5
    local frequency = 0.4
    local sineVal = math.sin((time * speed) + (index * frequency))
    
    local sizeOffset = math.round(sineVal * 2)
    
    local transparencyOffset = math.clamp((1 - sineVal) * 0.12, 0, 0.25)

    return sizeOffset, transparencyOffset
end

return Wave