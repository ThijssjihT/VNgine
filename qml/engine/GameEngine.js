.pragma library

var manifest        = null;         //variable to store game manifest that contains loading instructions
var variables       = {};           //object that holds all variables declared in the manifest, for the engine to reference
var commands        = [];           //list that holds the commands loaded from a scene in sequence,
                                    //the engine will step through this array to play the loaded scene
var cmdIndex        = 0;            //the index, or step, we are on in the list of commands
var labelIndex      = {};           //oject that holds all index numbers of the labels.
                                    //On a jump command, this is referenced to look up the label
                                    //and set the cmdIndex to the corresponding number.
var gamePath            = "";
var engineDefaultsPath  = "";
var currentScene        = "";       //store what scene we are curently on, needed for saving / loading
var gameInProgress      = false;    //we need to know if a game is in progress to toggle continue button functionality

var settingsProvider= null;         //Stores a reference to a function normally out of scope, to make it available
var activeChoice    = null;         //Stores all options for the choice the player is facing

function setSettingsProvider(fn) {
    settingsProvider = fn
}

function setEngineDefaultsPath(path) {
    engineDefaultsPath = path
}

function getSetting(key) {
    if (settingsProvider) return settingsProvider(key)
    console.warn ("Setting " + key + " requested before settings initialization")
    return undefined
}

function loadJson(url) {
    var xhr = new XMLHttpRequest(); //not commenting on this, look up this and its methods in the mozilla mdn
    xhr.open("GET", url, false);
    xhr.send();
    if (xhr.status !== 200 && xhr.status !== 0)
        throw new Error("Failed to load: " + url);
    return JSON.parse(xhr.responseText);
}

function loadManifest(path) {
    gamePath = path;
    manifest = loadJson(path + "/game.json");
    return manifest;
}

function initVariables() {
    variables = {};
    var defs = manifest.variables || {};        //a game with no variables will return an empty object, or else this would error.
    for (var key in defs)
        variables[key] = defs[key]["default"]
    var saveLabelVariable = manifest.save_display_variable
    if(saveLabelVariable && !(saveLabelVariable in variables))
        variables[saveLabelVariable] = "empty"
}

function loadScene(sceneId) {
    currentScene = sceneId
    var data = loadJson(gamePath + "/script/" + sceneId + ".json");
    commands = data.commands;
    cmdIndex = 0;       //start at the beginning of the new scene
    labelIndex = {};    //empties the labelIndex to flush labels from previous scene

    commands.forEach(function(command, index) {
        if (command.cmd === "label") {
            labelIndex[command.label] = index
        }
    })
}

function resolveStyle(category, styleId) {                  //resolves loading a preconfigured style in a category (textbox, choice, hud, ...)
    var engineDefault = loadJson(engineDefaultsPath + "/default_" + category + ".json")
    if (!styleId) return mergeStyle({}, engineDefault.style)
    var styleOverlay = loadStyleChain(category, styleId, [])
    if (styleOverlay === null) {
        console.warn("Style " + styleId + " could not be loaded")
        console.warn("Falling back on engine default")
        return mergeStyle({}, engineDefault.style)
    }
    return mergeStyle(engineDefault.style, styleOverlay)
}

function mergeStyle(base, override) {                       //merges styles together, so a preconfigured style can be based on another style
    var result = {}
    var key = null
    for (key in base) {
        result[key] = base[key]
    }
    for (key in override) {
        if (isPlainObject(result[key]) && isPlainObject(override[key])) {
            result[key] = mergeStyle(result[key], override[key])
        }
        else {
            result[key] = override[key]
        }
    }
    return result
}

function isPlainObject(value) {                             //guard against recognizing null and arrays as objects
    if (value !== null)
        if (typeof value === "object")
            if (Array.isArray(value) === false)
                return true
    return false
}

function loadStyleChain(category, styleId, visited) {
    if ((styleId.indexOf(".") !== -1 ) || (styleId.indexOf("/") !== -1 ) || (styleId.indexOf("\\") !== -1 )) { // reject styles from other directories, quick and dirty protection against invalid inheritance
        console.warn(styleId + " is not a valid filename.")
        return null
    }
    if (visited.indexOf(styleId) !== -1) {
        console.warn("circular style dependancy. " + visited.join(" -> ") + " -> " + styleId)
        console.warn("returning null")
        return null
    } else {
        visited.push(styleId)
    }

    var parsedStyleFile = {}
    try {
        parsedStyleFile = loadJson(gamePath + "/assets/ui/" + category + "/" + styleId + ".json")
    }
    catch(e) {
        console.warn("Could not load " + gamePath + "/assets/ui/" + category + "/" + styleId + ".json")
        console.warn(e)
        return null
    }

    if (!isPlainObject(parsedStyleFile.style)) {
        console.warn(styleId + " has no valid style block ...")
        return null
    }

    if (parsedStyleFile.base) {
        var parentStyle = loadStyleChain(category, parsedStyleFile.base, visited)   // load parent style first
        if (parentStyle === null) return null                                       // broken dependancy fails the whole cycle
        return mergeStyle(parentStyle, parsedStyleFile.style)                       // replace parent properties with new properties
    }
    return mergeStyle({}, parsedStyleFile.style)
}

