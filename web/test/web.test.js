import { test } from "node:test";
import assert from "node:assert/strict";
import { Digits, Worldline, Palette } from "../widget.js";
import { EPOCH, today, dayIndex, clock } from "../today.js";
import { readmeSVG, SCRAMBLE_MS, LOCK_STEP_MS } from "../readme-svg.js";
import { meterSVG } from "../svg.js";

const DAY = 86400000;

test("the widget's libraries load as modules", () => {
    assert.equal(Digits.paths.length, 10);
    assert.deepEqual(Digits.stack, [1, 6, 2, 7, 5, 0, 4, 9, 8, 3]);
    assert.equal(Worldline.EGG, "1.048596");
    assert.equal(Worldline.format(48596), "0.048596");
    assert.equal(typeof Worldline.seeded, "function");
    assert.equal(Palette.presets[0].colour, "#ff6b1a");
});

test("today starts at the easter egg on go-live day", () => {
    assert.equal(today(new Date(EPOCH)), Worldline.EGG);
    assert.equal(today(new Date(EPOCH - 5 * DAY)), Worldline.EGG);
    assert.equal(today(new Date(EPOCH + DAY - 1)), Worldline.EGG);
    assert.notEqual(today(new Date(EPOCH + DAY)), Worldline.EGG);
});

test("each day is one widget shift from the day before", () => {
    let prev = Worldline.EGG;
    for (let d = 1; d <= 400; ++d) {
        const v = today(new Date(EPOCH + d * DAY + 3600000));
        assert.equal(dayIndex(new Date(EPOCH + d * DAY)), d);
        assert.ok(Worldline.isValid(v), v);
        assert.equal(v, Worldline.next(prev, Worldline.seeded(d)));
        prev = v;
    }
});

test("clock reads local time as HH.MM.SS", () => {
    assert.equal(clock(new Date(2026, 0, 2, 3, 4, 5)), "03.04.05");
    assert.equal(clock(new Date(2026, 0, 2, 23, 59, 59)), "23.59.59");
});

test("the README meter locks onto the value, left to right", () => {
    const svg = readmeSVG("0.571024");
    const locks = [...svg.matchAll(/<use class="l" href="#wl-t(\w+)"[^>]*animation-delay:(\d+)ms/g)];
    assert.deepEqual(locks.map(m => m[1]), ["0", "5", "7", "1", "0", "2", "4"]);
    assert.deepEqual(locks.map(m => +m[2]), [0, 2, 3, 4, 5, 6, 7].map(i => SCRAMBLE_MS + i * LOCK_STEP_MS));
    assert.match(svg, /<use href="#wl-tdot"/);
    assert.equal(readmeSVG("0.571024"), svg, "same value, same file");
});

test("every reference in the markup resolves", () => {
    for (const svg of [meterSVG("12.34.56"), readmeSVG(Worldline.EGG)]) {
        const ids = new Set([...svg.matchAll(/ id="([^"]+)"/g)].map(m => m[1]));
        const refs = [...svg.matchAll(/(?:href="#|url\(#)([^")]+)/g)].map(m => m[1]);
        assert.ok(refs.length > 50);
        for (const r of refs)
            assert.ok(ids.has(r), `#${r} is missing`);
    }
});
