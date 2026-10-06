--!strict
--[=[
    Chirp v0.4.1
    A lightweight, tag-aware RichText typewriter & dialogue engine for Roblox.
    Author: 7frostt
]=]

local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local Signal = require(script.Signal)
local Parser = require(script.Parser)

local GlitchPreset = require(script.Presets.Glitch)
local FadePreset = require(script.Presets.Fade)
local PopPreset = require(script.Presets.Pop)

local ShakeEffect = require(script.Effects.Shake)
local WaveEffect = require(script.Effects.Wave)

local Chirp = {}
Chirp.__index = Chirp

type CustomEffectFn = (index: number, time: number) -> (number?, number?, string?)
Chirp.RegisteredEffects = {} :: { [string]: CustomEffectFn }

export type PresetType = "Classic" | "Glitch" | "Fade" | "Pop"

export type ChirpOptions = {
    Speed: number?,
    Preset: PresetType?,
    Sound: Sound?,
    RandomizePitch: boolean?,
    PitchRange: Vector2?,
    Caret: string?,
    ShowPrompt: boolean?,
}

export type ChirpInstance = {
    TextLabel: TextLabel,
    Speed: number,
    Preset: PresetType,
    Sound: Sound?,
    RandomizePitch: boolean,
    PitchRange: Vector2,
    Caret: string?,
    ShowPrompt: boolean,

    OnComplete: any,
    OnPause: any,
    OnEventTriggered: any,

    _isTyping: boolean,
    _skipRequested: boolean,
    _stopRequested: boolean,
    _promptGui: TextLabel?,
    _renderConn: RBXScriptConnection?,
    _promptConn: RBXScriptConnection?,

    Type: (self: ChirpInstance, text: string, startTime: number?) -> (),
    Skip: (self: ChirpInstance) -> (),
    Stop: (self: ChirpInstance) -> (),
    Destroy: (self: ChirpInstance) -> (),
}

function Chirp.RegisterEffect(effectName: string, callback: CustomEffectFn)
    assert(type(effectName) == "string", "[Chirp]: Effect name must be a string.")
    assert(type(callback) == "function", "[Chirp]: Callback must be a function.")
    Chirp.RegisteredEffects[string.lower(effectName)] = callback
end

function Chirp.Sanitize(rawUgcText: string): string
    local sanitized = string.gsub(rawUgcText, "&", "&amp;")
    sanitized = string.gsub(sanitized, "<", "&lt;")
    sanitized = string.gsub(sanitized, ">", "&gt;")
    return sanitized
end

function Chirp.new(textLabel: TextLabel, options: ChirpOptions?): ChirpInstance
    assert(textLabel and textLabel:IsA("TextLabel"), "[Chirp]: TextLabel instance expected.")

    options = options or {}
    textLabel.RichText = true

    local self = setmetatable({}, Chirp)

    self.TextLabel = textLabel
    self.Speed = options.Speed or 0.04
    self.Preset = options.Preset or "Classic"
    self.Sound = options.Sound
    self.RandomizePitch = if options.RandomizePitch ~= nil then options.RandomizePitch else true
    self.PitchRange = options.PitchRange or Vector2.new(0.95, 1.05)
    self.Caret = options.Caret or "|"
    self.ShowPrompt = if options.ShowPrompt ~= nil then options.ShowPrompt else true

    self.OnComplete = Signal.new()
    self.OnPause = Signal.new()
    self.OnEventTriggered = Signal.new()

    self._isTyping = false
    self._skipRequested = false
    self._stopRequested = false
    self._renderConn = nil
    self._promptConn = nil

    if self.ShowPrompt and textLabel.Parent then
        local prompt = Instance.new("TextLabel")
        prompt.Name = "ChirpPrompt"
        prompt.Size = UDim2.new(0, 18, 0, 18)
        prompt.Position = UDim2.new(1, -22, 1, -22)
        prompt.BackgroundTransparency = 1
        prompt.Text = "▼"
        prompt.TextColor3 = textLabel.TextColor3
        prompt.TextSize = 14
        prompt.Font = Enum.Font.BuilderSansBold
        prompt.Visible = false
        prompt.Parent = textLabel.Parent
        self._promptGui = prompt
    end

    return (self :: any) :: ChirpInstance