function evaluateCondition(cond) {
    if (!cond) return true
    var actualValue
    if (cond.var !== undefined) {
        actualValue = variables[cond.var]
    }
    else if (cond.setting !== undefined) {
        actualValue = getSetting(cond.setting)
    }
    else if (cond.flag !== undefined) {
        actualValue = variables[cond.flag]
        if (actualValue === undefined) actualValue = getSetting(cond.flag)
    }
    else {
        console.warn("undefined condition: " + JSON.stringify(cond))
        console.warn("treating as false")
        return false
    }
    if (actualValue === undefined) {
        console.warn("value to condition to is undefined. Please check the condition: " + JSON.stringify(cond))
        return false
    }

    if (cond.op === undefined) {
        //if (actualValue) return true
        return !!actualValue
    }
    if (cond.value === undefined) {
        console.warn("no value to compare is set. Please check the condition: " + JSON.stringify(cond))
        return false
    }

    switch (cond.op) {
        case "==":
            return actualValue === cond.value
        case "!=":
            return actualValue !== cond.value
        case "<":
            return actualValue < cond.value
        case "<=":
            return actualValue <= cond.value
        case ">":
            return actualValue > cond.value
        case ">=":
            return actualValue >= cond.value
        default:
            console.warn("Unknown condition op: " + cond.op)
            return false
    }
}

function applyEffects(effects) {
    if (!effects) return;
    effects.forEach(function(effect) {
        applySet(effect.var, effect.op, resolveSetValue(effect))
    })
}

function nextCommand() {
    if (cmdIndex >= commands.length)    //there should ALWAYS be a next command, or the script is very wrong
        return null;                    //is this enough for error handling??? I don't know. Get back to this later.
    return commands[cmdIndex++]         //COOL EASTEREGG IDEA: maybe an optional declaration in the manifest for a custom error scene?
}

function jumpToLabel(name) {
    if (labelIndex.hasOwnProperty(name)){
        cmdIndex = labelIndex[name];    //jump to the index corresponding to the label
        return true;
    }
    console.warn("Unknown label: " + name);
    return false;
}

function resolveSetValue(cmd) {
    if (cmd.from) {
        if (cmd.from.var !== undefined) {
            if (!variables.hasOwnProperty(cmd.from.var))
                console.warn("set: unknown source variable: " + cmd.from.var)
            return variables[cmd.from.var]
        }
        if (cmd.from.setting !== undefined) {
            return getSetting(cmd.from.setting)
        }
        console.warn("set: unrecognised 'from' key" + JSON.stringify(cmd.from))
    }
    return cmd.value
}

function applySet(name, op, value) {
    if (value === undefined) {
        //debugging info: if something goes completely wrong here, it is probably
        //because of wrong value. Please call this function not with cmd.value, but
        // resolveSetValue(command) instead.
        console.warn("applySet: undefined value for '" + name + "', op '" + op + "' — ignoring");
        return;
    }
    if (op === "set")      variables[name] = value;
    else if (op === "add") variables[name] = (variables[name] || 0) + value;
    else if (op === "sub") variables[name] = (variables[name] || 0) - value;
    else if (op === "mul") variables[name] = (variables[name] || 0) * value;
    else console.warn("Unknown set op: " + op);
}

function interpolate(str) { //Every displayed string is routed through here, for string replacement
    if (!str) return str
    return str.replace(/%([A-Za-z_][A-Za-z0-9_]*)%/g, function(match, name) { //regex made by AI
        if (variables.hasOwnProperty(name))
            return variables[name];
        var settingValue = getSetting(name)
        if (settingValue !== undefined)
            return settingValue
        console.warn("Unknow variable in text: " + name);
        return match;
    });
}

function resolveText(cmd) {
    /*
      this is a stub, and just returns inline text right now.
      will be replaced in development phase 2 with text_key lookup
      and i18n in development phase 6
    */
    var raw;
    if (cmd.text_key) {
        console.log("TODO, text_key: " + cmd.text_key);
        raw = "[" + cmd.text_key + "]";
    } else {
        raw = cmd.text || "";
    }

    return interpolate(raw);
}
