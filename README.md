# Worldline

A nixie-tube divergence meter widget for KDE Plasma 6, inspired by Steins;Gate.
Every so often it drifts to a new worldline.

![Worldline](assets/screenshot.png)

- Desktop or panel; click to shift, settings for wait time, colour, glow and detail.
- Drawn entirely in QML, no image assets; idle between shifts.

## Install

```sh
make install     # installs for the current user
```

Then add **Worldline** from *Add Widgets*. `make uninstall` removes it.

## Develop

Needs Qt 6 dev tools (`qml-qt6 qt6-declarative-dev-tools qml6-module-qttest` on Debian/Ubuntu).

```sh
make check       # lint + tests
make preview     # design preview window
make package     # worldline.plasmoid
```

## Licence

GPL-3.0-or-later. Steins;Gate is a trademark of its owners; this project is not affiliated with them.
