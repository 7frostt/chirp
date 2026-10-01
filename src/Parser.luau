--!strict
local Parser = {}

export type Command = {
    Kind: "Pause" | "Speed" | "Event",
    Value: any,
}

export type GraphemeNode = {
    char: string,
    nativeOpenTags: string,
    nativeCloseTags: string,
    effects: { [string]: boolean },
}

export type ParsedDialogue = {
    cleanText: string,
    graphemes: { GraphemeNode },
    commands: { [number]: { Command } },
    hasEffects: boolean,
}

local NATIVE_TAG_PATTERNS = {
    "^/?font",
    "^/?b$",
    "^/?i$",
    "^/?u$",
    "^/?s$",
    "^/?sc$",
    "^/?stroke",
}

local function isNativeTag(tagContent: string): boolean
    local lower = string.lower(tagContent)
    for _, pattern in ipairs(NATIVE_TAG_PATTERNS) do
        if string.find(lower, pattern) then
            return true
        end
    end
    return false
end

local function getClosingTag(openingTag: string): string
    local tagName = string.match(openingTag, "^<([%w]+)")
    if tagName then
        return "</" .. tagName .. ">"
    end
    return ""
end

function Parser.parseText(rawText: string): ParsedDialogue
    local cleanText = ""
    local graphemes: { GraphemeNode } = {}
    local commands: { [number]: { Command } } = {}
    local nativeTagStack: { { open: string, close: string } } = {}
    local activeEffects: { [string]: boolean } = {}

    local hasEffects = false
    local pos = 1
    local length = #rawText

    local function addCommand(atGrapheme: number, cmd: Command)
        if not commands[atGrapheme] then
            commands[atGrapheme] = {}
        end
        table.insert(commands[atGrapheme], cmd)
    end

    local function getNativeOpenClose(): (string, string)
        local openStr = ""
        local closeStr = ""
        for i = 1, #nativeTagStack do
            openStr ..= nativeTagStack[i].open
        end
        for i = #nativeTagStack, 1, -1 do
            closeStr ..= nativeTagStack[i].close
        end
        return openStr, closeStr
    end

    local function cloneEffects(): { [string]: boolean }
        local clone = {}
        for k, v in pairs(activeEffects) do
            clone[k] = v
        end
        return clone
    end

    while pos <= length do
        local tagStart, tagEnd = string.find(rawText, "<[^>]+>", pos)

        if tagStart and tagEnd then
            if tagStart > pos then
                local textChunk = string.sub(rawText, pos, tagStart - 1)
                for _, codePoint in utf8.codes(textChunk) do
                    local char = utf8.char(codePoint)
                    local openTags, closeTags = getNativeOpenClose()
                    table.insert(graphemes, {
                        char = char,
                        nativeOpenTags = openTags,
                        nativeCloseTags = closeTags,
                        effects = cloneEffects(),
                    })
                    cleanText ..= char
                end
            end

            local fullTag = string.sub(rawText, tagStart, tagEnd)
            local tagContent = string.sub(rawText, tagStart + 1, tagEnd - 1)

            local pauseVal = string.match(tagContent, "^pause=(%d*%.?%d+)$")
            local speedVal = string.match(tagContent, "^speed=(%d*%.?%d+)$")
            local eventVal = string.match(tagContent, "^event=(.+)$")

            if pauseVal then
                addCommand(#graphemes + 1, { Kind = "Pause", Value = tonumber(pauseVal) })
            elseif speedVal then
                addCommand(#graphemes + 1, { Kind = "Speed", Value = tonumber(speedVal) })
            elseif eventVal then
                addCommand(#graphemes + 1, { Kind = "Event", Value = eventVal })
            elseif string.sub(tagContent, 1, 1) ~= "/" and not isNativeTag(tagContent) then
                -- Custom effect start tag (e.g., <shake>, <wave>)
                activeEffects[tagContent] = true
                hasEffects = true
            elseif string.sub(tagContent, 1, 1) == "/" and not isNativeTag(tagContent) then
                -- Custom effect end tag (e.g., </shake>, </wave>)
                local effectName = string.sub(tagContent, 2)
                activeEffects[effectName] = nil
            elseif isNativeTag(tagContent) then
                cleanText ..= fullTag
                if string.sub(tagContent, 1, 1) == "/" then
                    if #nativeTagStack > 0 then
                        table.remove(nativeTagStack)
                    end
                else
                    table.insert(nativeTagStack, {
                        open = fullTag,
                        close = getClosingTag(fullTag),
                    })
                end
            end

            pos = tagEnd + 1
        else
            local remaining = string.sub(rawText, pos)
            for _, codePoint in utf8.codes(remaining) do
                local char = utf8.char(codePoint)
                local openTags, closeTags = getNativeOpenClose()
                table.insert(graphemes, {
                    char = char,
                    nativeOpenTags = openTags,
                    nativeCloseTags = closeTags,
                    effects = cloneEffects(),
                })
                cleanText ..= char
            end
            break
        end
    end

    return {
        cleanText = cleanText,
        graphemes = graphemes,
        commands = commands,
        hasEffects = hasEffects,
    }
end

return Parser