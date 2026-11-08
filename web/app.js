// Page wiring: shifting, share links, today's caption, settings, modes.
import { Worldline, Palette } from "./widget.js";
import { DEFAULTS } from "./svg.js";
import { Meter } from "./meter.js";
import { today } from "./today.js";
import { Modes } from "./modes.js";
import { Explode } from "./explode.js";

const $ = s => document.querySelector(s);
const KEY = "worldline.settings";

function load() {
    try {
        return { ...DEFAULTS, ...JSON.parse(localStorage.getItem(KEY)) };
    } catch {
        return { ...DEFAULTS };
    }
}

function save(s) {
    try {
        localStorage.setItem(KEY, JSON.stringify(s));
    } catch {
        // private window or storage blocked: settings just don't persist
    }
}

const settings = load();
const now = new Date();
const todays = today(now);
const fromHash = () => {
    const v = decodeURIComponent(location.hash.slice(1));
    return Worldline.isValid(v) ? v : null;
};

const meter = new Meter($("#meter"), settings, todays);
const reduce = matchMedia("(prefers-reduced-motion: reduce)");
meter.scramble = !reduce.matches;
reduce.addEventListener("change", e => { meter.scramble = !e.matches; });

// --- caption -------------------------------------------------------------------
let kind = "today";   // today | yours | shared
const dateText = new Intl.DateTimeFormat(undefined, { day: "numeric", month: "long", year: "numeric", timeZone: "UTC" }).format(now);

function caption() {
    const text = modes.clock ? "Local time"
        : kind === "today" ? "Today's worldline"
        : kind === "shared" ? "A shared worldline" : "Your worldline";
    $("#caption").textContent = text;
    $("#date").textContent = kind === "today" && !modes.clock ? dateText : "";
    $("#today").hidden = kind === "today" || modes.clock;
    $("#copy").hidden = modes.clock;
    $("#clock").setAttribute("aria-pressed", modes.clock);
    $("#desk").setAttribute("aria-pressed", modes.desk);
}

meter.onSettled = v => {
    if (modes.clock)
        return;
    $("#meter").setAttribute("aria-label", `Worldline ${v}`);
    $("#said").textContent = `Worldline ${v}`;
};

// --- shifting --------------------------------------------------------------------
function goTo(v, k) {
    kind = k;
    history.replaceState(null, "", k === "today" ? location.pathname + location.search : "#" + v);
    meter.shiftTo(v);
    caption();
}

function shift() {
    if (modes.clock) {
        modes.scrambleClock();
        return;
    }
    goTo(Worldline.next(meter.busy ? meter.target : meter.value), "yours");
}

const modes = new Modes(meter, shift, caption);

$("#meter").addEventListener("click", shift);
$("#shift").addEventListener("click", shift);
$("#today").addEventListener("click", () => goTo(today(new Date()), "today"));
$("#clock").addEventListener("click", () => modes.setClock(!modes.clock));
$("#desk").addEventListener("click", () => modes.setDesk(!modes.desk));

addEventListener("hashchange", () => {
    const v = fromHash();
    if (v && v !== meter.target) {
        modes.setClock(false);
        goTo(v, "shared");
    }
});

let copyTimer = 0;
$("#copy").addEventListener("click", async () => {
    const url = `${location.origin}${location.pathname}#${meter.busy ? meter.target : meter.value}`;
    const button = $("#copy");
    try {
        await navigator.clipboard.writeText(url);
        button.textContent = "Copied";
    } catch {
        button.textContent = "Couldn't copy";
    }
    clearTimeout(copyTimer);
    copyTimer = setTimeout(() => { button.textContent = "Copy link"; }, 1600);
});

addEventListener("keydown", e => {
    if (e.altKey || e.ctrlKey || e.metaKey || e.target.closest("input, button, select, textarea, a"))
        return;
    if ((e.key === " " || e.key === "Enter") && scrollY < innerHeight / 2) {
        e.preventDefault();
        shift();
    } else if (e.key === "c" || e.key === "C") {
        modes.setClock(!modes.clock);
    } else if (e.key === "f" || e.key === "F") {
        modes.setDesk(!modes.desk);
    } else if (e.key === "Escape") {
        openSettings(false);
        modes.setDesk(false);
    }
});

// --- settings --------------------------------------------------------------------
const panel = $("#settings");
const explode = new Explode($("#tube3d"), $("#apart"), settings);

function apply(change) {
    Object.assign(settings, change);
    save(settings);
    meter.setOptions(settings);
    explode.setOptions(settings);
    document.documentElement.style.setProperty("--glow", settings.colour);
    for (const b of $("#swatches").children)
        b.setAttribute("aria-pressed", b.dataset.colour === settings.colour);
}

function openSettings(open) {
    panel.hidden = !open;
    $("#gear").setAttribute("aria-expanded", open);
}

for (const p of Palette.presets) {
    const b = document.createElement("button");
    b.type = "button";
    b.title = b.ariaLabel = p.name;
    b.dataset.colour = p.colour;
    b.style.setProperty("--c", p.colour);
    b.addEventListener("click", () => apply({ colour: p.colour }));
    $("#swatches").append(b);
}
$("#glow").value = settings.glow;
$("#unlit").checked = settings.showBack;
$("#mesh").checked = settings.showMesh;
$("#glow").addEventListener("change", e => apply({ glow: +e.target.value }));
$("#unlit").addEventListener("change", e => apply({ showBack: e.target.checked }));
$("#mesh").addEventListener("change", e => apply({ showMesh: e.target.checked }));
$("#gear").addEventListener("click", () => openSettings(panel.hidden));
addEventListener("pointerdown", e => {
    if (!panel.hidden && !e.target.closest("#settings, #gear"))
        openSettings(false);
});
document.documentElement.style.setProperty("--glow", settings.colour);
for (const b of $("#swatches").children)
    b.setAttribute("aria-pressed", b.dataset.colour === settings.colour);

// --- first shift: into a shared link, or into today's worldline ----------------------
const shared = fromHash();
caption();
if (shared)
    goTo(shared, "shared");
else
    goTo(todays, "today");