end

function Chirp:_cleanupConnections()
    if self._renderConn then
        self._renderConn:Disconnect()
        self._renderConn = nil
    end
    if self._promptConn then
        self._promptConn:Disconnect()
        self._promptConn = nil
    end
end

function Chirp:_playSound()
    if not self.Sound then return end

    local soundClone = self.Sound:Clone()
    if self.RandomizePitch then
        local randomPitch = math.random(
            math.floor(self.PitchRange.X * 100),
            math.floor(self.PitchRange.Y * 100)
        ) / 100
        soundClone.PlaybackSpeed = randomPitch
    end

    soundClone.Parent = SoundService
    soundClone:Play()

    soundClone.Ended:Once(function()
        soundClone:Destroy()
    end)
end

function Chirp:Type(rawText: string, startTime: number?)
    self:_cleanupConnections()
    self:Stop()

    if self._promptGui then
        self._promptGui.Visible = false
    end

    self._isTyping = true
    self._skipRequested = false
    self._stopRequested = false

    -- pass RegisteredEffects to parser so custom tags (<spooky>, <pulse>) are stripped from native rich text tags
    local parsed = Parser.parseText(rawText, Chirp.RegisteredEffects)
    local label = self.TextLabel
    local currentSpeed = self.Speed

    label.Text = parsed.cleanText
    label.MaxVisibleGraphemes = 0

    local totalGraphemes = #parsed.graphemes
    local revealTimestamps: { [number]: number } = {}

    local baseTime = os.clock()
    local initialElapsed = 0
    if startTime then
        local serverNow = workspace:GetServerTimeNow()
        initialElapsed = math.max(0, serverNow - startTime)
    end

    local currentGrapheme = 0
    if initialElapsed > 0 and currentSpeed > 0 then
        currentGrapheme = math.min(totalGraphemes, math.floor(initialElapsed / currentSpeed))
        for i = 1, currentGrapheme do
            revealTimestamps[i] = baseTime - (initialElapsed - (i * currentSpeed))
        end
    end

    local isCustomAnimated = (self.Preset ~= "Classic") or parsed.hasEffects

    if isCustomAnimated then
        label.MaxVisibleGraphemes = -1

        local charBuffer = table.create(totalGraphemes + 1)

        self._renderConn = RunService.RenderStepped:Connect(function()
            if currentGrapheme == 0 then
                label.Text = ""
                return
            end

            local now = os.clock()
            table.clear(charBuffer)

            for i = 1, currentGrapheme do
                local node = parsed.graphemes[i]
                -- clamp fade age so characters stay visible post-typing
                local revealTime = revealTimestamps[i] or now
                local rawAge = now - revealTime
                local fadeAge = math.min(0.5, rawAge)
                local char = node.char

                if self.Preset == "Glitch" then
                    char = GlitchPreset.getChar(char, rawAge, i)
                end

                local sizeOffset = 0
                local extraTransparency = 0
                local currentColorOverride: string? = nil

                if node.effects["shake"] then
                    sizeOffset += ShakeEffect.getOffset(i, now)
                end
                if node.effects["wave"] then
    local waveSize, waveTrans = WaveEffect.getOffset(i, now)
    sizeOffset += waveSize
    extraTransparency += waveTrans
end

                -- evaluate custom registered effects with lowercase key matching
                for effectTag, _ in pairs(node.effects) do
                    local customFn = Chirp.RegisteredEffects[string.lower(effectTag)]
                    if customFn then
                        local cSize, cTrans, cColor = customFn(i, now)
                        sizeOffset += (cSize or 0)
                        extraTransparency += (cTrans or 0)
                        if cColor then
                            currentColorOverride = cColor
                        end
                    end
                end

                local scale = 1.0
                if self.Preset == "Pop" then
                    scale = PopPreset.getScale(rawAge)
                end

                local targetSize = math.max(1, math.floor((label.TextSize + sizeOffset) * scale))
                local transparency = math.clamp((self.Preset == "Fade" and FadePreset.getTransparency(fadeAge) or 0) + extraTransparency, 0, 1)

                local formatted = node.nativeOpenTags
                if currentColorOverride then
                    formatted ..= string.format('<font color="%s">', currentColorOverride)
                end

                if targetSize ~= label.TextSize or transparency > 0 then
                    formatted ..= string.format('<font size="%d" transparency="%.2f">%s</font>', targetSize, transparency, char)
                else
                    formatted ..= char
                end

                if currentColorOverride then
                    formatted ..= '</font>'
                end
                formatted ..= node.nativeCloseTags

                table.insert(charBuffer, formatted)
            end

            if self.Caret and currentGrapheme < totalGraphemes then
                table.insert(charBuffer, self.Caret)
            end

            label.Text = table.concat(charBuffer)
        end)
    end

    while currentGrapheme < totalGraphemes do
        if self._stopRequested then break end

        if self._skipRequested then
            currentGrapheme = totalGraphemes
            for i = 1, totalGraphemes do
                if not revealTimestamps[i] then
                    revealTimestamps[i] = os.clock()
                end
            end
            if not isCustomAnimated then
                label.MaxVisibleGraphemes = -1
            end
            break
        end

        currentGrapheme += 1
        revealTimestamps[currentGrapheme] = os.clock()

        if not isCustomAnimated then
            label.MaxVisibleGraphemes = currentGrapheme
        end

        if parsed.commands[currentGrapheme] then
            for _, cmd in ipairs(parsed.commands[currentGrapheme]) do
                if cmd.Kind == "Pause" and not self._skipRequested then
                    self.OnPause:Fire(cmd.Value)
                    task.wait(cmd.Value)
                elseif cmd.Kind == "Speed" then
                    currentSpeed = cmd.Value
                elseif cmd.Kind == "Event" then
                    self.OnEventTriggered:Fire(cmd.Value)
                end
            end
        end

        self:_playSound()

        if currentSpeed > 0 and not self._skipRequested then
            task.wait(currentSpeed)
        end
    end

    -- disconnect static renders, but keep render loop active for custom animated effects so color cycling continues
    -- keeps render loop active for animated lines (<wave>, <spooky>, pop, glitch, etc.)
