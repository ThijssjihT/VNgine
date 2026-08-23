import QtQuick 2.6
import Sailfish.Silica 1.0

CoverBackground {
    Label {
        id:                 label
        anchors.fill:       parent
        anchors.margins:    Theme.horizontalPageMargin
        wrapMode:           Text.WordWrap
        text:               qsTr("The lazy-ass developer didn't even design a good cover page!!!")
    }

    CoverActionList {
        id: coverAction

        CoverAction {

        }

        CoverAction {

        }
    }
}
