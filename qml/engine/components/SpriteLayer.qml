import QtQuick 2.6
import "../GameEngine.js" as Engine

Item {
    id: spriteLayer

    property real clearance: 0

    function assetPath(rel) {
        return rel === "" ? "" : Engine.gamePath + "/assets/" + rel
    }

    ListModel { id: spriteModel }

    Repeater {
        model: spriteModel
        delegate: Image {
            source:             spriteLayer.assetPath(model.spriteSource)
            sourceSize.height:  spriteLayer.height * 0.9
            x:                  spriteLayer.spriteX(model.position, width)
            y:                  spriteLayer.spriteY(model.position, height)
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
            return parseFloat(pos.split(",")[0] / 100 * width - sprWidth / 2)
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
