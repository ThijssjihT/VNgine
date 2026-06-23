import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"

Page {
    id: pageRoot

    SilicaGridView {
        id:             loadGrid
        model:          listModel
        anchors.fill:   parent
        cellWidth:      parent.width / 2
        cellHeight:     cellWidth

        ListModel {
            id: listModel
            property bool populated

            Component.onCompleted: function() {
                SaveManager.listSavedGames(listModel)
                populated = true
            }
        }

        header: PageHeader { title: qsTr("Load game")}

        ViewPlaceholder {
            enabled:    (listModel.populated && listModel.count === 0)
            text:       qsTr("No saved games found")
            hintText:   qsTr("Pull down to start a new game")
        }

        PullDownMenu {
            id: pullDownMenu

            MenuItem {
                text:       qsTr("New game")
                onClicked:  {
                    pageStack.clear()
                    pageStack.replace("GameScreen.qml")
                }
            }
        }

        delegate: GridItem {
            MouseArea {
                onClicked: {
                    SaveManager.loadSavedGame(model.slot)
                    pageStack.replace("GameScreen.qml")
                }
                anchors.fill: parent
            }

            Image {
                width:      parent.width
                height:     parent.height
                fillMode:   Image.PreserveAspectCrop
                source:     StandardPaths.data + "/" + model.screenshot
                opacity:    50
            }

            Column {
                spacing:    Theme.paddingSmall

                Label {
                    text:           qsTr("Slot %1").arg(model.slot)
                    font.pixelSize: Theme.fontSizeSmall
                    color:          Theme.secondaryColor
                }
                Label {
                    text:           model.label
                    font.pixelSize: Theme.fontSizeMedium
                    color:          Theme.primaryColor
                }
                Label {
                    text:           new Date(model.savedAt * 1000).toLocaleDateString(Qt.locale(), "yyyy/MM/dd")
                    font.pixelSize: Theme.fontSizeMedium
                    color:          Theme.primaryColor
                }
                Label {
                    text:           {
                                        var diff = Math.floor(Date.now() / 1000) - model.savedAt
                                        if (diff < 60) return qsTr("less than a minute ago")
                                        if (diff < 3600) return qsTr("%1 minutes ago").arg(Math.floor(diff / 60))
                                        if (diff < 86400) return qsTr("%1 hours ago").arg(Math.floor(diff / 3600))
                                        return new Date(model.savedAt * 1000).toLocaleDateString(Qt.locale(), "yyyy/MM/dd")
                                    }
                    font.pixelSize: Theme.fontSizeMedium
                    color:          Theme.primaryColor
                }
            }
        }
    }
}
