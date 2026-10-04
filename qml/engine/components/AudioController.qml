pragma Singleton
import QtQuick 2.6
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import "../GameEngine.js" as Engine

Item {
    property bool   bgTrackAActive:     true    //needed for crossfading audio

    function assetPath(rel) {
        return rel === "" ? "" : Engine.gamePath + "/assets/" + rel
    }

    //Need 2 background music items for crossfading and other animations
    Audio {
        id:         bgMusic_a
        loops:      Audio.Infinite
        volume:     0
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
        loops:      Audio.Infinite
        volume:     0
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
        animation.stopOnFinish  = !!stopOnFinish
        animation.duration      = duration || 0
        animation.to            = endVolume
        animation.start()
    }

    function doCrossFade(track, fadeTime, volume) {
        var fadeOut     = bgTrackAActive ? fadeVolumeA : fadeVolumeB
        var fadeIn      = bgTrackAActive ? fadeVolumeB : fadeVolumeA
        var fadeInTarget= bgTrackAActive ? bgMusic_b : bgMusic_a

        fadeVolume(fadeOut, 0, fadeTime, true) //fade out old track, then stop

        fadeInTarget.source = assetPath("audio/" + track)
        fadeInTarget.play()
        fadeVolume(fadeIn, effectiveVolume("music", volume), fadeTime, false) //fade in new track
        bgTrackAActive = !bgTrackAActive
    }

    function doSetMusicVolume(multiplier, fadeTime) {
        var fadeAnimationSelect = bgTrackAActive ? fadeVolumeA : fadeVolumeB
        fadeVolume(fadeAnimationSelect, effectiveVolume("music", multiplier), fadeTime, false)
    }

    function doStop(fadeTime) {
        var fadeOut = bgTrackAActive ? fadeVolumeA : fadeVolumeB
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
            case "crossfade":
                doCrossFade(action.track, action.fadeTime)
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
