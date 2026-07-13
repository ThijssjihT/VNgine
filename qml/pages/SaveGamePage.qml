import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"

Page {
    id: saveGamePage

    ListModel {
        id: saveSlotModel
        property bool populated

        function buildSavesList() {
            clear()

            var result = SaveManager.listSavedGames()
            var allSlots = {}

            //Building an object with slot number as element number, and the slot content as value.
            //This way empty slots will return undefined, which we need.
            //If would have just looped over the results, we would skip past empty slots, instead of
            //registering them as undefined.
            for (var i = 0; i < result.saves.length; i++)
                        allSlots[result.saves[i].slot] = result.saves[i]

            //Now loop over the object we just build, but add one free slot at the beginning
            for (var slot = result.maxSlot + 1; slot > 0; slot--) { //add one empty slot to the list, don't list the autosave
                var save = allSlots[slot]
                if (save) {
                    append({
                               slot:        slot,
                               emptySlot:   false,
                               label:       save.label,
                               screenshot:  save.screenshot,
                               savedAt:     save.savedAt
                    })
                } else {
                    append({
                               slot:        slot,
                               emptySlot:   true,
                               label:       "",
                               screenshot:  "",
                               savedAt:     0
                    })
                }
            }
        }

        Component.onCompleted: {
            buildSavesList()
            populated = true
        }
    }

    SilicaListView {
        id: slotListView
        anchors.fill: parent
        model: saveSlotModel

        header: PageHeader { title: qsTr("Save Game") }

        delegate: ListItem {
            id: slotDelegate
            width: parent.width
            contentHeight: Theme.itemSizeExtraLarge

            ////////////////
            // Display this when slot is empty
            Row {
                visible:                model.emptySlot
                anchors.verticalCenter: parent.verticalCenter
                x:                      Theme.horizontalPageMargin
                spacing:                Theme.paddingLarge

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    source:                 "image://theme/icon-m-add"
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text:                   qsTr("Save to slot %1").arg(model.slot)
                    color:                  slotDelegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
            }

            ////////////////
            // Display this when slot is filled
            Image {
                id:         slotThumbnail
                visible:    !model.emptySlot
                anchors {
                    left:           parent.left
                    leftMargin:     Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
                width:      Theme.itemSizeExtraLarge * 1.78   // ~320:180 aspect
                height:     Theme.itemSizeExtraLarge
                fillMode:   Image.PreserveAspectCrop
                source:     StandardPaths.data + "/" + model.screenshot
            }

            // Text column, right of the thumbnail with its own margin — same pattern as categoryText
            Column {
                visible:    !model.emptySlot
                anchors {
                    left:           slotThumbnail.right
                    leftMargin:     Theme.paddingLarge
                    right:          parent.right
                    rightMargin:    Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
                spacing:    Theme.paddingSmall

                Label {
                    width:          parent.width
                    text:           qsTr("Slot %1").arg(model.slot)
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode:       Text.WordWrap
                    truncationMode: TruncationMode.Fade
                }

                Label {
                    width:          parent.width
                    text:           model.label
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode:       Text.WordWrap
                    truncationMode: TruncationMode.Fade
                }

                Label {
                    width:          parent.width
                    text:           new Date(model.savedAt * 1000).toLocaleDateString(Qt.locale(), "yyyy/MM/dd")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color:          Theme.secondaryColor
                    wrapMode:       Text.WordWrap
                    truncationMode: TruncationMode.Fade
                }
            }

            onClicked: {
                // TODO: if slot occupied, Remorse-style overwrite confirm
                // TODO: SaveManager.stagePendingSave() -> finalizePending() -> commitToSlot(slot)
            }

            menu: model.emptySlot ? null : slotContextMenu

            Component {
                id: slotContextMenu
                ContextMenu {
                    MenuItem {
                        text: qsTr("Delete")
                        onClicked: {
                            // TODO: remorseAction delete, then SaveManager delete + rebuild model
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

        VerticalScrollDecorator {}
    }
}
