import QtQuick 2.6
import QtQml 2.2
import "../GameEngine.js" as Engine

Item {
    id: spriteLayer

    property real clearance: 0

    ListModel { id: spriteModel }

    Repeater {
        model: spriteModel
        delegate: Item {
            id: sprite

            property var spriteState: Engine.beginSpritePipeline(model.spriteSource)

            height:     spriteLayer.height * 0.9
            width:      assetRepeater.count > 0 ? assetRepeater.itemAt(0).width : 0
            x:          spriteLayer.spriteX(model.position, width)
            y:          spriteLayer.spriteY(model.position, height)

            Repeater {
                id:     assetRepeater
                model:  sprite.spriteState !== null ? sprite.spriteState.assets : []
                delegate: Image {
                    property string assetId: modelData.id
                    source:             Engine.assetPath("sprites/" + modelData.file)
                    sourceSize.height:  sprite.height
                    z:                  modelData.z
                    visible:            false
                }
            }

            Instantiator {  //create a timer for each animation
                model: sprite.spriteState !== null ? sprite.spriteState.animations : []

                delegate: Timer {
                    property var animation: modelData
                    property int stepIndex: 0
                    property var shownImage:null

                    running:            assetRepeater.count === sprite.spriteState.assets.length  //Make sure all imgages exist before starting timers, so it can't miss.
                    repeat:             true
                    triggeredOnStart:   true  //immediately trigger to show first image and set timer length

                    onTriggered: {
                        var step = animation.steps[stepIndex]

                        if (shownImage !== null) shownImage.visible = false
                        shownImage = sprite.findImage(step.id)
                        shownImage.visible = true

                        if (animation.type === "once" && stepIndex === animation.steps.length - 1) {
                            stop()
                            return
                        }

                        var offset = Math.round((Math.random() * 2 - 1) * step.randomize)
                        interval = Math.max(1, step.duration + offset)
                        stepIndex = (stepIndex + 1) % animation.steps.length
                    }
                }
            }

            //used by timers to find the Image for an animation step
            function findImage(assetId) {
                for (var i = 0; i < assetRepeater.count; i++) {
                    if (assetRepeater.itemAt(i).assetId === assetId) return assetRepeater.itemAt(i)
                }
                return null
            }
        }
    }

    function show(sId, src, pos) {
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

    function remove(sId) {
        for (var i = 0; i < spriteModel.count; i++)
            if (spriteModel.get(i).spriteId === sId) { spriteModel.remove(i); return }
    }

    function clear() { spriteModel.clear() }

    function spriteX(pos, sprWidth) {
        if (pos === "left")     return 0
        if (pos === "right")    return width - sprWidth
        if (pos.indexOf("%") !== -1)                    //If exact x and y coordinates are given
            return parseFloat(pos.split(",")[0]) / 100 * width - sprWidth / 2
        return (width - sprWidth) / 2          //Default center position
    }

    function spriteY(pos, sprHight) {
        if (pos.indexOf("%") !== -1)
            return parseFloat(pos.split(",")[1]) / 100 * height - sprHight
        return height - sprHight - clearance   // presets: bottom
    }

    function toList() {
        var list = []
        for (var i=0; i < spriteModel.count; i++) {
            var s = spriteModel.get(i)
            list.push({
                spriteId:       s.spriteId,
                spriteSource:   s.spriteSource,
                position:       s.position})
        }
        return list
    }

    function restoreFrom(list) {
        for (var i = 0; i < list.length; i++) {
            var s = list[i]
            show(s.spriteId, s.spriteSource, s.position)
        }
    }
}
