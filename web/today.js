// Today's worldline: one value per UTC day, the same for everyone. It starts at the
// easter egg on go-live day and drifts one widget shift per day from there.
import { Worldline } from "./widget.js";

export const EPOCH = Date.UTC(2026, 10, 8);   // go-live day: 1.048596
const DAY = 86400000;

export function dayIndex(date) {
    return Math.floor((date.getTime() - EPOCH) / DAY);
}

export function today(date) {
    let v = Worldline.EGG;
    for (let d = 1; d <= dayIndex(date); ++d)
        v = Worldline.next(v, Worldline.seeded(d));
    return v;
}

// Local time as a meter value, HH.MM.SS; the widget's clock mode uses the same.
export const clock = Worldline.clock;
