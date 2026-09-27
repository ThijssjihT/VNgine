import QtQuick 2.6
import Sailfish.Silica 1.0

Rectangle {
    property var    style:      ({})
    property string speaker:    ""
    property string text:       ""

    readonly property color baseColor:  style.background.color
    readonly property color borderBase: style.border.color

    readonly property bool  atTop:       style.position === "top"
    readonly property bool  atCenter:    style.position === "center"

    id:             textboxLayer
    height:         (parent.height - Theme.pixelRatio * (style.margins.top + style.margins.bottom)) * style.height
    radius:         style.radius * Theme.pixelRatio
    color:          Qt.rgba(baseColor.r, baseColor.g, baseColor.b, style.background.opacity)

    border.width:   style.border.width * Theme.pixelRatio
    border.color:   Qt.rgba(borderBase.r, borderBase.g, borderBase.b, style.border.opacity)

    anchors.left:           parent.left
    anchors.leftMargin:     style.margins.left * Theme.pixelRatio
    anchors.right:          parent.right
    anchors.rightMargin:    style.margins.right * Theme.pixelRatio
    anchors.top:            atTop ? parent.top : undefined
    anchors.topMargin:      style.margins.top * Theme.pixelRatio
    anchors.bottom:         (atTop || atCenter) ? undefined : parent.bottom
    anchors.bottomMargin:   style.margins.bottom * Theme.pixelRatio
    anchors.verticalCenter: atCenter ? parent.verticalCenter : undefined

    Column {
        anchors.fill:           parent
        anchors.leftMargin:     style.padding.left * Theme.pixelRatio
        anchors.rightMargin:    style.padding.right * Theme.pixelRatio
        anchors.topMargin:      style.padding.top * Theme.pixelRatio
        anchors.bottomMargin:   style.padding.bottom * Theme.pixelRatio

        Label {
            id:             speakerLabel
            text:           textboxLayer.speaker
            color:          Theme.highlightColor
            font.pixelSize: Theme.fontSizeSmall
            font.bold:      true
            visible:        textboxLayer.speaker !== ""
        }

        Label {
            id:             dialogueLabel
            text:           textboxLayer.text
            color:          Theme.primaryColor
            font.pixelSize: Theme.fontSizeSmall
            wrapMode:       Text.WordWrap
            width:          parent.width
        }
    }
}
