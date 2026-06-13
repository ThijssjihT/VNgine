pragma Singleton

import QtQuick 2.6
import QtQuick.LocalStorage 2.0
import "Constants.js" as Constants

QtObject {
    id: saveManager

    property var    _db:            null     // database connection
    property var    _pending:       null     // staged save data awaiting save slot choice
    property bool   _justLoaded:    false    // to communicate if a save game has just been loaded
    property bool   ready:          false

    function pendingLabel() {
        return _pending ? _pending.presetLabel : ""
    }

    function pendingSlot() {
        return _pending ? _pending.slot : -1
    }

    function clearSaveData() {
        _pending = null
    }

    function justLoaded() {
        return _justLoaded
    }

    function loading() {
        _justLoaded = !_justLoaded
    }

    function stagePendingSave(sceneId, cmdIndex, variables, screen, presetLabel) {
        // This is called by GameScreen, to save game state into a variable
        // while GameScreen is still visible, before a pageStack.push() is called
        _pending = {
            sceneId:        sceneId,        //What scene we are in
            cmdIndex:       cmdIndex,       //What row we are on at this scene
            variables:      variables,      //JS object containing all variables and their values
            screen:         screen,         //JS object containing instructions for building up every thing on screen
            presetLabel:    presetLabel,    //User overwritable save game label
            slot:           -1
        }
    }

    function finalizePending(slot, label) {
        // This is called by Save.qml to add the last information to _pending
        _pending.slot           = slot
        _pending.presetLabel    = label
    }

    function commitSave(screenshotPath) {
        //saves the gamestate
        if (!_pending) return false
        if (_pending.slot < 0) return false
        if (!_pending.presetLabel || (_pending.presetLabel === "")) _pending.presetLabel = "untitled"

        _db.transaction(function(tx) {
            tx.executeSql(
                        "INSERT OR REPLACE INTO saves " +
                        "(slot, scene_id, cmd_index, variables, screen, label, screenshot, saved_at) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                        [_pending.slot, _pending.sceneId, _pending.cmdIndex, JSON.stringify(_pending.variables), JSON.stringify(_pending.screen), _pending.presetLabel, screenshotPath, Math.floor(Date.now() / 1000) ])
        })
        clearSaveData()
        return true
    }

    function loadSavedGame(slot) {
        if (!_db) return null

        var result = null

        _db.transaction(function(tx) {
            var rawdata = tx.executeSql(
                        "SELECT scene_id, cmd_index, variables, screen, label, screenshot, saved_at " +
                        "FROM saves WHERE slot = ?",
                        [slot])
            if (rawdata.rows.length === 0) return

            var row = rawdata.rows.item(0)

            result = {
                slot:           slot,
                sceneId:        row.scene_id,
                cmdIndex:       row.cmd_index,
                variables:      JSON.parse(row.variables),
                screen:         JSON.parse(row.screen),
                label:          row.label,
                screenshot:     row.screenshot,
                savedAt:        row.saved_at
            }
        })

        if (result) _justLoaded = true
        return result
    }

    function slotHasSave(slot) {
        if (!_db) return false

        var exists = false

        _db.transaction(function(tx) {
            var rs = tx.executeSql(
                "SELECT 1 FROM saves WHERE slot = ?",
                [slot])
            exists = rs.rows.length > 0
        })

        return exists
    }

    function loadMostRecentSave() {
        if (!_db) return null

        var result = null

        _db.transaction(function(tx) {
            var rawdata = tx.executeSql(
                "SELECT scene_id, cmd_index, variables, screen, label, screenshot, saved_at, slot " +
                "FROM saves ORDER BY saved_at DESC LIMIT 1")

            if (rawdata.rows.length === 0) return

            var row = rawdata.rows.item(0)

            result = {
                slot:       row.slot,
                sceneId:    row.scene_id,
                cmdIndex:   row.cmd_index,
                variables:  JSON.parse(row.variables),
                screen:     JSON.parse(row.screen),
                label:      row.label,
                screenshot: row.screenshot,
                savedAt:    row.saved_at
            }
        })

        return result
    }

    function initialize() {
        if (ready) return
        _db = LocalStorage.openDatabaseSync(
            Constants.dbName, Constants.dbVersion,
            Constants.dbDescription, Constants.dbSize)
        _db.transaction(function(tx) {
            tx.executeSql(
                "CREATE TABLE IF NOT EXISTS saves (" +
                "  slot       INTEGER PRIMARY KEY, " +
                "  scene_id   TEXT    NOT NULL, " +
                "  cmd_index  INTEGER NOT NULL, " +
                "  variables  TEXT    NOT NULL, " +
                "  screen     TEXT, " +
                "  label      TEXT, " +
                "  screenshot TEXT, " +
                "  saved_at   INTEGER NOT NULL)")
        })
        ready = true
    }
}
