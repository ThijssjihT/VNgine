.pragma library

var manifest        = null;         //variable to store game manifest that contains loading instructions
var variables       = {};           //object that holds all variables declared in the manifest, for the engine to reference
var commands        = [];           //list that holds the commands loaded from a scene in sequence,
                                    //the engine will step through this array to play the loaded scene
var cmdIndex        = 0;            //the index, or step, we are on in the list of commands
var labelIndex      = {};           //oject that holds all index numbers of the labels.
                                    //On a jump command, this is referenced to look up the label
                                    //and set the cmdIndex to the corresponding number.
var gamePath        = "";
var currentScene    = "";           //store what scene we are curently on, needed for saving / loading
var gameInProgress  = false;        //we need to know if a game is in progress to toggle continue button functionality



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
}

function loadTextboxStyle(styleId) {
    var style = loadJson(gamePath + "/assets/ui/textbox/" + styleId + ".json");
    return {
        color:   style.color   || "#000000",
        opacity: style.opacity !== undefined ? style.opacity : 0.7   // "style.opacity || 0.7" would override an intentional zero
    };
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

function applySet(name, op, value) {
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
