import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"

Page {
    id: loadGamePage

    ListModel {
        id: listModel
        property bool populated

        Component.onCompleted: {
            var result = SaveManager.listSavedGames()

            for (var i = 0; i < result.saves.length; i++) {
                var row = result.saves[i]
                append({
                           slot:        row.slot,
                           label:       row.label,
                           screenshot:  row.screenshot,
                           savedAt:     row.savedAt
                })
            }
            populated = true
        }
    }

    SilicaListView {
        id:             loadGrid
        model:          listModel
        anchors.fill:   parent
        spacing:        Theme.paddingMedium

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

        delegate: ListItem {
            id:             slotDelegate
            width:          parent.width
            contentHeight:  Theme.itemSizeHuge

            MouseArea {
                onClicked: {
                    SaveManager.loadSavedGame(model.slot)
                    pageStack.replace("GameScreen.qml")
                }
                anchors.fill: parent
            }

            Image {
                id:         slotThumbnail
                anchors {
                    left:           parent.left
                    leftMargin:     Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
                width:      Theme.itemSizeHuge / Screen.width * Screen.height
                height:     Theme.itemSizeHuge
                fillMode:   Image.PreserveAspectCrop
                source:     StandardPaths.data + "/" + model.screenshot
            }

            Column {
                anchors {
                    left:           slotThumbnail.right
                    leftMargin:     Theme.paddingLarge
                    right:          parent.right
                    rightMargin:    Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
                spacing: Theme.paddingSmall

                Label {
                    text:           qsTr("Slot %1").arg(model.slot)
                    font.pixelSize: Theme.fontSizeMedium
                    color:          Theme.primaryColor
                }
                Label {
                    text:           model.label
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
                    font.pixelSize: Theme.fontSizeSmall
                    color:          Theme.secondaryColor
                }
            }

            menu: slotContextMenu

            Component {
                id: slotContextMenu
                ContextMenu {
                    MenuItem {
                        text: qsTr("Delete")
                        onClicked: {
                            // All variables don't survive the remorseAction function for some reason, so we need local variables.
                            var targetSlot = model.slot
                            var manager = SaveManager
                            var listModel = saveSlotModel
                            slotDelegate.remorseAction(qsTr("Deleting save %1").arg(targetSlot), function() {
                                manager.deleteSave(targetSlot)
                                listModel.buildSavesList()
                            })
                        }
                    }

                    MenuItem {
                        text: qsTr("Rename")
                        onClicked: {
                            // TODO: rename file
                        }
                    }
                }
            }
        }
    }
}
