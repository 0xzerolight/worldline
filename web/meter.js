// The meter on the page: the svg.js markup inserted once, then each tick only
// swaps which ready-made tube each of the 8 <use> elements points at.
// Timing follows Meter.qml: 45 ms ticks, 1.5 s scramble, lock-in 120 ms apart.
import { meterSVG, defsInner, tubeId, DEFAULTS } from "./svg.js";

export class Meter {
    constructor(host, opts = {}, value = "1.048596") {
        this.opts = { ...DEFAULTS, ...opts };
        this.scrambleMs = 1500;
        this.lockStepMs = 120;
        this.tickMs = 45;
        this.scramble = true;
        this.value = this.target = value;
        this.onSettled = null;
        this.timer = 0;
        this.done = null;
        host.innerHTML = meterSVG(value, this.opts);
        this.defs = host.querySelector("defs");
        this.uses = [...host.querySelectorAll("svg > use")];
        this.shown = [...value];
    }

    get busy() {
        return this.timer !== 0;
    }

    setOptions(opts) {
        Object.assign(this.opts, opts);
        this.defs.innerHTML = defsInner(this.opts);
    }

    show(chars) {
        chars.forEach((c, i) => {
            if (this.shown[i] !== c) {
                this.uses[i].setAttribute("href", "#" + tubeId(c));
                this.shown[i] = c;
            }
        });
    }

    stop() {
        clearInterval(this.timer);
        this.timer = 0;
        this.done?.(false);
        this.done = null;
    }

    // Show `value` at once, without a scramble.
    set(value) {
        this.stop();
        this.value = this.target = value;
        this.show([...value]);
    }

    // Scramble, then lock onto `goal`: a value, or a function read on every tick
    // (the clock). Resolves true once settled, false if another shift or set() cut in.
    shiftTo(goal) {
        const read = typeof goal === "function" ? goal : () => goal;
        this.stop();
        this.target = read();
        if (!this.scramble) {
            this.set(this.target);
            this.onSettled?.(this.value);
            return Promise.resolve(true);
        }
        const start = performance.now();
        const tick = () => {
            const t = performance.now() - start;
            const goalNow = this.target = read();
            let settled = true;
            this.show([...goalNow].map((c, i) => {
                if (c === "." || t >= this.scrambleMs + i * this.lockStepMs)
                    return c;
                settled = false;
                return String(Math.floor(Math.random() * 10));
            }));
            if (settled) {
                this.done(true);
                this.done = null;
                this.stop();
                this.value = goalNow;
                this.onSettled?.(goalNow);
            }
        };
        const p = new Promise(resolve => { this.done = resolve; });
        this.timer = setInterval(tick, this.tickMs);
        tick();
        return p;
    }
}
