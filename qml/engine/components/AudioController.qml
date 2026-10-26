pragma Singleton
import QtQuick 2.6
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import "../GameEngine.js" as Engine
import "."

Item {
    property bool   bgTrackAActive: true    //needed for crossfading audio
    property var    musicQueue:     []
    property int    musicIndex:     0       //track in the queue
    property bool   musicLoop:      true
    property real   musicVolume:    1.0
    readonly property int       defaultFadeDuration:    800
    readonly property string    musicChannel:           "music"
    readonly property string    gamefxChannel:          "game_fx"
    readonly property string    loopingfxChannel:       "looping_fx"
    readonly property string    textfxChannel:          "text_fx"
    readonly property string    voiceChannel:           "voice"

    Connections {
        target:  Settings
        onSettingChanged: {
            if (key === "audio_" + musicChannel + "_value") applyMusicVolume()
            if (key === "audio_" + loopingfxChannel + "_value") applyLoopingFXVolume()
        }
    }

    //Four slots for effects. Add more if needed
    SfxSlot { id: sfx0 }
    SfxSlot { id: sfx1 }
    SfxSlot { id: sfx2 }
    SfxSlot { id: sfx3 }
    property var sfxPool: [sfx0, sfx1, sfx2, sfx3]

    //Four slots for looping effects. Add more if needed
    LoopFXSlot { id: lfx0 }
    LoopFXSlot { id: lfx1 }
    LoopFXSlot { id: lfx2 }
    LoopFXSlot { id: lfx3 }
    property var loopPool: [lfx0, lfx1, lfx2, lfx3] //palindrome

    function playSfx(file, volume) {
        if (file === undefined) {
            console.warn("audio_fx: missing \"file\"")
            return
        }
        for (var i = 0; i < sfxPool.length; i++) {
            var slot = sfxPool[i]
            if (!slot.busy) {
                slot.busy   = true
                slot.volume = effectiveVolume(gamefxChannel, volume)
                slot.source = Engine.assetPath("audio/" + file)
                slot.play()
                return
            }
        }
        console.warn("audio_sfx: all " + sfxPool.length + " slots busy, skipping " + file)
        console.warn("Please check for using sfx for music or other long files")
        console.warn("or consider using audio_loop")
        console.warn("You may add extra slots by modifying AudioController.qml")
    }

    function handleAudioLoopAction(action) {
        switch (action.action) {
            case "start":
                playLoopFx(action.id, action.file, action.volume, action.fadeTime)
                break
            case "stop":
                stopLoopFx(action.id, action.fadeTime)
                break
            case "stopAll":
                stopAllLoopFx(action.fadeTime)
                break
        }
    }

    function findLoopSlot(id) {
        for (var i = 0; i < loopPool.length; i++) {
            if (loopPool[i].busy && loopPool[i].loopId === id) return loopPool[i]
        }
        return null
    }

    function findFreeLoopSlot() {
        for (var i = 0; i < loopPool.length; i++) {
            if (!loopPool[i].busy) return loopPool[i]
        }
        return null
    }

    function playLoopFx(id, file, volume, fadeTime) {
        if (file === undefined) {
            console.warn("audio_loop: missing \"file\"")
            return
        }
        var multiPlier  = (volume !== undefined) ? volume : 1.0
        var slot        = findLoopSlot(id)

        if (slot !== null && slot.file === file) { //Loop is already running, adjust the volume
            slot.baseVolume = multiPlier
            fadeVolume(slot.fader, effectiveVolume(loopingfxChannel, multiPlier), fadeTime, false)
            console.warn("Loop is already running. Adjusting volume if necessary.")
            return
        }

        if (slot === null) slot = findFreeLoopSlot()
        if (slot === null) {
            console.warn("audio_loop: all " + loopPool.length + " slots busy, skipping " + file)
            console.warn("You may add extra slots by modifying AudioController.qml")
            return
        }

        slot.busy       = true
        slot.loopId     = id
        slot.file       = file
        slot.baseVolume = multiPlier
        slot.source     = Engine.assetPath("audio/" + file)
        slot.volume     = 0
        slot.play()
        fadeVolume(slot.fader, effectiveVolume(loopingfxChannel, multiPlier), fadeTime, false)
    }

    function stopLoopFx(id, fadeTime) {
        var slot = findLoopSlot(id)
        if (slot === null ) {
            console.warn("stopping loop not possible: no active loop with id " + id)
            return
        }
        fadeVolume(slot.fader, 0, fadeTime, true)
        return
    }

    function stopAllLoopFx(fadeTime) {
        loopPool.forEach(function(slot) {
            if (slot.busy) fadeVolume(slot.fader, 0, fadeTime, true)
        })
    }

    function applyLoopingFXVolume(fadeTime) {
        loopPool.forEach(function(slot) {
            if (slot.busy) {
                fadeVolume(slot.fader, effectiveVolume(loopingfxChannel, slot.baseVolume), 100, false)
            }
        })
    }

    function stopAll(fadeTime) {
        stopAllLoopFx(fadeTime)
        doStop(fadeTime)
     }

    //Need 2 background music items for crossfading and other animations
    Audio {
        id:         bgMusic_a
        volume:     0
        onStatusChanged: if (status === Audio.EndOfMedia) advanceQueue(bgMusic_a)
        onError: {
            if (error === Audio.ResourceError || error === Audio.FormatError) {
                console.warn("bgMusic_a failed to load: " + errorString)
            } else {
                console.warn("bgMusic_a failing to play: " + errorString)
            }
            stop()
        }
    }

    Audio {
        id:         bgMusic_b
        volume:     0
        onStatusChanged: if (status === Audio.EndOfMedia) advanceQueue(bgMusic_b)
        onError: {
            if (error === Audio.ResourceError || error === Audio.FormatError) {
                console.warn("bgMusic_b failed to load: " + errorString)
            } else {
                console.warn("bgMusic_b failing to play: " + errorString)
            }
            stop()
        }
    }

    //Having separate animation instead of general fadeIn, fadeOut
    //makes that we don't need live binding and thus to guard against overlap
    PropertyAnimation {
        id:         fadeVolumeA
        target:     bgMusic_a
        property:   "volume"
        property bool stopOnFinish: false
        onStopped: {
            if (stopOnFinish) bgMusic_a.stop()
        }
    }

    PropertyAnimation {
        id:         fadeVolumeB
        target:     bgMusic_b
        property:   "volume"
        property bool stopOnFinish: false
        onStopped: {
            if (stopOnFinish) bgMusic_b.stop()
        }
    }

    function applyMusicVolume() {
        if (musicQueue.length === 0) return
        var animation = bgTrackAActive ? fadeVolumeA : fadeVolumeB
        fadeVolume(animation, effectiveVolume(musicChannel, musicVolume), 100, false)
    }

    function effectiveVolume(channelKey, multiplier) {
        var settingsVolume = Settings.get("audio_" + channelKey + "_value") / 100
        return settingsVolume * (multiplier === undefined ? 1.0 : multiplier)
    }

    function fadeVolume(animation, endVolume, duration, stopOnFinish) {
        //First stop the running animation to get more predictable behaviour
        //when we try to do 2 animations simultaniously
        animation.stopOnFinish  = false
        animation.stop()

        //Set up the animation
        animation.stopOnFinish  = !!stopOnFinish
        animation.duration      = duration || 0
        animation.to            = endVolume
        animation.start()
    }

    function playQueueTrack(element, index) {
        element.loops   = (musicQueue.length === 1 && musicLoop) ? Audio.Infinite : 1
        element.source  = Engine.assetPath("audio/" + musicQueue[index])
        element.play()
    }

    function advanceQueue(element) {
        var active = bgTrackAActive ? bgMusic_a : bgMusic_b
        if (element !== active || musicQueue.length === 0) return

        var next = musicIndex + 1
        if (next >= musicQueue.length) {
            if (!musicLoop) return
            next = 0
        }
        musicIndex = next
        playQueueTrack(element, next)
    }

    function doSetMusic(tracks, loop, transition, fadeTime, volume, startIndex) {
        if (tracks === undefined || tracks.length === 0) {
            console.warn("setMusic: needs a non-empty \"tracks\" list")
            return
        }
        musicQueue  = tracks
        musicIndex  = (startIndex !== undefined && startIndex < tracks.length) ? startIndex : 0
        musicLoop   = (loop !== false)
        musicVolume = (volume !== undefined) ? volume : 1.0

        var duration = (transition === "cut") ? 0 : (fadeTime !== undefined ? fadeTime : defaultFadeDuration)
        var fadeOut  = bgTrackAActive ? fadeVolumeA : fadeVolumeB
        var fadeIn   = bgTrackAActive ? fadeVolumeB : fadeVolumeA
        var incoming = bgTrackAActive ? bgMusic_b : bgMusic_a

        fadeVolume(fadeOut, 0, duration, true)
        playQueueTrack(incoming, musicIndex)
        fadeVolume(fadeIn, effectiveVolume(musicChannel, volume), duration, false)
        bgTrackAActive = !bgTrackAActive
    }

    function doSetMusicVolume(multiplier, fadeTime) {
        var fadeAnimationSelect = bgTrackAActive ? fadeVolumeA : fadeVolumeB
        musicVolume = multiplier
        fadeVolume(fadeAnimationSelect, effectiveVolume(musicChannel, multiplier), fadeTime, false)
    }

    function doStop(fadeTime) {
        var fadeOut = bgTrackAActive ? fadeVolumeA : fadeVolumeB
        musicQueue = []
        fadeVolume(fadeOut, 0, fadeTime, true)
    }

    function doPause() {
        var active = bgTrackAActive ? bgMusic_a : bgMusic_b
        active.pause()
    }

    function doResume() {
        var active = bgTrackAActive ? bgMusic_a : bgMusic_b
        active.play()
    }

    function handleAudioBgAction(action) {
        switch (action.action) {
            case "setMusic":
                doSetMusic(action.tracks, action.loop, action.transition, action.fadeTime, action.volume)
                break
            case "setVolume":
                doSetMusicVolume(action.volume, action.fadeTime)
                break
            case "stop":
                doStop(action.fadeTime)
                break
            case "pause":
                doPause()
                break
            case "resume":
                doResume()
                break
            default:
                console.warn("audio_bg action not implemented: " + action.action)
        }
    }

    function toBlob() {
        var loops = []
        for (var i = 0; i < loopPool.length; i++) {
            var s = loopPool[i]
            if (s.busy) loops.push({ id: s.loopId, file: s.file, volume: s.baseVolume})
        }
        var music = (musicQueue.length === 0) ? null : { tracks: musicQueue, index: musicIndex, loop: musicLoop, volume: musicVolume }
        return {
            music: music,
            loops: loops
        }
    }

    function restoreFrom(blob) {
        if (!blob) return
        if (blob.music) {
            var m = blob.music
            doSetMusic(m.tracks, m.loop, "cut", 0, m.volume, m.index)
        }
        (blob.loops || []).foreach(function (l) {
            playLoopFx(l.id, l.file, l.volume)
        } )
    }
}
