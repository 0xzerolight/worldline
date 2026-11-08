.pragma library

// Worldline values are X.XXXXXX. Internally they are integers in millionths.
var EGG = "1.048596";
var EGG_RATE = 0.05;    // chance to land on the easter egg
var JUMP_RATE = 0.15;   // chance to jump to the other attractor field

function format(n) {
    var f = Math.floor(n / 1000000);
    var s = String(n % 1000000);
    while (s.length < 6)
        s = "0" + s;
    return f + "." + s;
}

function parse(v) {
    return Math.round(parseFloat(v) * 1000000);
}

function isValid(v) {
    return /^[0-9]\.[0-9]{6}$/.test(v);
}

// Local time as a meter value, HH.MM.SS (24 h; the dots get their own tubes).
function clock(date) {
    function two(n) {
        return (n < 10 ? "0" : "") + n;
    }
    return two(date.getHours()) + "." + two(date.getMinutes()) + "." + two(date.getSeconds());
}

// Seedable PRNG (mulberry32): floats in [0, 1), the same sequence for the same seed.
function seeded(seed) {
    var s = seed >>> 0;
    return function () {
        s = (s + 0x6D2B79F5) >>> 0;
        var t = s;
        t = Math.imul(t ^ (t >>> 15), t | 1);
        t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
        return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
}

// Drift: mostly small moves inside the current attractor field (the leading
// digit), sometimes a jump to the other field, rarely the easter egg.
// `rng` returns floats in [0, 1); it defaults to Math.random.
function next(current, rng) {
    rng = rng || Math.random;
    if (current !== EGG && rng() < EGG_RATE)
        return EGG;
    var n = parse(current);
    var field = Math.floor(n / 1000000) >= 1 ? 1 : 0;
    if (rng() < JUMP_RATE)
        return format((1 - field) * 1000000 + Math.floor(rng() * 1000000));
    var mag = rng() < 0.75 ? 1000 : 100000;
    var delta = Math.floor(rng() * mag) + 1;
    if (rng() < 0.5)
        delta = -delta;
    var r = ((n % 1000000) + delta + 1000000) % 1000000;
    return format(field * 1000000 + r);
}
