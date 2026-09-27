import QtQuick 2.6
import Sailfish.Silica 1.0

// PARTIALLY AI GENERATED AND HUMAN MODIFIED
Rectangle {
    id: choiceFrame

    property var    style:          ({})
    property bool   active:         false
    property var    choiceModel:    null
    signal          optionSelected(int index)

    readonly property var   gridStyle:      style.grid
    readonly property color baseColor:      gridStyle.background.color
    readonly property color borderColor:    gridStyle.border.color

    readonly property real  maxWidth:       parent.width - Theme.pixelRatio * (gridStyle.margins.left + gridStyle.margins.right)
    readonly property real  maxHeight:      parent.height - Theme.pixelRatio * (gridStyle.margins.top + gridStyle.margins.bottom)

    visible:        active
    width:          maxWidth * gridStyle.width
    height:         maxHeight * gridStyle.height
    radius:         gridStyle.radius * Theme.pixelRatio
    color:          Qt.rgba(baseColor.r, baseColor.g, baseColor.b, gridStyle.background.opacity)

    border.width:   gridStyle.border.width * Theme.pixelRatio
    border.color:   Qt.rgba(borderColor.r, borderColor.g, borderColor.b, gridStyle.border.opacity)

    x:  gridStyle.margins.left * Theme.pixelRatio + (maxWidth - width) / 2
    y:  gridStyle.margins.right * Theme.pixelRatio + (maxHeight - height) / 2

    Grid {
        id:         choiceGrid
        columns:    choiceFrame.gridStyle.columns
        spacing:    choiceFrame.gridStyle.spacing * Theme.pixelRatio
        x:          choiceFrame.gridStyle.padding.left * Theme.pixelRatio
        y:          choiceFrame.gridStyle.padding.top * Theme.pixelRatio

        anchors.verticalCenter:     parent.verticalCenter
        anchors.horizontalCenter:   parent.horizontalCenter

        Repeater {
            model: choiceModel
            delegate: Rectangle {
                readonly property var   optionStyle:    choiceFrame.style.option
                readonly property color baseColor:      optionStyle.background.color
                readonly property color borderColor:    optionStyle.border.color

                id:     optionBox
                width:  (choiceFrame.width - Theme.pixelRatio * (choiceFrame.gridStyle.padding.left + choiceFrame.gridStyle.padding.right) - choiceGrid.spacing * (choiceGrid.columns -1)) / choiceGrid.columns
                height: optionLabel.implicitHeight + Theme.pixelRatio * (optionStyle.padding.top + optionStyle.padding.bottom)
                radius: optionStyle.radius * Theme.pixelRatio
                color:  Qt.rgba(baseColor.r, baseColor.g, baseColor.b, optionStyle.background.opacity)

                border.width:   optionStyle.border.width * Theme.pixelRatio
                border.color:   Qt.rgba(borderColor.r, borderColor.g, borderColor.b, optionStyle.border.opacity)

                Label {
                    id:                     optionLabel
                    x:                      parent.optionStyle.padding.left * Theme.pixelRatio
                    width:                  parent.width - Theme.pixelRatio * (parent.optionStyle.padding.left + parent.optionStyle.padding.right)
                    anchors.verticalCenter: parent.verticalCenter
                    text:                   model.text
                    wrapMode:               Text.WordWrap
                    horizontalAlignment:    Text.AlignHCenter
                    color:                  Theme.primaryColor
                    font.pixelSize:         Theme.fontSizeSmall
                }
                MouseArea {
                    id:             optionMouse
                    anchors.fill:   parent
                    onClicked:      choiceFrame.optionSelected(model.optionIndex)
                }
            }
        }
    }
}
