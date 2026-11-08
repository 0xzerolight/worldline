pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: meter

    property string value: "1.048596"
    property color glowColor: "#ff6b1a"
    property real glow: 0.7
    property bool showBack: true
    property bool showMesh: true
    property int scrambleMs: 1500
    property int lockStepMs: 120
    property int tickMs: 45
    readonly property bool busy: ticker.running
    signal settled()

    readonly property real aspect: 2.0
    readonly property real gapRatio: 0.035
    readonly property real tubeH: Math.max(1, Math.min(height, width / (8 + 7 * gapRatio) * aspect))
    readonly property real tubeW: tubeH / aspect
    readonly property real widthPerHeight: (8 + 7 * gapRatio) / aspect

    property var shown: digitsOf(value)
    property var lockAt: []
    property double startedAt: 0
    property string target: value

    onValueChanged: if (!busy) shown = digitsOf(value)

    function digitsOf(v) {
        const a = [];
        for (let i = 0; i < v.length; ++i) {
            const c = v.charAt(i);
            a.push(c === "." ? -1 : parseInt(c));
        }
        return a;
    }

    function shiftTo(v) {
        target = v;
        startedAt = Date.now();
        const l = [];
        for (let i = 0; i < 8; ++i)
            l.push(scrambleMs + i * lockStepMs);
        lockAt = l;
        ticker.start();
    }

    Timer {
        id: ticker
        interval: meter.tickMs
        repeat: true
        onTriggered: {
            const t = Date.now() - meter.startedAt;
            const goal = meter.digitsOf(meter.target);
            const s = [];
            let done = true;
            for (let i = 0; i < 8; ++i) {
                if (goal[i] < 0) {
                    s.push(-1);
                } else if (t >= meter.lockAt[i]) {
                    s.push(goal[i]);
                } else {
                    s.push(Math.floor(Math.random() * 10));
                    done = false;
                }
            }
            meter.shown = s;
            if (done) {
                stop();
                meter.value = meter.target;
                meter.settled();
            }
        }
    }

    Row {
        id: row
        anchors.horizontalCenter: parent.horizontalCenter
        y: (meter.height - meter.tubeH) / 2
        spacing: meter.tubeW * meter.gapRatio
        Repeater {
            model: 8
            RectTube {
                required property int index
                width: meter.tubeW
                height: meter.tubeH
                digit: meter.shown[index]
                dpLit: index === 1
                glowColor: meter.glowColor
                glow: meter.glow
                showBack: meter.showBack
                showMesh: meter.showMesh
            }
        }
    }
}
