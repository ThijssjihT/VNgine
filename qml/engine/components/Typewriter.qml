import QtQuick 2.6
import "Constants.js" as Constants

QtObject {
    id: typewriter

    property string fullText:       ""
    property string visibleText:    ""
    property int    speed:          1   // 0 slow, 1 fast, 2 instant. Set from the scrollSpeed setting.
    readonly property int   interval:   Constants.typewriterIntervals[speed]
    readonly property bool  animating:  _timer.running

    property Timer  _timer:         Timer{
        interval:   typewriter.interval
        repeat:     true
        onTriggered: {
            if (typewriter.visibleText.length < typewriter.fullText.length) {
                typewriter.visibleText = typewriter.fullText.substring(0, typewriter.visibleText.length + 1)
            } else {
                typewriter._timer.stop()
            }
        }
    }

    function start(text) {
        if (speed === 2) {
            setImmediate(text)
            return
        }
        fullText        = text
        visibleText     = ""
        _timer.start()
    }

    function skip() {
        _timer.stop()
        visibleText     = fullText
    }

    function setImmediate(text) {
        _timer.stop()
        fullText    = text
        visibleText = text
    }
}
