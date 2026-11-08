.pragma library

// Glow colour presets shared by the settings page and the design preview.
var presets = [
    { name: "Neon orange", colour: "#ff6b1a" },
    { name: "Amber", colour: "#ffa526" },
    { name: "Argon blue", colour: "#4fa8ff" },
    { name: "Green", colour: "#3cff7a" },
    { name: "Rose", colour: "#ff4f7b" }
];

function indexOf(colour) {
    for (var i = 0; i < presets.length; ++i) {
        if (presets[i].colour.toLowerCase() === String(colour).toLowerCase())
            return i;
    }
    return 0;
}
