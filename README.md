# 🐥 Chirp v0.4.0

> A high-performance, modular, tag-aware RichText typewriter & dialogue engine for Roblox.

**Chirp** is built for modern Roblox games requiring frame-perfect dialogue rendering, modular animation presets, stacked inline math effects, and zero-overhead client-side typing.

---

## ✨ Features

- **⚡ 60 FPS Grapheme Engine:** Uses `MaxVisibleGraphemes` and delta-time `RenderStepped` loops. Unclosed native RichText tags are completely hidden during reveal without leaking raw XML on screen.
- **🎨 4 Animation Presets:** `Classic`, `Glitch`, `Fade`, and `Pop`.
- **🌀 Multi-Effect Tag Stacking:** Nest inline math effects seamlessly (e.g. `<shake><wave><font color="#00FF88">stacked text</font></wave></shake>`).
- **⏱️ Inline Commands:** Dynamic pause duration `<pause=0.5>`, typing speed overrides `<speed=0.01>`, and custom code event triggers `<event=camera_shake>`.
- **🔻 Non-Intrusive Prompt System:** Clean bottom-right continuation prompt arrow (`▼`) that only appears and bounces when line typing completes.
- **🔊 Pitch Randomization:** Integrated grapheme-synced audio playback with dynamic pitch modulation.
- **🛡️ Enterprise Networking & GC Safety:** Zero-packet typing overhead (server sends 1 payload), automatic `RenderStepped` connection cleanup guards, and built-in UGC string sanitization (`Chirp.Sanitize()`).
- **🌐 Synced Multiplayer Cutscenes:** Pass `workspace:GetServerTimeNow()` to keep late-joining or high-ping players synchronized down to the exact millisecond.

---

## 📁 Project Structure

Chirp follows a modular architecture designed for **Rojo** or direct Roblox Studio installation:

```text
src/
├── init.luau             -- Core engine & public Chirp API
├── Signal.luau           -- Lightweight custom signal class
├── Parser.luau           -- Tag, command, and grapheme node parser
├── Presets/
│   ├── Classic.luau      -- Instant grapheme reveal
│   ├── Fade.luau         -- Smooth transparency interpolation
│   ├── Glitch.luau       -- Randomized character swapping
│   └── Pop.luau          -- Spring scale pop reveal
└── Effects/
    ├── Shake.luau        -- Real-time size offset jitter
    └── Wave.luau         -- Floating sine wave math animation

```