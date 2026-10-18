pragma Singleton
import QtQuick 2.6
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import "../GameEngine.js" as Engine

Item {
    property bool   bgTrackAActive:     true    //needed for crossfading audio
    property var    musicQueue:         []
    property int    musicIndex:         0       //track in the queue
    property bool   musicLoop:          true
    readonly property int defaultFadeDuration: 800

    function assetPath(rel) {
        return rel === "" ? "" : Engine.gamePath + "/assets/" + rel
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

    function doSetMusic(tracks, loop, transistion, fadeTime, volume) {
        if (tracks === undefined || tracks.length === 0) {
            console.warn("setMusic: needs a non-empty \"tracks\" list")
            return
        }
        musicQueue  = tracks
        musicIndex  = 0
        musicLoop   = (loop !== false)

        var duration = (transistion === "cut") ? 0 : (fadeTime !== undefined ? fadeTime : defaultFadeDuration)
        var fadeOut  = bgTrackAActive ? fadeVolumeA : fadeVolumeB
        var fadeIn   = bgTrackAActive ? fadeVolumeB : fadeVolumeA
        var incoming = bgTrackAActive ? bgMusic_b : bgMusic_a

        fadeVolume(fadeOut, 0, duration, true)
        playQueueTrack(incoming, 0)
        fadeVolume(fadeIn, effectiveVolume("music", volume), duration, false)
        bgTrackAActive = !bgTrackAActive
    }

    function doSetMusicVolume(multiplier, fadeTime) {
        var fadeAnimationSelect = bgTrackAActive ? fadeVolumeA : fadeVolumeB
        fadeVolume(fadeAnimationSelect, effectiveVolume("music", multiplier), fadeTime, false)
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
}
