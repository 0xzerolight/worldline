// Design preview: run with `make preview`.
// `make preview SHOTS=dir` also saves idle, mid-scramble and settled screenshots there.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../package/contents/ui"
import "../package/contents/ui/Worldline.js" as Worldline
import "../package/contents/ui/Palette.js" as Palette

ApplicationWindow {
    id: win

    readonly property string shotDir: {
        const args = Qt.application.arguments;
        const i = args.indexOf("--shots");
        return i >= 0 && i + 1 < args.length ? args[i + 1].replace(/\/?$/, "/") : "";
    }
    property bool firstShift: true

    function doShift() {
        const v = Worldline.next(big.busy ? big.target : big.value);
        big.shiftTo(v);
        small.shiftTo(v);
    }

    function capture(name) {
        if (shotDir === "")
            return;
        stage.grabToImage(function (r) {
            r.saveToFile(win.shotDir + name + ".png");
        });
    }

    width: 1100
    height: 600
    visible: true
    title: "Worldline preview"
    color: "#050404"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: stage
            Layout.fillWidth: true
            Layout.fillHeight: true
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#0e0c0b" }
                GradientStop { position: 1.0; color: "#050404" }
            }

            Meter {
                id: big
                anchors.fill: parent
                anchors.margins: parent.width * 0.04
                glowColor: colourBox.currentValue ?? Palette.presets[0].colour
                glow: glowSlider.value
                showBack: unlitSwitch.checked
                showMesh: meshSwitch.checked
                onSettled: if (win.firstShift) {
                    win.firstShift = false;
                    settledShot.start();
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: win.doShift()
            }
        }

        Rectangle {   // fake panel, to judge the 32 px readout
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            color: "#202326"
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                Label {
                    text: "Panel (32 px):"
                    color: "#a0a4a8"
                }
                Meter {
                    id: small
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 32 * widthPerHeight + 2
                    glowColor: big.glowColor
                    glow: big.glow
                    showBack: big.showBack
                    showMesh: big.showMesh
                }
                Item { Layout.fillWidth: true }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 8
            spacing: 14
            Button {
                text: "Shift"
                onClicked: win.doShift()
            }
            ComboBox {
                id: colourBox
                textRole: "name"
                valueRole: "colour"
                model: Palette.presets
            }
            Label { text: "Glow"; color: "#c8c8c8" }
            Slider {
                id: glowSlider
                from: 0
                to: 1
                value: 0.7
                Layout.preferredWidth: 140
            }
            Switch { id: unlitSwitch; text: "Unlit digits"; checked: true }
            Switch { id: meshSwitch; text: "Mesh"; checked: true }
            Item { Layout.fillWidth: true }
            Label {
                text: big.busy ? "→ " + big.target : big.value
                color: "#808080"
                font.family: "monospace"
            }
        }
    }

    Timer {   // with --shots: idle shot, then one shift with mid-scramble and settled shots
        interval: 1500
        running: win.shotDir !== ""
        onTriggered: {
            win.capture("01-idle");
            win.doShift();
            scrambleShot.start();
        }
    }
    Timer { id: scrambleShot; interval: 600; onTriggered: win.capture("02-scramble") }
    Timer { id: settledShot; interval: 400; onTriggered: win.capture("03-settled") }
}
