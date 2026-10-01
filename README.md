# Chirp

**Chirp** is a lightweight, tag-aware RichText typewriter & dialogue engine for Roblox Studio. It handles custom XML tags seamlessly without glitching text, supports customizable animation presets, embeds inline commands, and features pitch-randomized typing audio.

---

## ✨ Features

- **🛡️ Tag-Aware Parsing:** Automatically skips XML tags (`<font>`, `<b>`, `<i>`) so markup never types out letter-by-letter.
- **🎨 Animation Presets:** Choose from built-in presets (`Classic`, `Fade`, `Glitch`, `Pop`) or use inline tags like `<shake>` and `<wave>`.
- **⏱️ Inline Commands:** Embed dynamic pauses (`<pause=0.5>`), speed shifts (`<speed=0.01>`), and custom event triggers (`<event=nod>`) directly inside dialogue strings.
- **🎵 Pitch-Randomized Audio:** Built-in typing sound support with configurable pitch variation for natural-sounding dialogue.
- **⚡ Clean Signals:** Exposes `.OnComplete()`, `.OnPause()`, and `.OnEventTriggered()` signals for cutscenes and UI integration.

---

## 📦 Installation

### Wally
Add Chirp to your `wally.toml`:
```toml
Chirp = "7frostt/chirp@0.1.0"
```

### Manual Installation
Download `Chirp.luau` or the `.rbxm` file from the [Releases](https://github.com/7frostt/chirp/releases) tab and drop it directly into `ReplicatedStorage`.

---

## 🚀 Quick Start

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Chirp = require(ReplicatedStorage.Chirp)

local label = script.Parent.TextLabel

local dialogue = Chirp.new(label, {
    Speed = 0.03,
    Preset = "Glitch",
    RandomizePitch = true,
})

-- Types out seamlessly without breaking the red font tag or shaking word!
dialogue:Type("Hello <font color='#FF0000'>Bro!</font> <pause=0.5> Welcome to <shake>Chirp</shake>.")
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).