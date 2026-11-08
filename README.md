<h1 align="center">Worldline</h1>

<p align="center">
<a href="https://www.gnu.org/licenses/gpl-3.0"><img src="https://img.shields.io/badge/License-GPLv3-blue.svg" alt="License: GPL v3"></a>
<a href="https://kde.org/plasma-desktop/"><img src="https://img.shields.io/badge/KDE_Plasma-6-1d99f3?logo=kde&logoColor=white" alt="KDE Plasma 6"></a>
<a href="https://store.kde.org/p/2381415/"><img src="https://img.shields.io/badge/KDE_Store-Worldline-1d99f3?logo=kde&logoColor=white" alt="KDE Store"></a>
</p>

<p align="center">
A nixie-tube divergence meter widget for KDE Plasma 6, inspired by Steins;Gate.
Every so often it drifts to a new worldline.
</p>

<p align="center">
Please leave a ⭐ star if you like Worldline - it helps others find it :).
</p>

![Worldline showing 1.048596](assets/screenshot.png)

## Features

- Desktop or panel - the full meter on the desktop, small tubes in a panel.
- Shifts on its own every 20-60 minutes (adjustable), when clicked, and after the machine wakes from sleep.
- Settings - glow colour, glow strength, unlit digits, anode mesh.
- Drawn entirely in QML with no image assets; idle between shifts.

## Installation

Requires KDE Plasma 6.

From the [KDE Store](https://store.kde.org/p/2381415/): in **Add Widgets**, pick **Get New Widgets… → Download New Plasma Widgets…** and search for **Worldline**.

Or download [worldline.plasmoid](https://github.com/0xzerolight/worldline/releases/latest/download/worldline.plasmoid) and pick **Get New Widgets… → Install Widget From Local File…**.

Or from source:

```sh
git clone https://github.com/0xzerolight/worldline.git
cd worldline
make install
```

Then add **Worldline** from **Add Widgets**. `make uninstall` removes a source install.

<details>
<summary><strong>Development</strong></summary>

Needs Qt 6 dev tools (`qml-qt6 qt6-declarative-dev-tools qml6-module-qttest` on Debian/Ubuntu).

```sh
make check       # lint + tests
make preview     # design preview window
make package     # worldline.plasmoid
make screenshot  # assets/screenshot.png
```

</details>

## License

GNU General Public License v3.0 or later. See [LICENSE](LICENSE).
Steins;Gate is a trademark of its owners; this project is not affiliated with them.
