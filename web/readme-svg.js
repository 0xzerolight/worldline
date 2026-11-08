// A standalone animated SVG for the README, where no script runs: each tube shows
// a run of random digits (one <use> per 80 ms frame, each visible only during its
// CSS animation window), then locks onto `value` left to right and holds.
import { Worldline } from "./widget.js";
import { defsInner, tubeId, tubeX, METER_W, TUBE_H, DEFAULTS } from "./svg.js";

export const FRAME_MS = 80;
export const SCRAMBLE_MS = 1500;
export const LOCK_STEP_MS = 120;
const PAD_X = 40;
const PAD_Y = 30;

const STYLE = `.f,.l{visibility:hidden;animation-name:on;animation-timing-function:linear}` +
    `.l{animation-duration:1ms;animation-fill-mode:forwards}` +
    `@keyframes on{from,to{visibility:visible}}` +
    `@media (prefers-reduced-motion:reduce){.f{display:none}.l{animation:none;visibility:visible}}`;

export function readmeSVG(value, opts = DEFAULTS) {
    // Same value, same scramble: the build output only changes when the value does.
    const rng = Worldline.seeded([...value].reduce((h, c) => Math.imul(h ^ c.charCodeAt(0), 16777619), 2166136261));
    const w = +(METER_W + 2 * PAD_X).toFixed(2), h = TUBE_H + 2 * PAD_Y;
    let tubes = "";
    [...value].forEach((ch, i) => {
        const at = `x="${+(PAD_X + tubeX(i)).toFixed(2)}" y="${PAD_Y}"`;
        if (ch === ".") {
            tubes += `<use href="#${tubeId(ch)}" ${at}/>`;
            return;
        }
        const lock = SCRAMBLE_MS + i * LOCK_STEP_MS;
        for (let t = 0; t < lock; t += FRAME_MS) {
            const d = String(Math.floor(rng() * 10));
            tubes += `<use class="f" href="#${tubeId(d)}" ${at} style="animation-delay:${t}ms;animation-duration:${Math.min(FRAME_MS, lock - t)}ms"/>`;
        }
        tubes += `<use class="l" href="#${tubeId(ch)}" ${at} style="animation-delay:${lock}ms"/>`;
    });
    return `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}" role="img">` +
        `<title>Worldline ${value}</title><style>${STYLE}</style><defs>${defsInner(opts)}` +
        `<linearGradient id="stage" x2="0" y2="1"><stop offset="0" stop-color="#0e0c0b"/><stop offset="1" stop-color="#050404"/></linearGradient></defs>` +
        `<rect width="${w}" height="${h}" rx="12" fill="url(#stage)"/>${tubes}</svg>\n`;
}
