--!strict
local Parser = {}

export type Token = {
    Kind: "Text" | "Tag" | "Pause" | "Speed" | "Event" | "EffectStart" | "EffectEnd",
    Value: string,
    Data: any?,
}

local NATIVE_TAGS = { "font", "b", "i", "u", "s", "sc", "stroke" }

local function isNativeTag(tagContent: string): boolean
    local cleanTag = string.match(tagContent, "^/?([%w]+)")
    if not cleanTag then return false end
    return table.find(NATIVE_TAGS, string.lower(cleanTag)) ~= nil
end

function Parser.parseText(rawText: string): {Token}
    local tokens: {Token} = {}
    local pos = 1
    local length = #rawText

    while pos <= length do
        local tagStart, tagEnd = string.find(rawText, "<[^>]+>", pos)

        if tagStart and tagEnd then
            if tagStart > pos then
                local textChunk = string.sub(rawText, pos, tagStart - 1)
                for i = 1, #textChunk do
                    table.insert(tokens, {
                        Kind = "Text",
                        Value = string.sub(textChunk, i, i),
                    })
                end
            end

            local tagContent = string.sub(rawText, tagStart + 1, tagEnd - 1)

            local pauseVal = string.match(tagContent, "^pause=(%d*%.?%d+)$")
            local speedVal = string.match(tagContent, "^speed=(%d*%.?%d+)$")
            local eventVal = string.match(tagContent, "^event=(.+)$")

            if pauseVal then
                table.insert(tokens, { Kind = "Pause", Value = tagContent, Data = tonumber(pauseVal) })
            elseif speedVal then
                table.insert(tokens, { Kind = "Speed", Value = tagContent, Data = tonumber(speedVal) })
            elseif eventVal then
                table.insert(tokens, { Kind = "Event", Value = eventVal })
            elseif tagContent == "shake" or tagContent == "wave" then
                table.insert(tokens, { Kind = "EffectStart", Value = tagContent })
            elseif tagContent == "/shake" or tagContent == "/wave" then
                table.insert(tokens, { Kind = "EffectEnd", Value = string.sub(tagContent, 2) })
            elseif isNativeTag(tagContent) then
                table.insert(tokens, { Kind = "Tag", Value = string.sub(rawText, tagStart, tagEnd) })
            end

            pos = tagEnd + 1
        else
            local remaining = string.sub(rawText, pos)
            for i = 1, #remaining do
                table.insert(tokens, {
                    Kind = "Text",
                    Value = string.sub(remaining, i, i),
                })
            end
            break
        end
    end

    return tokens
end

return Parser