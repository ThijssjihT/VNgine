# VNgine
A visual novel game engine for SailfishOS

## Status

⚠️ **Under active development.** The engine is not yet ready for production use. Documented functionality may be missing or functionally discrepant.

⚠️ **Parts of the code is written with help of AI.** AI is used to give small code snippet examples, to help with bugs, and to generate repetitive work from a human made original. This used to say "co-written by AI" but these parts of the code have by now been rewritten by a human, apart from a few tiny snippets. They are clearly marked in the source.

## Overview
VNgine is used to build visual novel games. VN developers using VNgine bundle their game with the engine in a complete package, installed directly from the store or any other distribution channel. There is no separate engine installation, and no game library browsing. Your game is a single self-contained app.

You provide the story scripts, assets and metadata. The engine handles rendering, input, saves, settings and localisation.

### Design philosophy
- **Bundled engine.** Your game is a self contained application, with ease of use of your game's user in mind. Players download the game directly from Harbour or other distribution channels. There is no need for installing a seperate engine or browsing game libraries.
- **SailfishOS feel.** VNgine follows the Sailfish UI conventions as much as possible. Pull-down menus, page stack navigation, every thing is there. Your game will feel right at home on SailfishOS
- **Harbour-first.** VNgine and base games target Harbour compliance.

## Features

### Implemented
- Title screen page
- Settings screen with customizable settings
- Game screen page
- Dialogue with typewriter effect and tap-to-advance
- Basic script playback and command execution
- Sprites with positioning
- Save/Load system
- Choice system with conditional visibility
- Variable system for storing game variables

### In development
- Textbox styling and theming
- Adjustable speaker colors
- Splash screens
- Sprite objects to easily put in animations or composite sprites

### Planned
- HUD for displaying game variables
- Sprite fade transitions
- Background transitions
- Multi-language support
- Audio: sound effects, character voice, background music
- Text effects

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
        "music": {
            "label": "Music",
            "default": 80
        },
        "text_fx": {
            "label": "TextFX",
            "default": 40
        },
        "game_fx": {
            "label": "GameFX",
            "default": 80
        },
        "voice": {
            "label": "Voice",
            "default": 100
        }
    },
    "languages": {}
    "toggles": {}
    "dropdowns": {
        "difficulty": {
            "label": "Difficulty",
            "options": ["easy", "normal", "hard"],
            "default": "normal"
        }
    },

    "variables": {
        "wealth": { "type": "int", "default": 50 }
        "affection_alice": { "type": "int", "default": 5 }
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
| `audio` | Play audio |
| `show_hud` | Display a variable value in the HUD |
| `wait` | Pause for N milliseconds |
| `end` | End of game |
