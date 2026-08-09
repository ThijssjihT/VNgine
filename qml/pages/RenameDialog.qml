import QtQuick 2.6
import Sailfish.Silica 1.0

Dialog {
    property int    slot
    property string initialLabel
    property alias  newLabel: labelField.text

    Column {
        width: parent.width
        DialogHeader { title: qsTr("Rename save") }
        TextField {
            id:                     labelField
            width:                  parent.width
            text:                   initialLabel
            label:                  qsTr("Save label")
            placeholderText:        qsTr("Save label")
            EnterKey.iconSource:    "image://theme/icon-m-enter-accept"
            EnterKey.onClicked:     accept()
        }
    }
}