if not isCustomAnimated then
    if self._renderConn then
        self._renderConn:Disconnect()
        self._renderConn = nil
    end
    label.Text = parsed.cleanText
    label.MaxVisibleGraphemes = -1
end

    if self._promptGui and not self._stopRequested then
        self._promptGui.Visible = true
        self._promptConn = RunService.RenderStepped:Connect(function()
            if not self._promptGui or not self._promptGui.Visible or self._isTyping then
                if self._promptConn then
                    self._promptConn:Disconnect()
                    self._promptConn = nil
                end
                return
            end
            local now = os.clock()
            local bounce = math.sin(now * 8) * 3
            self._promptGui.Position = UDim2.new(1, -22, 1, -22 + bounce)
        end)
    end

    self._isTyping = false
    self._skipRequested = false
    self.OnComplete:Fire()
end

function Chirp:Skip()
    if self._isTyping then
        self._skipRequested = true
    end
end

function Chirp:Stop()
    self._stopRequested = true
    self._isTyping = false
    self:_cleanupConnections()
    if self._promptGui then
        self._promptGui.Visible = false
    end
end

function Chirp:Destroy()
    self:Stop()
    self:_cleanupConnections()
    if self._promptGui then
        self._promptGui:Destroy()
        self._promptGui = nil
    end
    self.TextLabel.Text = ""
end

return Chirp