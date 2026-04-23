import QtQuick 2.6
import Sailfish.Silica 1.0
import "pages"
import "components" as Components
import "GameEngine.js" as Engine

ApplicationWindow {
    initialPage:            Component { TitlePage { } }
    cover:                  Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations:    defaultAllowedOrientations

    Component.onCompleted: {
        Components.Settings.initialize()
    }
}
