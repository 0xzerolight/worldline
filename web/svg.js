// Meter markup as plain strings (no DOM), shared by the page and the README image.
// Geometry, colours and opacities follow RectTube.qml for a tube 100 units wide
// and 200 tall; the meter is 8 tubes 3.5 units apart, as in Meter.qml.
import { Digits } from "./widget.js";

export const TUBE_W = 100;
export const TUBE_H = 200;
export const GAP = TUBE_W * 0.035;
export const METER_W = 8 * TUBE_W + 7 * GAP;
export const DEFAULTS = { colour: "#ff6b1a", glow: 0.7, showBack: true, showMesh: true };

const STRETCH = 1.15;
const CAP_H = TUBE_W * 0.075;
const BASE_H = TUBE_W * 0.12;
const GLASS_X = TUBE_W * 0.03;
const GLASS_W = TUBE_W - 2 * GLASS_X;
const GLASS_TOP = CAP_H * 0.6;
const U = TUBE_W * 0.8 / 100;
const DIGIT_W = 100 * U;
const DIGIT_H = 160 * U * STRETCH;
const DIGIT_X = (TUBE_W - DIGIT_W) / 2;
const DIGIT_Y = CAP_H + TUBE_W * 0.1;
const MESH_TOP = DIGIT_Y - 8 * U;
const MESH_BOTTOM = DIGIT_Y + DIGIT_H + 10 * U;
const GLASS_BOTTOM = DIGIT_Y + DIGIT_H + TUBE_W * 0.293;
const GLASS_H = GLASS_BOTTOM - GLASS_TOP;
const WIRE = "#5e4e45";

const n = v => +v.toFixed(2);

function rgb(hex) {
    const v = parseInt(hex.slice(1), 16);
    return [v >> 16 & 255, v >> 8 & 255, v & 255];
}

// Qt.tint: `over` at alpha `a` on top of `base`.
function tint(base, over, a) {
    const b = rgb(base), o = rgb(over);
    return "#" + b.map((v, i) => Math.round(v * (1 - a) + o[i] * a).toString(16).padStart(2, "0")).join("");
}

// The hot core of a lit wire.
export function coreColour(colour) {
    return tint(colour, "#fff7e0", 0.62);
}

// Cathode `d` as path data in tube units, shrunk by `k` around the digit box centre.
export function wirePath(d, k = 1) {
    const sx = U * k, sy = U * k * STRETCH;
    const ox = DIGIT_X + DIGIT_W * (1 - k) / 2, oy = DIGIT_Y + DIGIT_H * (1 - k) / 2;
    return Digits.paths[d].replace(/(-?[\d.]+),(-?[\d.]+)/g, (_, x, y) => `${n(ox + x * sx)},${n(oy + y * sy)}`);
}

// Stack position, depth scale and opacities of each unlit cathode, front to back.
export const stack = Digits.stack.map((d, i) => ({ d, i, k: 1 - i * 0.008 }));

function rect(x, y, w, h, attrs) {
    return `<rect x="${n(x)}" y="${n(y)}" width="${n(w)}" height="${n(h)}" ${attrs}/>`;
}

function hGradient(id, stops) {
    return `<linearGradient id="${id}">${stops.map(([o, c, a]) =>
        `<stop offset="${o}" stop-color="${c}"${a === undefined ? "" : ` stop-opacity="${n(a)}"`}/>`).join("")}</linearGradient>`;
}

function vGradient(id, stops) {
    return hGradient(id, stops).replace("<linearGradient ", `<linearGradient x2="0" y2="1" `);
}

export function meshPath() {
    const w = GLASS_W, h = MESH_BOTTOM - MESH_TOP, inset = w * 0.06, pitch = Math.max(3, w * 0.05);
    let d = "";
    for (let x = inset; x <= w - inset + 0.1; x += pitch)
        d += `M${n(GLASS_X + x)},${n(MESH_TOP)}v${n(h)}`;
    for (let y = 0; y <= h + 0.1; y += pitch)
        d += `M${n(GLASS_X + inset)},${n(MESH_TOP + y)}h${n(w - 2 * inset)}`;
    return { d, frame: [GLASS_X + inset, MESH_TOP, w - 2 * inset, h] };
}

