# VNgine
A visual novel game engine for SailfishOS

## Status

⚠️ **Under active development.** The engine is not yet ready for production use. Documented functionality may be missing or functionaly discrepant.

⚠️ **Parts of the code is co-written by AI.** AI is used to give code examples, and to help with bugs. Purely AI generated code is now being rewritten by a human. Engine.js is still largely made by AI, but comments, improvements and approving is done by a human.

## Overview
VNgine is used to build visual novel games. VN developers using VNgine bundle their game with the engine in a complete package, installed directly from the store or any other distribution channel. There is no seperate engine installation, and no game library browsing. Your game is a single self-contained app.

You provide the story scripts, assets and metadata. The engine handles rendering, input, saves, settings and localisation.

### Design philosophy
- **Bundled engine.** Your game is a self contained application, with ease of use of your game's user in mind. Players download the game directly from Harbour or other distribution channels. There is no need for installing a seperate engine or browsing game libraries.
- **SailfishOS feel.** VNgine follows the Sailfish UI conventions as much as possible. Pull-down menus, page stack navigation, every thing is there. Your game will feel right at home on SailfishOS
- **Harbour-first.** VNgine and base games target Harbour compliance.
- **Adjustable settings.** VNgine contains basic settings, like text speed and volume sliders. You can adjust settings available to your players. For example, a player name input field, or adult content or arachnofobia enable/disable toggles.

## Features

⚠️ Features flagged as implemented might not yet be on github, as I am rewriting AI generated pages.
### Implemented
- Title screen with pull-down menu (New Game, Load Game, Settings)
- Settings screen: text speed, auto-advance, audio volume per channel, language selection, 18+ content toggle. Settings are still non-functional and volatile for now.
- Landscape game screen with background
- Dialogue with typewriter effect and tap-to-advance
- Basic script playback and command execution

### In development
- SFOS remorse timer confirmation
- Sprites with positioning
- Choice system with conditional visibility
- Variable system for storing game variables
- Audio playback: background music
- Non-volatile settings

### Planned
- HUD for displaying game variables
- Sprite fade transitions
- Background transitions
- Save/Load system
- Multi-language support
- Audio: sound effects, character voice
- Customizable settings

## Quick Start

### For Game Authors

Create a game folder inside your app bundle:

```
qml/game/
├── game.json              # Manifest: metadata, settings, variables
├── banner.png             # Title screen banner
├── script/
│   ├── scene_0000.json    # Start scene (entry_scene)
│   └── scene_0001.json
├── assets/
│   ├── bg/                # Background images (JPEG/PNG)
│   ├── sprites/           # Character sprites (PNG, transparent)
│   └── audio/
│       ├── music/
│       ├── sfx/
│       └── voice/
└── i18n/
    ├── en.json
    └── nl.json
```

### Example: game.json

```json
{
  "title": "My Story",
  "version": "1.0.0",
  "default_language": "en",
  "entry_scene": "scene_0000",
  "has_adult_content": false,
  "audio_channels": {
    "music": true,
    "text_fx": true,
    "game_fx": true,
    "voice": false
  },
  "variables": {
    "chapter_title": { "type": "string", "default": "Prologue" },
    "affection_alice": { "type": "int", "default": 0 }
  }
}
```

### Example: scene_0000.json

```json
{
  "id": "scene_0000",
  "commands": [
    { "cmd": "bg", "image": "bg/forest_day.jpg" },
    { "cmd": "sprite", "id": "alice", "image": "sprites/alice_happy.png", "position": "center" },
    { "cmd": "say", "speaker": "Alice", "text_key": "s0000_01" },
    { "cmd": "say", "speaker": null, "text": "The leaves whisper." },
    { "cmd": "jump", "scene": "scene_0001" }
  ]
}
```

### Complete command reference
See the AI generated [Design Document](vn-engine-design-v3.docx) (TODO: upload document) for complete command reference and script format specification. A human generated command reference can be found below:

| Command | Purpose |
|---------|---------|
| `bg` | Set background image |
| `sprite` | Show or position a character sprite |
| `sprite_remove` | Remove a sprite |
| `say` | Display dialogue with optional speaker name |
| `choice` | Present player options |
| `set` | Change a variable value (add, subtract, set) |
| `jump` | Unconditional scene transition |
| `jump_if` | Conditional scene transition based on variable state |
| `audio_bg` | Start/stop background music |
| `audio_sfx` | Play a sound effect |
| `audio_voice` | Play a voiced line |
| `show_hud` | Display a variable value in the HUD |
| `wait` | Pause for N milliseconds |
| `end` | End of game |
