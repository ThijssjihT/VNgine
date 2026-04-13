//////////////////////////////////////s///////////////////////////////////////////////////////////////
/*

Do not alter this page.
Only alter files in folders:
 -  icons/
 -  qml/game/
Contents of the title page are set by changing:
 -  game/banner.png
 -  game/game.json


If any further alterations must be made
please contact me on github or on the SFOS forum
and uncomment the lines in the footer credits

*/
////////////////////////////////////////////////////////////////////////////////////////////////////

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../GameEngine.js" as Engine

Page {
    SilicaFlickable {
        anchors.top:    parent.top
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: footer.top
        //contentHeight:  column.height + Theme.paddingLarge

        PullDownMenu {
            MenuItem {
                text:       qsTr("Settings")
                onClicked:  pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text:       qsTr("Load Game")
                onClicked:  pageStack.push(Qt.resolvedUrl("LoadGamePage.qml"))
            }
            MenuItem {
                text:       qsTr("New Game")
                onClicked:  {
                    Engine.initVariables()
                    Engine.loadScene(Engine.manifest.entry_scene)
                    pageStack.replace("GameScreen.qml")
                }
            }
        }

        Column {
            width:      parent.width
            spacing:    Theme.paddingLarge

            PageHeader {
                title:  qsTr("Title")
            }

            Image {
                width:      parent.width
                height:     width * 9 / 16
                source:     Qt.resolvedUrl("../game/banner.png")    //replace this for custom url from manifest???
                fillMode:   Image.PreserveAspectCrop
            }

            Button {
                anchors.horizontalCenter:   parent.horizontalCenter
                text:                       qsTr("Continue")
                enabled:                    false                   //should check for active game or otherwise most recent save
                onClicked: {
                    pageStack.replace(Qt.resolvedUrl("GamePage.qml"))
                }
            }

            Separator {
                width:                  parent.width
                color:                  Theme.secondaryColor
                horizontalAlignment:    Qt.AlignHCenter
            }

            Label {
                id:             introlabel
                x:              Theme.horizontalPageMargin
                width:          parent.width - 2 * Theme.horizontalPageMargin
                text:           qsTr("A short tagline or introduction loaded from game.json will appear here.")
                color:          Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
                wrapMode:       Text.WordWrap
            }

            Label {
                id:             creditslabel
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("Content warnings, version info, or credits go here.")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
            }
        }
    }

    Column {
        id:                 footer
        anchors.bottom:     parent.bottom
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.margins:    Theme.horizontalPageMargin
        spacing:            Theme.paddingMedium

        Separator {
            width:                  parent.width
            color:                  Theme.primaryColor
            horizontalAlignment:    Qt.AlignHCenter
        }

        Row {
            spacing:            Theme.paddingMedium
            height:             logo.height + Theme.paddingLarge

            Image {
                id:                     logo
                source:                 Qt.resolvedUrl("../components/icon.png")
                width:                  Theme.itemSizeMedium
                height:                 Theme.itemSizeMedium
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing:                Theme.paddingSmall

                Row {
                    spacing:                Theme.paddingSmall

                    Label {
                        text:               "VNgine"
                        font.pixelSize:     Theme.fontSizeSmall
                        color:              Theme.highlightColor
                        anchors.baseline:   versionLabel.baseline
                    }

                    Label {
                        id:             versionLabel
                        text:           "v0.1.0"
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color:          Theme.secondaryColor
                    }
                }

/*
                Label {
                    text:               "Modified engine version" //feel free to change this text to give yourself some credit
                    font.pixelSize:     Theme.fontSizeSmall
                    color:              Theme.primaryColor
                }

                Label {
                    text:               "Originally written:"
                    font.pixelSize:     Theme.fontSizeSmall
                    color:              Theme.primaryColor
                }

*/

                Label {
                    text:               "By Thijs Janssen"
                    font.pixelSize:     Theme.fontSizeSmall
                    color:              Theme.primaryColor
                }
            }
        }
    }

    Component.onCompleted: {
        Engine.loadManifest(Qt.resolvedUrl("../game"))
        introlabel.text = Engine.manifest.Tagline
        // creditslabel reads a list, and must loop over the list
    }
}
