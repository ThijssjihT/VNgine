pragma Singleton
import QtQuick 2.6
import QtQuick.LocalStorage 2.0
import "../GameEngine.js" as Engine

QtObject {
    id: settings

    property var _db: null          //for database connection
    property var _settings: ({})    //stores the settings
    property bool ready: false

    function initialize() {
        _db = LocalStorage.openDatabaseSync(Qt.application.name, "1.0", "Game settings", 10000)
        _db.transaction(function(tx) {tx.executeSql("CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT, type TEXT)")})
        _applyManifest(Engine.manifest)
        _loadFromDatabase()
    }

    function get(key) {
        return _settings[key]
    }

    function set(key, value) {
        _settings[key] = value
        _db.transaction(function(tx) { tx.executeSql("INSERT OR REPLACE INTO settings (key, value, type) VALUES (?, ?, ?)", [key, JSON.stringify(value), typeof value])})
    }

    function _applyManifest(manifest) {
        //engine defaults
        _settings["scrollSpeed"]        = 1
        _settings["autoAdvance"]        = false
        _settings["autoAdvanceDelay"]   = 3.0

        //load audio channels from manifest
        _settings["numChannels"] = 0
        if (manifest.audio_channels) {
            /*Object.keys(manifest.audio_channels).forEach(function(channel) {        //loop through the array of declared audio channels
                _settings[channel] = manifest.audio_channels[channel]    //
            })*/
            var audioChannels = Object.keys(manifest.audio_channels)
            _settings["numChannels"] = audioChannels.length
            audioChannels.forEach(function(channel, index) {
                _settings["audio_channel_" + index + "_key"]    = channel
                _settings["audio_" + channel + "_label"]        = manifest.audio_channels[channel].label
                _settings["audio_" + channel + "_value"]        = manifest.audio_channels[channel].default
            })
        }

        //load language from manifest
        _settings["numLanguageSelectors"] = 0
        if (manifest.languages) {
            var languages = Object.keys(manifest.languages)
            _settings["numLanguageSelectors"] = languages.length
            languages.forEach(function(languageSelector, index) {
                _settings["language_selector_" + index + "_key"]         = languageSelector
                _settings["language_" + languageSelector + "_label"]    = manifest.languages[languageSelector].label
                _settings["language_" + languageSelector + "_options"]  = manifest.languages[languageSelector].options
                _settings["language_" + languageSelector + "_value"]    = manifest.languages[languageSelector].default
            })
        }

        //load optional and variable dropdown menus
        _settings["numDropdowns"] = 0
        if (manifest.dropdowns) {
            var dropdowns = Object.keys(manifest.dropdowns)
            _settings["numDropdowns"] = dropdowns.length
            dropdowns.forEach(function(dropDown, index) {
                _settings["dropdown_key_" + index + "_key"]     = dropDown
                _settings["dropdown_" + dropDown + "_label"]    = manifest.dropdowns[dropDown].label
                _settings["dropdown_" + dropDown + "_options"]  = manifest.dropdowns[dropDown].options
                _settings["dropdown_" + dropDown + "_value"]    = manifest.dropdowns[dropDown].default
            })
        }

        //load optional and variable toggles
        _settings["numToggles"] = 0
        if (manifest.toggles) {
            var toggles = Object.keys(manifest.toggles)
            _settings["numToggles"] = toggles.length
            toggles.forEach(function(toggle, index) {
                _settings["toggle_key_" + index + "_key"]   = toggle
                _settings["toggle_" + toggle + "_label"]    = manifest.toggles[toggle].label
                _settings["toggle_" + toggle + "_value"]    = manifest.toggles[toggle].default
            })
        }

        // load optional and variable sliders
        _settings["numSliders"] = 0
        if (manifest.sliders) {
            var sliders = Object.keys(manifest.sliders)
            _settings["numSliders"] = sliders.length
            sliders.forEach(function(slider, index) {
                _settings["slider_key_" + index + "_key"]   = slider
                _settings["slider_" + slider + "_label"]    = manifest.sliders[slider].label
                _settings["slider_" + slider + "_min"]      = manifest.sliders[slider].min
                _settings["slider_" + slider + "_max"]      = manifest.sliders[slider].max
                _settings["slider_" + slider + "_stepsize"] = manifest.sliders[slider].stepsize
                _settings["slider_" + slider + "_value"]    = manifest.sliders[slider].default
            })
        }

        // load optional and variable text fields
        _settings["numTextfields"] = 0
        if (manifest.textfields) {
            var textfields = Object.keys(manifest.textfields)
            _settings["numTextfields"] = textfields.length
            textfields.forEach(function(textfield, index) {
                _settings["textfield_key_" + index + "_key"]  = textfield
                _settings["textfield_" + textfield + "_label"] = manifest.textfields[textfield].label
                _settings["textfield_" + textfield + "_value"] = manifest.textfields[textfield].default
            })
        }
    }

    function _loadFromDatabase() {
        _db.transaction(function(tx) {
            var result = tx.executeSql("SELECT key, value, type FROM settings")
            for (var i = 0; i < result.rows.length; i++) {
                var row = result.rows.item(i)
                if (_settings.hasOwnProperty(row.key)) {
                    _settings[row.key] = JSON.parse(row.value)
                }
            }
        })
    }
}
