# CLAUDE.md — worldline

Plasma 6 widget (pure QML, no C++). Package in `package/`, design in `docs/design.md`.

## Gate
- `make check` (metadata JSON, `qmllint --max-warnings 0`, `qmltestrunner` offscreen on the software renderer). CI runs the same in an `ubuntu:26.04` container.
- Qt tools live in `/usr/lib/qt6/bin` (not on PATH); the Makefile uses `QTBIN`.

## Rules
- Keep "Steins;Gate" out of the widget name, id and any store title (trademark); README may say "inspired by". No assets from the show or the game: everything is drawn in code.
- Nothing may animate or redraw between shifts (idle CPU must stay ~0 %).
- `i18n()` calls carry an end-of-line `// qmllint disable unqualified`; don't disable that warning more broadly.
- `ConfigGeneral.qml` must not declare `cfg_value`: Apply would write a stale worldline back.

## Looking at it
- `make preview SHOTS=dir` saves screenshots from the design preview; use that for visual checks.
- Never capture the screen with `spectacle -a` or similar: the active window is the user's, not the widget.
