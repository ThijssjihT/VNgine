import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components" as Components
import "../GameEngine.js" as Engine

Page {
    RemorsePopup { id: remorsePopup }

    SilicaFlickable {
        anchors.fill:   parent

        Column {
            anchors.fill:   parent
            spacing:        Theme.paddingLarge

            PullDownMenu {
                MenuItem {
                    text:       qsTr("Revert all settings")
                    onClicked:  remorsePopup.execute(qsTr("Reverting settings"), Components.Settings.revertAll())
                }
            }

            PageHeader { title: qsTr("Settings") }

            // ---- Text section ----
            SectionHeader { text: qsTr("Text") }

            ComboBox {
                label:                  qsTr("Text scroll speed")
                currentIndex:           Components.Settings.scrollSpeed
                onCurrentIndexChanged:  Components.Settings.scrollSpeed = currentIndex
                menu: ContextMenu {
                    MenuItem { text: qsTr("Slow") }
                    MenuItem { text: qsTr("Fast") }
                    MenuItem { text: qsTr("Instant") }
                }
            }

            TextSwitch {
                text:               qsTr("Auto-advance")
                checked:            Components.Settings.autoAdvance
                onCheckedChanged:   Components.Settings.autoAdvance = checked
            }

            Slider {
                width:              parent.width
                label:              qsTr("Auto-advance delay")
                minimumValue:       1.0
                maximumValue:       10.0
                stepSize:           0.5
                value:              Components.Settings.autoAdvanceDelay
                valueText:          value.toFixed(1) + " s"
                enabled:            Components.Settings.autoAdvance
                onValueChanged:     Components.Settings.autoAdvanceDelay = value
            }

            // ---- Audio section ----
            SectionHeader { text: qsTr("Audio") }

            //TODO: load sliders from manifest

            // ---- Other section ----
            SectionHeader { text: qsTr("Other") }

            ComboBox {
                label: qsTr("Language")
                enabled: false  // stub: only one language
                menu: ContextMenu {
                    MenuItem { text: "English" }
                }
            }

            TextSwitch {
                text: qsTr("18+ content")
                checked: Components.Settings.adultContent
                enabled: false  // stub: this shouldn't be fixed, but loaded from manifest
                description: qsTr("This game has no adult content")
                onCheckedChanged: Components.Settings.adultContent = checked
            }
        }
    }
}
