.pragma library

var dbName        = Qt.application.name
var dbVersion     = "1.0"
var dbDescription = "VNgine data"
var dbSize        = 1000000

var thumbScreenFraction = 0.4   // as a fraction of screen width

var audioChannels = [
    { key: "music",      label: "Music",         defaultVolume: 80,  hidden: false },
    { key: "voice",      label: "Voice",         defaultVolume: 100, hidden: true  },  // until voice is built
    { key: "game_fx",    label: "Sound effects", defaultVolume: 80,  hidden: false },
    { key: "looping_fx", label: "Ambience",      defaultVolume: 80,  hidden: false },
    { key: "text_fx",    label: "Text sounds",   defaultVolume: 40,  hidden: true  }   // until text_fx is built
]

var textSettings = {
    scrollSpeed:        1,
    autoAdvance:        false,
    autoAdvanceDelay:  3.0
}

var typewriterIntervals = [40, 15, 0] // ms per character, indexed by scrollSpeed: 0 slow, 1 fast, 2 instant
