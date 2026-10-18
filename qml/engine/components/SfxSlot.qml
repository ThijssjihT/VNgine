import QtQuick 2.6
import QtMultimedia 5.0

Audio {
    property bool busy: false

    onStopped: busy = false
    onError: {
        console.warn("audio_sfx failed: " + errorString)
        stop()
        busy = false
    }
}
