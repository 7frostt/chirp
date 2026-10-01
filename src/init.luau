--!strict
--[=[
    Chirp v0.1.0
    A lightweight, tag-aware RichText typewriter & dialogue engine for Roblox.
    Author: 7frostt
]=]

local SoundService = game:GetService("SoundService")

local Signal = require(script.Signal)
local Parser = require(script.Parser)
local GlitchPreset = require(script.Presets.Glitch)

local Chirp = {}
Chirp.__index = Chirp

export type PresetType = "Classic" | "Glitch" | "Fade" | "Pop"

export type ChirpOptions = {
    Speed: number?,
    Preset: PresetType?,
    Sound: Sound?,
    RandomizePitch: boolean?,
    PitchRange: Vector2?,
}

export type ChirpInstance = {
    TextLabel: TextLabel,
    Speed: number,
    Preset: PresetType,
    Sound: Sound?,
    RandomizePitch: boolean,
    PitchRange: Vector2,
    
    OnComplete: any,
    OnPause: any,
    OnEventTriggered: any,
    
    _isTyping: boolean,
    _skipRequested: boolean,
    _stopRequested: boolean,
    
    Type: (self: ChirpInstance, text: string) -> (),
    Skip: (self: ChirpInstance) -> (),
    Stop: (self: ChirpInstance) -> (),
    Destroy: (self: ChirpInstance) -> (),
}

function Chirp.new(textLabel: TextLabel, options: ChirpOptions?): ChirpInstance
    assert(textLabel and textLabel:IsA("TextLabel"), "[Chirp]: TextLabel instance expected.")

    options = options or {}
    textLabel.RichText = true

    local self = setmetatable({}, Chirp)

    self.TextLabel = textLabel
    self.Speed = options.Speed or 0.03
    self.Preset = options.Preset or "Classic"
    self.Sound = options.Sound
    self.RandomizePitch = if options.RandomizePitch ~= nil then options.RandomizePitch else true
    self.PitchRange = options.PitchRange or Vector2.new(0.95, 1.05)

    self.OnComplete = Signal.new()
    self.OnPause = Signal.new()
    self.OnEventTriggered = Signal.new()

    self._isTyping = false
    self._skipRequested = false
    self._stopRequested = false

    return (self :: any) :: ChirpInstance
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

function Chirp:Type(rawText: string)
    if self._isTyping then
        self:Stop()
        task.wait()
    end

    self._isTyping = true
    self._skipRequested = false
    self._stopRequested = false

    local tokens = Parser.parseText(rawText)
    local currentSpeed = self.Speed
    local label = self.TextLabel

    label.Text = ""

    local accumulatedText = ""

    for _, token in ipairs(tokens) do
        if self._stopRequested then break end

        if token.Kind == "Tag" then
            accumulatedText ..= token.Value
            label.Text = accumulatedText
        elseif token.Kind == "Pause" then
            if not self._skipRequested and token.Data then
                self.OnPause:Fire(token.Data)
                task.wait(token.Data)
            end
        elseif token.Kind == "Speed" then
            if token.Data then
                currentSpeed = token.Data
            end
        elseif token.Kind == "Event" then
            self.OnEventTriggered:Fire(token.Value)
        elseif token.Kind == "Text" then
            if self._skipRequested then
                accumulatedText ..= token.Value
            else
                self:_playSound()

                if self.Preset == "Glitch" then
                    GlitchPreset.apply(label, accumulatedText, currentSpeed)
                end

                accumulatedText ..= token.Value
                label.Text = accumulatedText

                if currentSpeed > 0 then
                    task.wait(currentSpeed)
                end
            end
        end
    end

    if self._skipRequested then
        local fullText = ""
        for _, token in ipairs(tokens) do
            if token.Kind == "Text" or token.Kind == "Tag" then
                fullText ..= token.Value
            end
        end
        label.Text = fullText
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
end

function Chirp:Destroy()
    self:Stop()
    self.TextLabel.Text = ""
end

return Chirp