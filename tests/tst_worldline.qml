import QtQuick
import QtTest
import "../package/contents/ui/Worldline.js" as Worldline

TestCase {
    name: "Worldline"

    // Small seedable PRNG (mulberry32) so runs are reproducible.
    function seeded(seed) {
        let s = seed >>> 0;
        return function () {
            s = (s + 0x6D2B79F5) >>> 0;
            let t = s;
            t = Math.imul(t ^ (t >>> 15), t | 1);
            t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
            return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
        };
    }

    function field(v) {
        return v.charAt(0);
    }

    function circularDistance(a, b) {
        const d = Math.abs(Worldline.parse(a) % 1000000 - Worldline.parse(b) % 1000000);
        return Math.min(d, 1000000 - d);
    }

    function test_format_and_parse() {
        compare(Worldline.format(48596), "0.048596");
        compare(Worldline.format(1048596), "1.048596");
        compare(Worldline.parse("1.048596"), 1048596);
        compare(Worldline.parse("0.000001"), 1);
        verify(Worldline.isValid("0.571024"));
        verify(!Worldline.isValid("0.57102"));
        verify(!Worldline.isValid("10.571024"));
        verify(!Worldline.isValid(""));
    }

    function test_always_valid_and_in_known_fields() {
        const rng = seeded(1);
        let v = Worldline.EGG;
        for (let i = 0; i < 20000; ++i) {
            v = Worldline.next(v, rng);
            verify(Worldline.isValid(v), v);
            verify(field(v) === "0" || field(v) === "1", v);
        }
    }

    function test_drift_moves_are_small_and_keep_the_field() {
        const rng = seeded(2);
        let v = "0.571024";
        for (let i = 0; i < 20000; ++i) {
            const n = Worldline.next(v, rng);
            if (n !== Worldline.EGG && field(n) === field(v)) {
                verify(n !== v, "a shift always changes the value");
                verify(circularDistance(v, n) <= 100000, v + " -> " + n);
            }
            v = n;
        }
    }

    function test_jump_and_egg_rates() {
        const rng = seeded(3);
        const steps = 20000;
        let v = "0.571024", eggs = 0, jumps = 0;
        for (let i = 0; i < steps; ++i) {
            const n = Worldline.next(v, rng);
            if (n === Worldline.EGG && v !== Worldline.EGG)
                ++eggs;
            else if (field(n) !== field(v))
                ++jumps;
            v = n;
        }
        // Expected: eggs ~5 %, jumps ~15 % of the remaining 95 %.
        verify(eggs / steps > 0.03 && eggs / steps < 0.07, "egg rate " + eggs / steps);
        verify(jumps / steps > 0.11 && jumps / steps < 0.18, "jump rate " + jumps / steps);
    }

    function test_egg_never_repeats_itself() {
        const rng = seeded(4);
        for (let i = 0; i < 2000; ++i)
            verify(Worldline.next(Worldline.EGG, rng) !== Worldline.EGG);
    }
}
