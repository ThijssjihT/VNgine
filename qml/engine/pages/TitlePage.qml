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
please uncomment the lines in the footer credits
and contact me on github or on the SFOS forum

*/
////////////////////////////////////////////////////////////////////////////////////////////////////

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../GameEngine.js" as Engine
import "../components"

Page {

    property var    gameScreen
    property bool   hasPreloadedSave: false

    SilicaFlickable {
        id:             body
        anchors.top:    parent.top
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: footer.top
        clip:           true
        contentHeight:  contentColumn.height

        VerticalScrollDecorator {}

        PullDownMenu {
            MenuItem {
                text:       qsTr("Settings")
                onClicked:  pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text:       qsTr("Load Game")
                onClicked:  pageStack.push(Qt.resolvedUrl("LoadGamePage.qml"), { gameScreen: gameScreen})
            }
            MenuItem {
                text:       qsTr("New Game")
                onClicked:  {
                    gameScreen.beginNew()
                    pageStack.pop()
                }
            }
        }

        Column {
            id:         contentColumn
            width:      parent.width
            spacing:    Theme.paddingLarge

            PageHeader {
                id:     title
                title:  "Title"
            }

            Image {
                width:      parent.width
                height:     width * 9 / 16
                source:     Qt.resolvedUrl("../../game/banner.png")    //replace this for custom url from manifest???
                fillMode:   Image.PreserveAspectCrop
            }

            Separator {
                width:                  parent.width
                color:                  Theme.primaryColor
                horizontalAlignment:    Qt.AlignHCenter
            }

            Label {
                id:                 introlabel
                anchors.left:       parent.left
                anchors.right:      parent.right
                anchors.margins:    Theme.horizontalPageMargin
                text:               "A short tagline or introduction loaded from game.json will appear here."
                color:              Theme.highlightColor
                font.pixelSize:     Theme.fontSizeMedium
                wrapMode:           Text.WordWrap
            }

            Label {
                anchors.left:       parent.left
                anchors.right:      parent.right
                anchors.margins:    Theme.horizontalPageMargin
                text:               "Credits:"
                color:              Theme.primaryColor
                font.pixelSize:     Theme.fontSizeSmall
                wrapMode:           Text.WordWrap
            }

            Label {
                id:                 creditslabel
                anchors.left:       parent.left
                anchors.right:      parent.right
                anchors.margins:    Theme.horizontalPageMargin
                text:               "Content warnings, version info, or credits go here."
                color:              Theme.secondaryColor
                font.pixelSize:     Theme.fontSizeSmall
                wrapMode:           Text.WordWrap
            }
        }
    }

    Rectangle {     //AI generated
        id:             scrollFadeHint
        anchors.bottom: body.bottom
        anchors.left:   body.left
        anchors.right:  body.right
        height:         Theme.itemSizeSmall
        z:              1
        visible:        (body.contentHeight > body.height) && !body.atYEnd
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: Theme.colorScheme === Theme.LightOnDark
                                                  ? "black" : "white" }
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
                source:                 Qt.resolvedUrl("../icon.png")
                width:                  Theme.itemSizeMedium
                height:                 Theme.itemSizeMedium
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing:                Theme.paddingSmall

                Row {
                    spacing:                Theme.paddingSmall

                    LinkedLabel {
                        text:               '<a href="https://github.com/ThijssjihT/VNgine">VNgine</a>'
                        font.pixelSize:     Theme.fontSizeSmall
                        color:              Theme.highlightColor
                        anchors.baseline:   versionLabel.baseline
                    }

                    Label {
                        id:             versionLabel
                        text:           "v0.2.0"
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

    InteractionHintLabel {
        id:             hintLabel
        anchors.top:    parent.top
        opacity:        hint.running ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation {} }
    }

    TouchInteractionHint {
        id:                     hint
        anchors.verticalCenter: parent.verticalCenter
    }

    Timer {
        id:             hintStopTimer
        interval:       40000
        onTriggered:    hint.running = false
    }

    function showHint() {
        if (hint.running === true) return
        if (!SaveManager.getFlag("hintPulldownShown")) {
            runHint(qsTr("Pull down for settings"), TouchInteraction.Down, "hintPulldownShown")
        } else if (hasPreloadedSave) {
            if (!SaveManager.getFlag("hintContinueShown"))
                runHint(qsTr("Swipe right to continue"), TouchInteraction.Right, "hintContinueShown")
        } else {
            if (!SaveManager.getFlag("hintNewGameShown"))
                runHint(qsTr("Swipe right to start playing"), TouchInteraction.Right, "hintNewGameShown")
        }
    }

    function runHint(labelText, dir, flagKey) {
        hintLabel.text  = labelText
        hint.direction  = dir
        hint.running    = true
        hintStopTimer.restart()
        SaveManager.setFlag(flagKey, true)
    }

    onStatusChanged: {
        if (status === PageStatus.Active) showHint()
    }

    Component.onCompleted: {
        title.title = Engine.manifest.title
        introlabel.text = Engine.manifest.tagline

        //read all credits from the manifest file
        //append them and display them
        //first declare variable to store what we read from json
        var credits = Engine.manifest.credits
        var sections = []
        for (var key in credits) {
            var entry = credits[key]
            var lines = []
            for (var j = 0; j < entry.length; j++) {
                lines.push(entry[j])
            }
            sections.push(lines.join("\n")) //join all lines from a single credits key
        }
        creditslabel.text = sections.join("\n\n") //join all text from every credits keys
    }
}
