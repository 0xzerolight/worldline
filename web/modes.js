// Clock mode (HH.MM.SS) and desk mode (fullscreen, screen kept awake, drifting on
// its own like the widget). Both only use timers that fire when something changes.
import { clock } from "./today.js";

const MINUTE = 60000;

export class Modes {
    // `shift()` makes a normal worldline shift; `changed()` is called when a mode flips.
    constructor(meter, shift, changed) {
        this.meter = meter;
        this.shift = shift;
        this.changed = changed;
        this.clock = false;
        this.desk = false;
        this.saved = null;
        this.tickTimer = 0;
        this.driftTimer = 0;
        this.awakeTimer = 0;
        this.wakeLock = null;
        this.hiddenAt = 0;
        this.wasFullscreen = false;

        document.addEventListener("visibilitychange", () => this.visibility());
        document.addEventListener("fullscreenchange", () => this.fullscreen());
        document.addEventListener("pointermove", () => this.wake());
        document.addEventListener("pointerdown", () => this.wake());
    }

    // --- clock -----------------------------------------------------------------
    setClock(on) {
        if (on === this.clock)
            return;
        this.clock = on;
        clearTimeout(this.tickTimer);
        if (on) {
            this.saved = this.meter.busy ? this.meter.target : this.meter.value;
            this.scrambleClock();
        } else {
            this.meter.shiftTo(this.saved);
        }
        this.changed();
    }

    // Scramble into the current time (on entry, on a tap and every hour).
    async scrambleClock() {
        clearTimeout(this.tickTimer);
        if (await this.meter.shiftTo(() => clock(new Date())))
            this.tick();
    }

    tick() {
        this.tickTimer = setTimeout(() => {
            if (!this.clock)
                return;
            const now = new Date();
            if (now.getMinutes() === 0 && now.getSeconds() === 0) {
                this.scrambleClock();
                return;
            }
            this.meter.set(clock(now));
            this.tick();
        }, 1000 - Date.now() % 1000 + 5);
    }

    // --- desk ------------------------------------------------------------------
    setDesk(on) {
        if (on === this.desk)
            return;
        this.desk = on;
        document.body.classList.toggle("desk", on);
        if (on) {
            document.documentElement.requestFullscreen?.().catch(() => {});
            this.lock();
            this.scheduleDrift();
            this.wake();
        } else {
            if (document.fullscreenElement)
                document.exitFullscreen?.().catch(() => {});
            this.wakeLock?.release().catch(() => {});
            this.wakeLock = null;
            clearTimeout(this.driftTimer);
            clearTimeout(this.awakeTimer);
            document.body.classList.remove("awake");
        }
        this.changed();
    }

    lock() {
        navigator.wakeLock?.request("screen").then(l => {
            if (this.desk)
                this.wakeLock = l;
            else
                l.release();   // desk mode ended while the request was pending
        }, () => {});
    }

    // Like the widget: a shift after a random 20–60 min wait.
    scheduleDrift() {
        clearTimeout(this.driftTimer);
        this.driftTimer = setTimeout(() => {
            if (!this.clock)
                this.shift();
            this.scheduleDrift();
        }, (20 + Math.random() * 40) * MINUTE);
    }

    // Controls show while the pointer moves, then hide again.
    wake() {
        if (!this.desk)
            return;
        document.body.classList.add("awake");
        clearTimeout(this.awakeTimer);
        this.awakeTimer = setTimeout(() => document.body.classList.remove("awake"), 2500);
    }

    // Like the widget's suspend check: back after more than 2 min away counts as a leap.
    visibility() {
        if (document.hidden) {
            this.hiddenAt = Date.now();
            return;
        }
        if (!this.desk)
            return;
        this.lock();
        if (Date.now() - this.hiddenAt > 2 * MINUTE && !this.clock) {
            this.shift();
            this.scheduleDrift();
        }
    }

    // Leaving fullscreen (Esc) leaves desk mode.
    fullscreen() {
        if (document.fullscreenElement)
            this.wasFullscreen = true;
        else if (this.wasFullscreen) {
            this.wasFullscreen = false;
            this.setDesk(false);
        }
    }
}
