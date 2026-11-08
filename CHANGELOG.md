# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.1.0] - 2026-11-08

Clock mode: the meter can show the local time instead of the worldline, switched from the settings or the right-click menu.

### Added
- **Clock mode: the local time as 24-hour `HH.MM.SS` (Configure Worldline → General, or the right-click menu).** The dots move to the third and sixth tubes. A tick just after each second redraws only the tubes whose digit changed — the one exception to idling between shifts; a new hour, a click and waking from sleep scramble into the time. The worldline holds still meanwhile (no drift, "Shift every" greyed out) and the tubes scramble back to it when clock mode ends. The web page's clock now uses the widget's own `Worldline.clock`.

## [1.0.0] - 2026-11-08

First release: a nixie-tube divergence meter for the Plasma 6 desktop and panel that drifts to a new worldline every so often, on click and after sleep, with the same meter on the web.

### Added
- **Nixie-tube divergence meter for the desktop.** Eight rectangular tubes drawn entirely in QML (`RectTube.qml`, wire digits from `Digits.js`) — no image assets. A shift scrambles every tube for 1.5 s, then locks them left to right 120 ms apart; nothing animates between shifts, so the scene graph stays idle.
- **Small tubes in a panel, sized like the icons beside them.** 15 % of the panel thickness pads every side; the mesh, glass highlights and rods drop out under 90 px, the unlit cathodes under 60 px. No `switchWidth`/`switchHeight`, so a tall panel still gets the small tubes.
- **Shifts on a random timer, 20 to 60 minutes by default (Configure Worldline → General).** Drift stays within the current attractor field (the leading 0 or 1); 15 % of shifts jump to the other field and 5 % land on `1.048596`.
- **Shifts on click and after the machine wakes from sleep.** Waking is detected as a gap of more than 2 min between 30 s wall-clock ticks. The panel tubes shift on click instead of opening a popup.
- **Glow colour, glow strength, unlit digits and mesh (Configure Worldline → General).** Five colour presets from `Palette.js`, shared with the design preview and the web meter.
- **The current worldline survives a restart.** It lives in the widget config (`value`), which the settings page never declares, so Apply cannot write a stale value back.
- **Worldline in a browser (https://0xzerolight.github.io/worldline/).** The same digits and drift as the widget: `web/build.mjs` wraps the widget's own JS. One worldline per UTC day starting from `1.048596` on 8 Nov 2026, `#X.XXXXXX` share links, clock and desk modes, a tube taken apart in CSS 3D, and an animated `today.svg` for the README; CI deploys it after the gate and daily.
