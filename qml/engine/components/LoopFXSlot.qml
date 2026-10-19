import QtQuick 2.6
import QtMultimedia 5.0

Item {
    property bool   busy:       false
    property string loopId:     ""
    property string file:       ""
    property real   baseVolume: 1.0

    property alias  source:     audio.source
    property alias  volume:     audio.volume
    property alias  fader:      fade

    function play() {
        audio.play()
    }

    function stop() {
        audio.stop()
    }

    Audio {
        id:        audio
        loops:     Audio.Infinite
        onStopped: busy = false
        onError: {
            console.warn("looping_fx failed: " + errorString)
            stop()
            busy = false
        }
    }

    PropertyAnimation {
        id:         fade
        target:     audio
        property:   "volume"
        property bool stopOnFinish: false
        onStopped:  if (stopOnFinish) audio.stop()
    }
}
