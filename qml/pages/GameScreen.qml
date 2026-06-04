import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components" as Components
import "../GameEngine.js" as Engine

Page {
    id:                     gameScreen
    allowedOrientations:    Orientation.Landscape

    property string currentBg:          ""
    property string speakerName:        ""
    property string fullText:           ""
    property string visibleText:        ""
    property bool   textAnimating:      false
    property real   spriteClearance:    0

    RemorsePopup { id: remorsePopup }

/////////////////////////
// --- Spritemodel ---

    ListModel { id: spriteModel }

    function showSprite(sId, src, pos) {
        for (var i = 0; i < spriteModel.count; i++) {
            if (spriteModel.get(i).spriteId === sId) {
                spriteModel.setProperty(i, "spriteSource", src)
                spriteModel.setProperty(i, "position", pos)
                /*
                  We can't set a x and y position here, because it will need to reference
                  object sizes, like the size of the sprite and such. At the point where
                  this function runs, the spriteModel is being populated, so nothing has
                  yet been drawn. So we give the Image object the raw data, and let it
                  calculate its own position.
                */
                return
            }
        }
        spriteModel.append({ "spriteId": sId, "spriteSource": src, "position": pos })
    }

    function removeSprite(sId) {
        for (var i = 0; i < spriteModel.count; i++)
            if (spriteModel.get(i).spriteId === sId) { spriteModel.remove(i); return }
    }

    function clearSprites() { spriteModel.clear() }

    function spriteX(pos, sprWidth) {
        if (pos === "left")     return 0
        if (pos === "right")    return gameRoot.width - sprWidth
        if (pos.indexOf("%") !== -1)                    //If exact x and y coordinates are given
            return parseFloat(pos.split(",")[0] / 100 * gameRoot.width - sprWidth / 2)
        return (gameRoot.width - sprWidth) / 2          //Default center position
    }

    function spriteY(pos, sprHight) {
        if (pos.indexOf("%") !== -1)
            return parseFloat(pos.split(",")[1]) / 100 * gameRoot.height - sprHight
        return gameRoot.height - sprHight - spriteClearance   // presets: bottom
    }

// --- End Spritemodel
/////////////////////////


/////////////////////////
// --- Typewriter ---
    Timer {
        id:         typewriterTimer
        interval:   15
        repeat:     true
        onTriggered: {
            if (visibleText.length < fullText.length) {
                visibleText = fullText.substring(0, visibleText.length + 1)
            } else {
                typewriterTimer.stop()
                textAnimating = false
            }
        }
    }

    function startTypewriter() {
        visibleText     = ""
        textAnimating   = true
        typewriterTimer.start()
    }

    function skipTypewriter() {
        typewriterTimer.stop()
        visibleText     = fullText
        textAnimating   = false
    }
// --- End Typewriter ---
/////////////////////////

/////////////////////////
// --- Game logic ---

    /*
      This is where the game data is processed. It is where the magic happens ;)
      There is no game loop. It will process a command, and then process the next command,
      until player interaction is required. Then everyting will stop, and the next command
      will only be processed after user input.
    */

    function processNext() {
        var command = Engine.nextCommand()

        if (command === null) {
            // the scene ended without jump or end. This is an authoring error.
            // treat as implicit end
            console.warn("Scene ended without jump or end command")
            pageStack.pop()
            return
        }

        switch (command.cmd) {
            /*
              only 4 commands implemented so far.
              TODO: really? do I really need to be this explisit? Do the other commands!
              Check the design file for reference
              Oh, and change the default switch key while your at it.
            */

        case "bg":
            currentBg = Engine.gamePath + "/assets/" + command.image
            processNext()  //immediately process next command
            break

        case "say":
            speakerName = command.speaker || ""
            fullText    = Engine.resolveText(command)
            startTypewriter()
            // stop here. Next command is processed after player input.
            break

        case "jump":
            if (command.label) {
                Engine.jumpToLabel(command.label)
            } else if (command.scene) {
                Engine.loadScene(command.scene)
            }
            processNext()
            break

        case "label":
            // labels are just markers, not actions: skip to the next command
            processNext()
            break

        case "sprite":
            showSprite(command.id, Engine.gamePath + "/assets/" + command.image, command.position)
            processNext()
            break

        case "sprite_remove":
            removeSprite(command.id)
            processNext()
            break

        default:
            // unknown command: log and skip so the game does not stall
            console.warn("Not every command is yet implemented.")
            console.warn("Unknown command, skipping " + command.cmd)
            processNext()
            break
        }
    }

// --- End Game Logic ---
/////////////////////////


    SilicaFlickable {
        anchors.fill: parent
        contentHeight: parent.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Title screen")
                onClicked: remorsePopup.execute(qsTr("Returning to home"), function() { pageStack.pop(null) })
            }
            MenuItem {
                text: qsTr("Save")
                enabled: false //saving is not yet possible
                onClicked: console.log("[Game] Save pressed")
            }
            MenuItem {
                text: qsTr("Quick load")
                enabled: false  // stub: slot 0 empty
                onClicked: console.log("[Game] Quick load pressed")
            }
            MenuItem {
                text: qsTr("Quick save")
                enabled: false //saving is not yet possible
                onClicked: console.log("[Game] Quick save pressed")
            }
        }


/////////////////////////
// --- Layer Stack ---

        Item {
            id:             gameRoot
            anchors.fill:   parent

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (textAnimating) {
                        skipTypewriter()
                    } else {
                        processNext()
                    }
                }
            }

            Image {
                id:             background
                anchors.fill:   parent
                source:         currentBg
                fillMode:       Image.PreserveAspectCrop  //Crop, or black borders? Maybe in the game.json?
            }

            Repeater {
                model: spriteModel
                delegate: Image {
                    source:             model.spriteSource
                    sourceSize.height:  gameRoot.height * 0.9
                    x:                  spriteX(model.position, width)
                    y:                  spriteY(model.position, height)
                }
            }

            Rectangle {
                id:             textbox
                anchors.bottom: parent.bottom
                anchors.left:   parent.left
                anchors.right:  parent.right
                height:         parent.height * 0.25
                color:          Qt.rgba(0, 0, 0, 0.7)

                Column {
                    anchors.fill:       parent
                    anchors.margins:    Theme.paddingMedium

                    Label {
                        id:             speakerLabel
                        text:           speakerName
                        color:          Theme.highlightColor
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold:      true
                        visible:        speakerName !== ""
                    }

                    Label {
                        id:             dialogueLabel
                        text:           visibleText
                        color:          Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        wrapMode:       Text.WordWrap
                        width:          parent.width
                    }
                }
            }
        }

// --- End Layer Stack ---
/////////////////////////

    }

    Component.onCompleted: {
        processNext()
    }
}
