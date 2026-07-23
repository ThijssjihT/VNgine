import QtQuick 2.6
import Sailfish.Silica 1.0
import "pages"
import "components" as Components
import "GameEngine.js" as Engine

ApplicationWindow {
    initialPage:            Component { GameScreen { } }            // Put the GameScreen as the root of the PageStack
    cover:                  Qt.resolvedUrl("cover/CoverPage.qml")   // GameScreen will not be our first page, but having
    allowedOrientations:    defaultAllowedOrientations              // our first page at the root of the pageStack simplifies
                                                                    // our PageStack design enourmously
    Component.onCompleted: {
        Engine.loadManifest(Qt.resolvedUrl("game")) // Load the game manifest into the Engine
        Components.Settings.initialize()            // We initialize settings
        Components.SaveManager.initialize()

        var game = pageStack.currentPage    // GameScreen is already pushed to root
        var preloaded = Components.SaveManager.loadMostRecentSave()

        if (preloaded) {
            game.resumeLoaded()
        } else {
            Engine.initVariables()
            Engine.loadScene(Engine.manifest.entry_scene)
            game.beginNew()
        }

        pageStack.push(Qt.resolvedUrl("pages/TitlePage.qml"), {gameScreen: game}, PageStackAction.Immediate)
    }
}
