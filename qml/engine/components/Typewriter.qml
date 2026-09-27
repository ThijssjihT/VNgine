import QtQuick 2.6

QtObject {
    id: typewriter

    property string fullText:       ""
    property string visibleText:    ""
    property int    interval:       15  //hardcoded, will need to use settings later

    readonly property bool animating: _timer.running

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
        fullText        = text
        visibleText     = ""
        _timer.start()
    }

    function skip() {
        _timer.stop()
        visibleText     = fullText
    }

    function setImmediate(text) {
        fullText    = text
        visibleText = text
    }
}
