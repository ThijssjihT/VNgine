import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"

Page {
    id: saveGamePage

    ListModel {
        id: saveSlotModel
        property bool populated

        Component.onCompleted: function() {
            SaveManager.listSavedGames(saveSlotModel)
            populated = true
        }
    }

    SilicaListView {
        id: slotListView
        anchors.fill: parent
        model: saveSlotModel

        header: PageHeader {
            title: qsTr("Save Game")
        }

        delegate: ListItem {
            id: slotDelegate
            width: parent.width
            contentHeight: Theme.itemSizeExtraLarge

            // Thumbnail, left-anchored with margin — mirrors ArticleDelegate's image treatment
            Image {
                id: slotThumbnail
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
                width: Theme.itemSizeExtraLarge * 1.78   // ~320:180 aspect
                height: Theme.itemSizeExtraLarge
                fillMode: Image.PreserveAspectCrop
                source: StandardPaths.data + "/" + model.screenshot
            }

            // Text column, right of the thumbnail with its own margin — same pattern as categoryText
            Column {
                anchors {
                    left: slotThumbnail.right
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
                spacing: Theme.paddingSmall

                Label {
                    width: parent.width
                    text: qsTr("Slot %1").arg(model.slot)
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode: Text.WordWrap
                    truncationMode: TruncationMode.Fade
                }

                Label {
                    width: parent.width
                    text: model.label
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode: Text.WordWrap
                    truncationMode: TruncationMode.Fade
                }

                Label {
                    width: parent.width
                    text: savedAt !== undefined ? new Date(model.savedAt * 1000).toLocaleDateString(Qt.locale(), "yyyy/MM/dd") : qsTr("Tap to save here")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    wrapMode: Text.WordWrap
                    truncationMode: TruncationMode.Fade
                }
            }

            onClicked: {
                // TODO: if slot occupied, Remorse-style overwrite confirm
                // TODO: SaveManager.stagePendingSave() -> finalizePending() -> commitToSlot(slot)
            }

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Delete")
                    visible: label !== undefined
                    onClicked: {
                        // TODO: remorseAction delete, then SaveManager delete + model.remove(index)
                    }
                }
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    // TODO: reload saveSlotModel from SaveManager
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