// Shared layers. `p` prefixes every id so several meters can live in one document.
function layers(p, o) {
    const core = coreColour(o.colour);
    const mesh = meshPath();
    const capX = GLASS_X - TUBE_W * 0.01, capW = GLASS_W + TUBE_W * 0.02, r = CAP_H / 2;
    const baseX = TUBE_W * 0.01, baseW = TUBE_W * 0.98, baseY = GLASS_BOTTOM - BASE_H / 2;
    const glass = [GLASS_X, GLASS_TOP, GLASS_W, GLASS_H];
    let s = "";
    s += hGradient(`${p}-glass`, [[0, "#050404"], [0.5, "#15110f"], [1, "#050404"]]);
    s += hGradient(`${p}-wallL`, [[0, "#fff", 0.10], [0.35, "#fff", 0.03], [1, "#fff", 0]]);
    s += hGradient(`${p}-wallR`, [[0, "#fff", 0], [0.65, "#fff", 0.03], [1, "#fff", 0.08]]);
    s += hGradient(`${p}-refl`, [[0, "#fff", 0], [0.5, "#fff", 0.045], [1, "#fff", 0]]);
    s += vGradient(`${p}-top`, [[0, o.colour, 0.22 * o.glow], [1, o.colour, 0]]);
    s += vGradient(`${p}-cap`, [[0, "#3b3633"], [0.4, "#1a1715"], [1, "#0c0a09"]]);
    s += vGradient(`${p}-base`, [[0, "#24201e"], [0.15, "#151211"], [1, "#050404"]]);
    s += `<filter id="${p}-halo" filterUnits="userSpaceOnUse" x="-60" y="-60" width="220" height="320"><feGaussianBlur stdDeviation="13"/></filter>`;
    s += `<filter id="${p}-bloom" filterUnits="userSpaceOnUse" x="-30" y="-30" width="160" height="260"><feGaussianBlur stdDeviation="4"/></filter>`;

    // Behind the cathodes: glass interior, rods, mica plate, lead wires.
    s += `<g id="${p}-back">${rect(...glass, `rx="${n(GLASS_W * 0.04)}" fill="url(#${p}-glass)"`)}`;
    for (const m of [-5, 105])
        s += rect(DIGIT_X + m * U - 1.1 * U, DIGIT_Y - 6 * U, 2.2 * U, GLASS_BOTTOM - DIGIT_Y + 6 * U, `fill="#2e2724"`);
    s += rect(DIGIT_X - 8 * U, MESH_BOTTOM + 6 * U, DIGIT_W + 16 * U, 3 * U, `fill="#3a322e" opacity="0.8"`);
    for (const m of [22, 40, 60, 78])
        s += rect(DIGIT_X + m * U, MESH_BOTTOM + 9 * U, 1.2 * U, GLASS_BOTTOM - MESH_BOTTOM - 9 * U, `fill="#241e1b"`);
    s += `</g>`;
    s += `<g id="${p}-wash">${rect(...glass, `rx="${n(GLASS_W * 0.04)}" fill="${o.colour}" opacity="${n(0.05 * o.glow)}"`)}</g>`;

    // Cathodes: each unlit one at its own depth, and the lit shape at full size.
    for (const c of stack)
        s += `<path id="${p}-c${c.d}" d="${wirePath(c.d, c.k)}"/>`;
    for (let d = 0; d < 10; ++d)
        s += `<path id="${p}-l${d}" d="${wirePath(d)}"/>`;

    s += `<g id="${p}-mesh" fill="none"><path d="${mesh.d}" stroke="#968a7e" stroke-opacity="0.2" stroke-width="0.6"/>`;
    s += rect(...mesh.frame, `stroke="#786c62" stroke-opacity="0.35" stroke-width="${n(GLASS_W * 0.012)}"`) + `</g>`;

    // In front: glass walls and reflection, outline, metal cap, base.
    s += `<g id="${p}-front">`;
    s += rect(GLASS_X, GLASS_TOP, GLASS_W * 0.08, GLASS_H, `fill="url(#${p}-wallL)"`);
    s += rect(GLASS_X + GLASS_W * 0.92, GLASS_TOP, GLASS_W * 0.08, GLASS_H, `fill="url(#${p}-wallR)"`);
    s += rect(GLASS_X + GLASS_W * 0.12, GLASS_TOP, GLASS_W * 0.2, GLASS_H, `fill="url(#${p}-refl)"`);
    const ow = TUBE_W * 0.012;
    s += rect(GLASS_X + ow / 2, GLASS_TOP + ow / 2, GLASS_W - ow, GLASS_H - ow,
        `rx="${n(GLASS_W * 0.04)}" fill="none" stroke="#fff" stroke-opacity="0.12" stroke-width="${n(ow)}"`);
    s += `<path d="M${n(capX)},${n(CAP_H)}V${n(r)}A${n(r)},${n(r)} 0 0 1 ${n(capX + r)},0H${n(capX + capW - r)}` +
        `A${n(r)},${n(r)} 0 0 1 ${n(capX + capW)},${n(r)}V${n(CAP_H)}Z" fill="url(#${p}-cap)"/>`;
    s += rect(capX + capW * 0.08, 0, capW * 0.84, 0.6, `fill="#fff" opacity="0.16"`);
    s += rect(baseX, baseY, baseW, BASE_H, `rx="${n(baseW * 0.04)}" fill="url(#${p}-base)"`);
    s += `</g>`;
    // Light caught by the glass top, the cap's lower edge and the base's top edge.
    s += `<g id="${p}-catch">${rect(...glass.slice(0, 3), GLASS_H * 0.06, `fill="url(#${p}-top)"`)}`;
    s += rect(capX + capW * 0.06, CAP_H * 0.8, capW * 0.88, CAP_H * 0.2, `fill="${o.colour}" opacity="${n(0.55 * o.glow)}"`);
    s += rect(baseX + baseW * 0.06, baseY, baseW * 0.88, BASE_H * 0.08, `fill="${o.colour}" opacity="${n(0.25 * o.glow)}"`);
    s += `</g>`;
    return { s, core };
}

