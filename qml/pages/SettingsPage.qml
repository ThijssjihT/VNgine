import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components" as Components
import "../GameEngine.js" as Engine

Page {
    RemorsePopup { id: remorsePopup }

    SilicaFlickable {
        anchors.fill:   parent
        contentHeight:  column.height

        VerticalScrollDecorator {}

        Column {
            id:             column
            width:          parent.width
            spacing:        Theme.paddingMedium

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
                currentIndex:           Components.Settings.get("scrollSpeed")
                onCurrentIndexChanged:  Components.Settings.set("scrollSpeed", currentIndex)
                menu: ContextMenu {
                    MenuItem { text: qsTr("Slow") }
                    MenuItem { text: qsTr("Fast") }
                    MenuItem { text: qsTr("Instant") }
                }
            }

            TextSwitch {
                id:                 autoAdvanceSwitch
                text:               qsTr("Auto-advance")
                checked:            Components.Settings.get("autoAdvance")
                onCheckedChanged:   Components.Settings.set("autoAdvance", checked)
            }

            Slider {
                width:              parent.width
                label:              qsTr("Auto-advance delay")
                minimumValue:       1.0
                maximumValue:       10.0
                stepSize:           0.5
                value:              Components.Settings.get("autoAdvanceDelay")
                valueText:          value.toFixed(1) + " s"
                enabled:            autoAdvanceSwitch.checked
                visible:            autoAdvanceSwitch.checked
                onValueChanged:     Components.Settings.set("autoAdvanceDelay", value)
            }

            // ---- Audio section ----
            SectionHeader {
                text:       qsTr("Audio")
                visible:    Components.Settings.get("numChannels") > 0
            }

            Repeater {
                model:      Components.Settings.get("numChannels")

                Slider {
                    property string channelKey: Components.Settings.get("audio_channel_" + index + "_key")

                    width:          parent.width
                    label:          Components.Settings.get("audio_" + channelKey + "_label")
                    minimumValue:   0
                    maximumValue:   100
                    stepSize:       1
                    value:          Components.Settings.get("audio_" + channelKey + "_value")
                    valueText:      value
                    onValueChanged: Components.Settings.set("audio_" + channelKey + "_value", value)
                }
            }

            // ---- Languages ----
            SectionHeader {
                text:       qsTr("Languages")
                visible:    Components.Settings.get("numLanguageSelectors") > 0
            }

            Repeater {
                model:      Components.Settings.get("numLanguageSelectors")

                ComboBox {
                    property string selectorKey:    Components.Settings.get("language_selector_" + index + "_key")
                    property var options:           Components.Settings.get("language_" + selectorKey + "_options")

                    width:                          parent.width
                    label:                          Components.Settings.get("language_" + selectorKey + "_label")
                    currentIndex:                   options.indexOf(Components.Settings.get("language_" + selectorKey + "_value"))
                    onCurrentIndexChanged:          Components.Settings.set("language_" + selectorKey + "_value", options[currentIndex])

                    menu: ContextMenu {
                        Repeater {
                            model: options
                            MenuItem { text: modelData }
                        }
                    }
                }
            }

            // ---- Seperator for additional settings
            Separator {
                width:                  parent.width
                color:                  Theme.primaryColor
                horizontalAlignment:    Qt.AlignHCenter
            }

            // --- Load other elements ---
            //AI generated

            // ---- Toggles ----
            SectionHeader {
                text:       qsTr("Content options")
                visible:    Components.Settings.get("numToggles") > 0
            }

            Repeater {
                model: Components.Settings.get("numToggles")

                TextSwitch {
                    property string toggleKey:  Components.Settings.get("toggle_key_" + index + "_key")

                    width:              parent.width
                    text:               Components.Settings.get("toggle_" + toggleKey + "_label")
                    checked:            Components.Settings.get("toggle_" + toggleKey + "_value")
                    onCheckedChanged:   Components.Settings.set("toggle_" + toggleKey + "_value", checked)
                }
            }

            // ---- Dropdowns ----
            SectionHeader {
                text:       qsTr("Game options")
                visible:    Components.Settings.get("numDropdowns") > 0
            }

            Repeater {
                model: Components.Settings.get("numDropdowns")

                ComboBox {
                    property string dropdownKey:    Components.Settings.get("dropdown_key_" + index + "_key")
                    property var options:           Components.Settings.get("dropdown_" + dropdownKey + "_options")

                    width:                  parent.width
                    label:                  Components.Settings.get("dropdown_" + dropdownKey + "_label")
                    currentIndex:           options.indexOf(Components.Settings.get("dropdown_" + dropdownKey + "_value"))
                    onCurrentIndexChanged:  Components.Settings.set("dropdown_" + dropdownKey + "_value", options[currentIndex])

                    menu: ContextMenu {
                        Repeater {
                            model: options
                            MenuItem { text: modelData }
                        }
                    }
                }
            }

            // ---- Sliders ----
            SectionHeader {
                text:       qsTr("Game parameters")
                visible:    Components.Settings.get("numSliders") > 0
            }

            Repeater {
                model: Components.Settings.get("numSliders")

                Slider {
                    property string sliderKey:  Components.Settings.get("slider_key_" + index + "_key")

                    width:          parent.width
                    label:          Components.Settings.get("slider_" + sliderKey + "_label")
                    minimumValue:   Components.Settings.get("slider_" + sliderKey + "_min")
                    maximumValue:   Components.Settings.get("slider_" + sliderKey + "_max")
                    stepSize:       Components.Settings.get("slider_" + sliderKey + "_stepsize")
                    value:          Components.Settings.get("slider_" + sliderKey + "_value")
                    valueText:      value
                    onValueChanged: Components.Settings.set("slider_" + sliderKey + "_value", value)
                }
            }

            // ---- Text fields ----
            SectionHeader {
                text:       qsTr("Unlock codes")
                visible:    Components.Settings.get("numTextfields") > 0
            }

            Repeater {
                model: Components.Settings.get("numTextfields")

                TextField {
                    property string textfieldKey:   Components.Settings.get("textfield_key_" + index + "_key")

                    width:          parent.width
                    label:          Components.Settings.get("textfield_" + textfieldKey + "_label")
                    text:           Components.Settings.get("textfield_" + textfieldKey + "_value")
                    onTextChanged:  Components.Settings.set("textfield_" + textfieldKey + "_value", text)
                }
            }
            //End AI generated content
        }
    }
}
