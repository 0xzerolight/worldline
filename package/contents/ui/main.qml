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

    function shift() {
        Plasmoid.configuration.value = Worldline.next(worldline);
        scheduleNext();
    }

    function scheduleNext() {
        const a = Plasmoid.configuration.minMinutes;
        const b = Plasmoid.configuration.maxMinutes;
        const lo = Math.max(1, Math.min(a, b));
        const hi = Math.max(lo, a, b);
        shiftTimer.interval = Math.round((lo + Math.random() * (hi - lo)) * 60000);
        shiftTimer.restart();
    }

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground | PlasmaCore.Types.ConfigurableBackground
    switchWidth: Kirigami.Units.gridUnit * 8
    switchHeight: Kirigami.Units.gridUnit * 2
    toolTipMainText: Plasmoid.title
    toolTipSubText: worldline

    onWaitRangeChanged: scheduleNext()
    Component.onCompleted: scheduleNext()

    Timer {
        id: shiftTimer
        onTriggered: root.shift()
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

        Layout.minimumWidth: vertical ? 0 : height * smallMeter.widthPerHeight
        Layout.preferredWidth: Layout.minimumWidth
        Layout.minimumHeight: vertical ? width / smallMeter.widthPerHeight : 0
        Layout.preferredHeight: Layout.minimumHeight

        onClicked: root.expanded = !root.expanded

        Meter {
            id: smallMeter
            anchors.fill: parent
            glowColor: Plasmoid.configuration.colour
            glow: Plasmoid.configuration.glow
            showBack: Plasmoid.configuration.showUnlit
            showMesh: Plasmoid.configuration.showMesh
            Component.onCompleted: value = root.worldline
        }
        Connections {
            target: root
            function onWorldlineChanged() {
                smallMeter.shiftTo(root.worldline);
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
            Component.onCompleted: value = root.worldline
        }
        Connections {
            target: root
            function onWorldlineChanged() {
                bigMeter.shiftTo(root.worldline);
            }
        }
    }
}
