# VNgine
A visual novel game engine for SailfishOS

## Status

⚠️ **Under active development.** The engine is not yet ready for production use. Documented functionality may be missing or functionally discrepant.

⚠️ **Parts of the code is written with help of AI.** AI is used to give small code snippet examples, to help with bugs, and to generate repetitive work from a human made original. This used to say "co-written by AI" but these parts of the code have by now been re**written by a human**, apart from a few tiny snippets. They are clearly marked in the source.

## Overview
VNgine is used to build visual novel games. VN developers using VNgine bundle their game with the engine in a complete package, installed directly from the store or any other distribution channel. There is no separate engine installation, and no game library browsing. Your game is a single self-contained app.

You provide the story scripts, assets and metadata. The engine handles rendering, input, saves, settings and localisation.

### Design philosophy
- **Bundled engine.** Your game is a self contained application, with ease of use of your game's user in mind. Players download the game directly from Harbour or other distribution channels. There is no need for installing a seperate engine or browsing game libraries.
- **SailfishOS feel.** VNgine follows the Sailfish UI conventions as much as possible. Pull-down menus, page stack navigation, every thing is there. Your game will feel right at home on SailfishOS
- **Harbour-first.** VNgine and base games target Harbour compliance.

## Known issues

VNgine is pre-alpha. The following are known and not yet fixed.

### Not yet implemented
These commands are accepted in scripts but currently do nothing. The engine logs "Unknown command, skipping" and carries on.

- `end`: there is no way to finish a story with an end card yet
- `wait`
- `show_hud`, and the HUD itself
- `audio_voice` (voiced lines)
- `transition` on `bg` and `sprite_remove` (backgrounds and sprites change instantly)
- `text_key` localisation: lines using a `text_key` show the key in brackets instead of translated text
- `alt_scene` on choice options

### Styling
- **Choice style:** the choice grid height is not defined in the engine defaults, so `grid.height` may produce a broken layout. The vertical position of the grid also uses the wrong margin, so `grid.margins.top` has no effect.
- **Choice option text colour:** `option.text.color` is ignored. Option text always uses the Sailfish primary colour.
- **Textbox position `center`:** ignores the top and bottom margins. `top` and `bottom` follow them.
- **HUD style:** can be defined, but there is nothing to apply it to yet.

### Scripting pitfalls
- A loop made only of `jump` / `jump_if` commands, with no `say` or `choice` in it, crashes the game with a stack overflow instead of looping.
- If a `jump` has both `label` and `scene`, `label` wins and `scene` is silently ignored.
- Duplicate labels in a scene are not an error: the last one wins and the earlier one becomes unreachable.
- A `choice` whose options all have conditions that evaluate to false is skipped entirely, so the player never sees the menu.
- `set` copies a value from a variable or setting with a `from` block. `from_setting` is not supported.
- Choice options route with `label` / `scene`, not `next`.
- Variables and settings share one lookup namespace. A variable and a setting with the same name shadow each other.
- `mul` on a variable that was never set gives 0.

### Limits
- Toggles, dropdowns, text fields and sliders are designed for at most four each. The engine does not enforce this, but only four are supported in the design.
- A variable's `type` in `game.json` is documentation only. The engine reads only `default`.

### Other
- Documentation is incomplete and may not match the engine in places.

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
- Textbox styling and theming
- Sprite objects to easily put in animations or composite sprites

### In development
- Adjustable speaker colors
- Splash screens
- Audio: sound effects, character voice, background music

### Planned
- HUD for displaying game variables
- Sprite fade transitions
- Background transitions
- Multi-language support
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
