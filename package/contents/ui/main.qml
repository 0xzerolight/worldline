pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "Worldline.js" as Worldline

PlasmoidItem {
    id: root

    // The current worldline. Shifts write it to the config, which persists it;
    // the meters animate to it whenever it changes.
    readonly property string worldline: Worldline.isValid(Plasmoid.configuration.value)
        ? Plasmoid.configuration.value : Worldline.EGG
    readonly property string waitRange: Plasmoid.configuration.minMinutes + "-" + Plasmoid.configuration.maxMinutes
    // Clock mode: the tubes show the local time and the worldline holds still.
    readonly property bool clockMode: Plasmoid.configuration.clockMode

    // The meters scramble into `v` on a shift; a clock tick is shown at once.
    signal scrambleTo(string v)
    signal showNow(string v)

    // What the tubes should show now.
    function face() {
        return clockMode ? Worldline.clock(new Date()) : worldline;
    }

    // A time leap (drift timer, click, wake): a new worldline, or in clock mode
    // a fresh scramble into the time.
    function shift() {
        if (clockMode) {
            scrambleTo(face());
            return;
        }
        Plasmoid.configuration.value = Worldline.next(worldline);
        scheduleNext();
    }

    function scheduleNext() {
        if (clockMode) {
            shiftTimer.stop();
            return;
        }
        const a = Plasmoid.configuration.minMinutes;
        const b = Plasmoid.configuration.maxMinutes;
        const lo = Math.max(1, Math.min(a, b));
        const hi = Math.max(lo, a, b);
        shiftTimer.interval = Math.round((lo + Math.random() * (hi - lo)) * 60000);
        shiftTimer.restart();
    }

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground | PlasmaCore.Types.ConfigurableBackground
    // No switchWidth/switchHeight: when set they override the form factor, and a
    // tall panel would get the full meter. Without them Plasma shows the full
    // meter on the desktop and the small tubes in panels.
    toolTipMainText: Plasmoid.title
    toolTipSubText: worldline

    // The linter (Qt 6.10) can't resolve object bindings into this attached list.
    Plasmoid.contextualActions: [
        PlasmaCore.Action {  // qmllint disable missing-property
            text: i18nc("@action:inmenu", "Clock Mode")  // qmllint disable unqualified
            icon.name: "clock"
            checkable: true
            checked: root.clockMode
            onTriggered: Plasmoid.configuration.clockMode = !root.clockMode
        }
    ]

    onWorldlineChanged: scrambleTo(worldline)
    onWaitRangeChanged: scheduleNext()
    onClockModeChanged: {
        scheduleNext();
        if (clockMode)
            clockTimer.arm(new Date());
        else
            clockTimer.stop();
        scrambleTo(face());
    }
    Component.onCompleted: {
        scheduleNext();
        if (clockMode)
            clockTimer.arm(new Date());
    }

    Timer {
        id: shiftTimer
        onTriggered: root.shift()
    }

    // Clock mode: fires just after each second turns over. A new hour
    // re-scrambles, as on the web page (and as nixie clocks do).
    Timer {
        id: clockTimer
        property int hour: -1

        function arm(now: date) {
            hour = now.getHours();
            interval = 1005 - Date.now() % 1000;
            restart();
        }

        onTriggered: {
            const now = new Date();
            if (now.getHours() !== hour)
                root.scrambleTo(Worldline.clock(now));
            else
                root.showNow(Worldline.clock(now));
            arm(now);
        }
    }

    // Wall-clock heartbeat: a big gap between ticks means the machine slept,
    // which counts as a time leap.
    Timer {
        property double last: Date.now()
        interval: 30000
        repeat: true
        running: true
        onTriggered: {
            const now = Date.now();
            if (now - last > 120000)
                root.shift();
            last = now;
        }
    }

    compactRepresentation: MouseArea {
        readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
        // Breathing room on every side, like the icons and clock next to it
        // (~32 px icons in a 44 px panel); scales with the panel thickness.
        readonly property real pad: Math.round((vertical ? width : height) * 0.15)

        Layout.minimumWidth: vertical ? 0 : (height - 2 * pad) * smallMeter.widthPerHeight + 2 * pad
        Layout.preferredWidth: Layout.minimumWidth
        Layout.minimumHeight: vertical ? (width - 2 * pad) / smallMeter.widthPerHeight + 2 * pad : 0
        Layout.preferredHeight: Layout.minimumHeight

        onClicked: root.shift()

        Meter {
            id: smallMeter
            anchors.fill: parent
            anchors.margins: parent.pad
            glowColor: Plasmoid.configuration.colour
            glow: Plasmoid.configuration.glow
            showBack: Plasmoid.configuration.showUnlit
            showMesh: Plasmoid.configuration.showMesh
            Component.onCompleted: value = root.face()
        }
        Connections {
            target: root
            function onScrambleTo(v: string) {
                smallMeter.shiftTo(v);
            }
            function onShowNow(v: string) {
                smallMeter.set(v);
            }
        }
    }

    fullRepresentation: MouseArea {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 12
        Layout.minimumHeight: Layout.minimumWidth / bigMeter.widthPerHeight
        Layout.preferredWidth: Kirigami.Units.gridUnit * 30
        Layout.preferredHeight: Layout.preferredWidth / bigMeter.widthPerHeight

        onClicked: root.shift()

        Meter {
            id: bigMeter
            anchors.fill: parent
            glowColor: Plasmoid.configuration.colour
            glow: Plasmoid.configuration.glow
            showBack: Plasmoid.configuration.showUnlit
            showMesh: Plasmoid.configuration.showMesh
            Component.onCompleted: value = root.face()
        }
        Connections {
            target: root
            function onScrambleTo(v: string) {
                bigMeter.shiftTo(v);
            }
            function onShowNow(v: string) {
                bigMeter.set(v);
            }
        }
    }
}
