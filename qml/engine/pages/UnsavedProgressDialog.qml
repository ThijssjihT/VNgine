import QtQuick 2.6
import Sailfish.Silica 1.0

Dialog {
    id: unsavedProgressDialog

    property Page   gameScreen
    property string action:     "new"
    property int    loadSlot:   -1

    acceptDestination:          gameScreen
    acceptDestinationAction:    PageStackAction.Pop

    onAccepted: gameScreen.runAction({ action: action, slot: loadSlot})

    SilicaFlickable {
        anchors.fill:   parent
        contentHeight:  column.height

        Column {
            id:         column
            width:      parent.width
            spacing:    Theme.paddingLarge

            DialogHeader {
                acceptText: action === "load" ? qsTr("Load") : qsTr("StartOver")
            }

            Label {
                x:              Theme.horizontalPageMargin
                width:          parent.width - 2 * Theme.horizontalPageMargin
                wrapMode:       Text.WordWrap
                color:          Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
                text:           action === "load" ? qsTr("Load slot %1?").arg(loadSlot)
                                                  : qsTr("Start a new game?")
            }

            Label {
                x:              Theme.horizontalPageMargin
                width:          parent.width - 2 * Theme.horizontalPageMargin
                wrapMode:       Text.WordWrap
                color:          Theme.secondaryHighlightColor
                text:           qsTr("You have played on since your last save. That progress will be lost. Cancel and save first if you want to keep your progress.")
            }
        }
    }
}
