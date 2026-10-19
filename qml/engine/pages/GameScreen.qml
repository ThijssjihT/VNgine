import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components" as Components
import "../GameEngine.js" as Engine
import "../components/Constants.js" as Constants

Page {
    id:                     gameScreen
    allowedOrientations:    Orientation.Landscape
    cutoutMode:             CutoutMode.FullScreen

    property int    thumbWidth:         0
    property int    thumbHeight:        0       //For save game thumbnail

    property string currentBg:          ""      //background image, could have been better named
    property string speakerName:        ""
    property bool   awaitingChoice:     false

    property var    activeStyleIds:     ({ textbox: null, choice: null, hud: null })
    property var    textboxStyle:       ({})
    property var    choiceStyle:        ({})
    property var    hudStyle:           ({})

    RemorsePopup { id: remorsePopup }
    Components.Typewriter { id: typewriter }

/////////////////////////
// --- Branching logic

    ListModel { id: choiceModel}

    function applyJump(target) {
        if (target.label)       Engine.jumpToLabel(target.label)
        else if (target.scene)  Engine.loadScene(target.scene)
        else {
            // Does nothing if no key is present
            // This is deliberate, and not an unhandled branch
            // The game will just continue with the next line
            // This prevents having to write extra labels and jumps
            // Still we want to warn a game author for possible typos:
            console.warn("No jumping is set for this option.")
            console.warn("This may very well be intentional, in that case ignore this warning.")
            console.warn("But check for unintentional behaviour (for example typos)")
        }
    }

    function choiceTearDown() {
        awaitingChoice = false
        choiceModel.clear()
        Engine.activeChoice = null
    }

    function selectChoice(optionIndex) {
        var selectedOption = Engine.activeChoice.options[optionIndex]
        console.log("selected option " + optionIndex + ": " + JSON.stringify(selectedOption))
        // don't delete this console.log. It is important for debugging typos in option branching.
        choiceTearDown()
        Engine.applyEffects(selectedOption.effects)
        applyJump(selectedOption)
        processNext()
    }

// --- End branching logic
/////////////////////////

/////////////////////////
// --- Save game logic

    function stageSaveGame() {
        Components.SaveManager.stagePendingSave(
                    Engine.currentScene,
                    Engine.cmdIndex,
                    Engine.variables,
                    buildScreenBlob(),
                    Engine.variables[Engine.manifest.save_display_variable] || "empty")}

    function commitSave(slot) {
        if ((slot === null ) || (slot < 0 )) {
            return false
        }
        gameRoot.grabToImage(function(result) {
            if (result) {
                var filename    = "save_" + slot + ".jpg"
                var dir         = StandardPaths.data
                result.saveToFile(dir + "/" + filename)
                Components.SaveManager.commitSave(filename)
            }
        }, Qt.size(thumbWidth, thumbHeight))
    }

    // Quick save menu item:
    function doQuickSave() {
        stageSaveGame()
        Components.SaveManager.finalizePending(0, "Quicksave")
        commitSave(0)
    }

    // Save menu item:
    function doManualSave() {
        stageSaveGame()
        pageStack.push(Qt.resolvedUrl("SaveGamePage.qml"))
    }

    function computeThumbSize() {
        // For thumbscreen in saving and loading
        thumbWidth  = Math.round(Screen.width * Constants.thumbScreenFraction)
        thumbHeight = Math.round(thumbWidth * gameRoot.height / gameRoot.width)
    }

    function buildScreenBlob() {  //leftover name, also saves sounds and styles into the blob together with the graphics
        var sprites = spriteLayer.toList()
        return {
            background:     currentBg,
            sprites:        sprites,
            dialogue:       { speaker: speakerName, text: typewriter.fullText },
            activeStyleIds: activeStyleIds,
            sound:          Components.AudioController.toBlob()
        }
    }

    function buildScreenFromScreenBlob(screenBlob) {
        if (!screenBlob) return
        currentBg = screenBlob.background
        spriteLayer.restoreFrom(screenBlob.sprites)
        activeStyleIds  = screenBlob.activeStyleIds
        textboxStyle    = Engine.resolveStyle("textbox", activeStyleIds.text)
        choiceStyle     = Engine.resolveStyle("choice", activeStyleIds.choice)
        hudStyle        = Engine.resolveStyle("hud", activeStyleIds.hud)
        if (screenBlob.dialogue) {
            speakerName   = screenBlob.dialogue.speaker
            typewriter.setImmediate(screenBlob.dialogue.text)
        }
        Components.AudioController.restoreFrom(screenBlob.sound)
    }

    function beginNew() {
        resetSession()
        Engine.initVariables()
        Engine.loadScene(Engine.manifest.entry_scene)
        Engine.gameInProgress = true
        processNext()
    }

    function resumeLoaded() {
        resetSession()
        Engine.gameInProgress = true
        Components.SaveManager.finishLoading()
        buildScreenFromScreenBlob(Components.SaveManager.pendingScreen())
        Components.SaveManager.clearPendingLoad()
        if (!Engine.commands[Engine.cmdIndex]) {    // if we save on a script authoring error, and load that game
            Engine.cmdIndex--                       // we go back one line
            processNext()                           // and trigger the existing fail code
        } else if (Engine.commands[Engine.cmdIndex].cmd === "choice") {
            processNext()                           // if saved on a choice, we retrigger that code
        }
    }

    function resetSession() {
        spriteLayer.clear()
        typewriter.setImmediate("")
        currentBg           = ""
        speakerName         = ""
        awaitingChoice      = false
        Engine.activeChoice = null
        choiceModel.clear()
        textboxStyle        = Engine.resolveStyle("textbox", null)
        choiceStyle         = Engine.resolveStyle("choice", null)
        hudStyle            = Engine.resolveStyle("hud", null)
        Components.AudioController.stopAll(100)
    }

    onStatusChanged: {
        if (status !== PageStatus.Active) return
        quickLoadMenuItem.enabled = Components.SaveManager.slotHasSave(0)
        if (Components.SaveManager.pendingSlot() >= 0) {
            commitSave(Components.SaveManager.pendingSlot())
        }
    }

// --- End save game logic
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
              only 4 commands implemented so far. Nope, 10 now. I'm on fire!
              TODO: really? do I really need to be this explisit? Do the other commands!
              Check the design file for reference
              Oh, and change the default switch key while your at it.
            */
        case "set":
            Engine.applySet(command.var, command.op, Engine.resolveSetValue(command))
            processNext()
            break

        case "bg":
            currentBg = command.image
            processNext()  //immediately process next command
            break

        case "say":
            speakerName = Engine.interpolate(command.speaker || "")
            typewriter.start(Engine.resolveText(command))
            // stop here. Next command is processed after player input.
            break

        case "jump":
            applyJump(command)
            processNext()
            break

        case "jump_if":
            if (Engine.evaluateCondition(command.condition)) applyJump(command)
            processNext()
            break

        case "choice":
            Engine.activeChoice = command
            choiceModel.clear()
            command.options.forEach(function(option, index) {
                if (Engine.evaluateCondition(option.condition)) {
                    choiceModel.append({ text: Engine.interpolate(option.text_key ? "[" + option.text_key + "]" : option.text || ""), optionIndex: index})
                }
            })
            if (choiceModel.count === 0) {
                console.warn("Choice with no visible options in " + Engine.currentScene + " on command " + Engine.cmdIndex + ", skipping")
                Engine.activeChoice = null
                processNext()
                break
            }
            awaitingChoice = true
            break

        case "label":
            // labels are just markers, not actions: skip to the next command
            processNext()
            break

        case "sprite":
            spriteLayer.show(command.id, command.image, command.position)
            processNext()
            break

        case "sprite_remove":
            spriteLayer.remove(command.id)
            processNext()
            break

        case "style":
            var loadedStyle
            try {
                loadedStyle = Engine.resolveStyle(command.category, command.style)
            } catch (e) {
                console.warn("style command: could not load \"" + command.style + "\" for category \"" + command.category + "\", keeping current style")
                processNext()
                break
            }
            if (command.category === "textbox") {
                textboxStyle        = loadedStyle
                activeStyleIds.text = command.style
            }
            else if (command.category === "choice") {
                choiceStyle             = loadedStyle
                activeStyleIds.choice   = command.style
            }
            else if (command.category === "hud") {
                hudStyle            = loadedStyle
                activeStyleIds.hud  = command.style
            }
            else console.warn("style command: unknown category \"" + command.category + "\"")
            processNext()
            break

        case "audio_bg":
            Components.AudioController.handleAudioBgAction(command)
            processNext()
            break

        case "audio_fx":
            Components.AudioController.playSfx(command.file, command.volume)
            processNext()
            break

        case "audio_loop":
            Components.AudioController.handleAudioLoopAction(command)
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
                onClicked: pageStack.push(Qt.resolvedUrl("TitlePage.qml"), { gameScreen: gameScreen })
            }
            MenuItem {
                text: qsTr("Save")
                onClicked: {
                    stageSaveGame()
                    pageStack.push(Qt.resolvedUrl("SaveGamePage.qml"))
                }
            }
            MenuItem {
                id: quickLoadMenuItem
                text: qsTr("Quick load")
                enabled: false
                onClicked: {
                    Components.SaveManager.loadSavedGame(0)
                    resumeLoaded()
                }

            }
            MenuItem {
                text: qsTr("Quick save")
                onClicked: {
                    doQuickSave()
                    quickLoadMenuItem.enabled = true
                }
            }
        }

        Item {
            id:             gameRoot
            anchors.fill:   parent

            MouseArea {
                enabled: !awaitingChoice // When waiting for choice input, we should not continue to the next script line.
                anchors.fill: parent
                onClicked: {
                    if (typewriter.animating) {
                        typewriter.skip()
                    } else {
                        processNext()
                    }
                }
            }

            Image {
                id:             background
                anchors.fill:   parent
                source:         Engine.assetPath(currentBg)
                fillMode:       Image.PreserveAspectCrop  //Crop, or black borders? Maybe in the game.json?
            }

            Components.SpriteLayer {
                id:             spriteLayer
                anchors.fill:   parent
            }

            Components.TextboxLayer{
                style:      textboxStyle
                speaker:    speakerName
                text:       typewriter.visibleText
            }

            Components.ChoiceOverlay {
                style:              choiceStyle
                active:             awaitingChoice
                choiceModel:        choiceModel
                onOptionSelected:   selectChoice(index)
            }
        }
    }
    Component.onCompleted: {

    }
}