// One unlit cathode, as seen behind (grey) or in front of (catching light) the lit one.
export function unlit(p, o, c, front) {
    return front
        ? `<use href="#${p}-c${c.d}" stroke="${tint(WIRE, o.colour, 0.45)}" stroke-width="${n(3 * U * c.k)}" opacity="${n((0.30 + 0.15 * o.glow) * (1 - c.i * 0.06))}"/>`
        : `<use href="#${p}-c${c.d}" stroke="${WIRE}" stroke-width="${n(3.6 * U * c.k)}" opacity="${n(0.38 - c.i * 0.022)}"/>`;
}

// The lit cathode (digit `d`, or -1) and/or decimal point: halo, bloom, wire and hot core.
export function lit(p, o, core, d, dot) {
    const dp = Digits.dp, cx = n(DIGIT_X + dp.x * U), cy = n(DIGIT_Y + dp.y * U * STRETCH);
    const wire = (w, colour) => d >= 0 ? `<use href="#${p}-l${d}" stroke="${colour}" stroke-width="${n(w)}"/>` : "";
    const point = (r, attrs) => dot ? `<circle cx="${cx}" cy="${cy}" r="${n(r)}" ${attrs}/>` : "";
    return `<g filter="url(#${p}-halo)" opacity="${n(0.85 * o.glow)}">${wire(18 * U, o.colour)}${point(2 * dp.r * U, `fill="${o.colour}"`)}</g>` +
        `<g filter="url(#${p}-bloom)" opacity="${n(0.5 + 0.5 * o.glow)}">${wire(7.5 * U, o.colour)}${point(dp.r * U, `fill="${o.colour}"`)}</g>` +
        wire(7.5 * U, o.colour) + wire(2.8 * U, core) +
        point(dp.r * U - 1.25 * U, `fill="${core}" stroke="${o.colour}" stroke-width="${n(2.5 * U)}"`);
}

function tube(p, o, core, ch) {
    const d = ch >= "0" && ch <= "9" ? +ch : -1;
    const dot = ch === ".";
    const isLit = d >= 0 || dot;
    const depth = Digits.stack.indexOf(d);
    const cathodes = front => o.showBack
        ? stack.filter(c => front ? c.i < depth : c.i > depth).map(c => unlit(p, o, c, front)).join("")
        : "";
    return `<use href="#${p}-back"/>${isLit ? `<use href="#${p}-wash"/>` : ""}` +
        `<g fill="none" stroke-linecap="round" stroke-linejoin="round">` +
        cathodes(false) + (isLit ? lit(p, o, core, d, dot) : "") + cathodes(true) + `</g>` +
        (o.showMesh ? `<use href="#${p}-mesh"/>` : "") +
        `<use href="#${p}-front"/>${isLit ? `<use href="#${p}-catch"/>` : ""}`;
}

// Id of the ready-made tube for one character of a value: a digit, "." or blank.
export function tubeId(ch, p = "wl") {
    return `${p}-t${ch >= "0" && ch <= "9" ? ch : ch === "." ? "dot" : "off"}`;
}

// Everything inside <defs>: shared layers plus one complete tube per character.
export function defsInner(opts = DEFAULTS, p = "wl") {
    const o = { ...DEFAULTS, ...opts };
    const { s, core } = layers(p, o);
    let t = "";
    for (const ch of ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", " "])
        t += `<g id="${tubeId(ch, p)}">${tube(p, o, core, ch)}</g>`;
    return s + t;
}

export function tubeX(i) {
    return n(i * (TUBE_W + GAP));
}

// The whole meter showing `value` (8 characters), with `pad` units of room for the glow.
export function meterSVG(value, opts = DEFAULTS, pad = 14, p = "wl") {
    const w = n(METER_W + 2 * pad), h = TUBE_H + 2 * pad;
    const tubes = [...value].map((ch, i) => `<use href="#${tubeId(ch, p)}" x="${tubeX(i)}"/>`).join("");
    return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${-pad} ${-pad} ${w} ${h}">` +
        `<defs>${defsInner(opts, p)}</defs>${tubes}</svg>`;
}
