// README screenshot: run with `make screenshot`.
// Grabs the meter at the widget's defaults, tubes only on a transparent background,
// to the path given after `--`, then quits. Needs a real window: the offscreen
// platform falls back to the software renderer, which has no glow. The image is in
// device pixels (~1400 px wide at 125 % scaling).
import QtQuick
import "../package/contents/ui"

Window {
    id: win

    readonly property real tubeH: 264
    readonly property real pad: Math.round(tubeH * 0.05)   // room for the outer glow

    width: Math.ceil(tubeH * meter.widthPerHeight) + 2 * pad
    height: tubeH + 2 * pad
    visible: true
    title: "Worldline screenshot"

    Item {
        id: frame
        anchors.fill: parent

        Meter {
            id: meter
            anchors.fill: parent
            anchors.margins: win.pad
        }
    }

    Timer {
        interval: 500
        running: true
        onTriggered: frame.grabToImage(function (r) {
            const args = Qt.application.arguments;
            r.saveToFile(args[args.length - 1]);
            Qt.quit();
        })
    }
}
