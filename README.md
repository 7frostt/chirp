# Chirp

Chirp is a lightweight, tag-aware RichText typewriter and dialogue engine for Roblox. It provides frame-perfect grapheme rendering, stacked math effects, custom tag registration, and zero-GC memory optimization.

---

## Installation

Place the `Chirp` module into `ReplicatedStorage`.

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Chirp = require(ReplicatedStorage:WaitForChild("Chirp"))
```

---

## Quick Example

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Chirp = require(ReplicatedStorage:WaitForChild("Chirp"))

-- Register a custom inline effect
Chirp.RegisterEffect("pulse", function(index, time)
    return math.sin(time * 8) * 3, 0
end)

-- Create typewriter instance
local dialogue = Chirp.new(script.Parent.TextLabel, {
    Speed = 0.04,
    Preset = "Pop",
    ShowPrompt = true,
})

-- Type line with tags and commands
dialogue:Type("System ready! <pause=0.4> Welcome to <wave><pulse>Chirp Engine</pulse></wave>.")
```

---

## Key Features

- **Grapheme Rendering**: Render text frame-perfectly without raw XML tags leaking during reveals.
- **Custom Effect API**: Register custom dynamic text tags globally using `Chirp.RegisterEffect()`.
- **Effect Stacking**: Combine multiple tags simultaneously (e.g., `<shake><wave>text</wave></shake>`).
- **Inline Commands**: Pause dialogue `<pause=0.5>`, adjust typing speed `<speed=0.01>`, or trigger events `<event=name>`.
- **Multiplayer Sync**: Synchronize dialogue across all clients using `workspace:GetServerTimeNow()`.
- **UGC Sanitization**: Escape user text input safely using `Chirp.Sanitize(text)`.

---

## API Quick Reference

### Static Functions
- `Chirp.new(textLabel, options)`: Creates a new typewriter instance.
- `Chirp.RegisterEffect(name, callback)`: Registers a global inline effect tag.
- `Chirp.Sanitize(text)`: Escapes raw XML characters (`<`, `>`, `&`).

### Instance Methods
- `:Type(text, startTime?)`: Types out dialogue text.
- `:Skip()`: Instantly reveals all text for the current line.
- `:Stop()`: Halts active typing immediately.
- `:Destroy()`: Cleans up memory connections and instances.

### Presets
`"Classic"`, `"Glitch"`, `"Fade"`, `"Pop"`

---

## License

MIT License.