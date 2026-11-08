pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import "Digits.js" as Digits

// Tall rectangular tube: flat glass walls, metal cap, square mesh, internals below the digits.
Item {
    id: tube

    property int digit: 0           // lit digit, -1 for none
    property bool dpLit: false
    property color glowColor: "#ff6b1a"
    property real glow: 0.7
    property bool showBack: true
    property bool showMesh: true

    readonly property bool detailed: height >= 90
    readonly property bool isLit: digit >= 0 || dpLit
    readonly property color coreColor: Qt.tint(glowColor, Qt.rgba(1, 0.97, 0.88, 0.62))
    readonly property color wireColor: "#5e4e45"
    readonly property color frontWireColor: Qt.tint(wireColor, Qt.rgba(glowColor.r, glowColor.g, glowColor.b, 0.45))
    readonly property int litDepth: Digits.stack.indexOf(digit)

    // Geometry, in multiples of the tube width (Meter sets height = 2.0 x width).
    readonly property real stretch: 1.15                     // digits taller than the 100x160 box
    readonly property real capH: width * 0.075
    readonly property real baseH: width * 0.12
    readonly property real glassX: width * 0.03
    readonly property real glassW: width - 2 * glassX
    readonly property real glassTop: capH * 0.6
    readonly property real u: width * 0.80 / 100            // digit units -> px
    readonly property real digitW: 100 * u
    readonly property real digitH: 160 * u * stretch
    readonly property real digitX: (width - digitW) / 2
    readonly property real digitY: capH + width * 0.10
    readonly property real meshTop: digitY - 8 * u
    readonly property real meshBottom: digitY + digitH + 10 * u
    readonly property real glassBottom: digitY + digitH + width * 0.293
    readonly property real glassH: glassBottom - glassTop
    readonly property real litPad: 26 * u

    implicitWidth: 100
    implicitHeight: 200

    // --- glass interior -------------------------------------------------
    Rectangle {
        id: glassBody
        x: tube.glassX
        y: tube.glassTop
        width: tube.glassW
        height: tube.glassH
        radius: width * 0.04
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#050404" }
            GradientStop { position: 0.5; color: "#15110f" }
            GradientStop { position: 1.0; color: "#050404" }
        }
    }

    Rectangle {   // warm wash inside the glass while lit
        x: glassBody.x
        y: glassBody.y
        width: glassBody.width
        height: glassBody.height
        radius: glassBody.radius
        color: tube.glowColor
        opacity: tube.isLit ? 0.05 * tube.glow : 0
    }

    // --- internals below the digits (and the rods holding the stack) -----
    Repeater {
        model: tube.detailed ? [-5, 105] : []
        Rectangle {
            required property int modelData
            x: tube.digitX + modelData * tube.u - width / 2
            y: tube.digitY - 6 * tube.u
            width: Math.max(1, 2.2 * tube.u)
            height: tube.glassBottom - y
            color: "#2e2724"
        }
    }
    Rectangle {   // mica plate
        visible: tube.detailed
        x: tube.digitX - 8 * tube.u
        y: tube.meshBottom + 6 * tube.u
        width: tube.digitW + 16 * tube.u
        height: Math.max(1, 3 * tube.u)
        color: "#3a322e"
        opacity: 0.8
    }
    Repeater {   // lead wires down to the base
        model: tube.detailed ? [22, 40, 60, 78] : []
        Rectangle {
            required property int modelData
            x: tube.digitX + modelData * tube.u
            y: tube.meshBottom + 9 * tube.u
            width: Math.max(1, 1.2 * tube.u)
            height: tube.glassBottom - y
            color: "#241e1b"
        }
    }

    // --- unlit cathodes behind the lit one --------------------------------
    Repeater {
        model: tube.showBack && tube.height >= 60 ? Digits.stack : []
        Wire {
            required property int modelData
            required property int index
            readonly property real k: 1 - index * 0.008
            visible: index > tube.litDepth
            cathode: modelData
            unit: tube.u * k
            stretch: tube.stretch
            x: tube.digitX + tube.digitW * (1 - k) / 2
            y: tube.digitY + tube.digitH * (1 - k) / 2
            width: tube.digitW * k
            height: tube.digitH * k
            opacity: 0.38 - index * 0.022
        }
    }

    // --- lit cathode with glow --------------------------------------------
    Item {   // thick hidden copy of the lit cathode, only used as the halo source
        id: haloSrc
        visible: false
        x: lit.x
        y: lit.y
        width: lit.width
        height: lit.height
        Wire {
            x: tube.litPad
            y: tube.litPad
            width: tube.digitW
            height: tube.digitH
            visible: tube.digit >= 0
            cathode: Math.max(0, tube.digit)
            unit: tube.u
            stretch: tube.stretch
            colour: tube.glowColor
            strokeUnits: 18
            minStroke: 2
        }
        Rectangle {
            visible: tube.dpLit
            width: 4 * Digits.dp.r * tube.u
            height: width
            radius: width / 2
            x: tube.litPad + Digits.dp.x * tube.u - width / 2
            y: tube.litPad + Digits.dp.y * tube.u * tube.stretch - height / 2
            color: tube.glowColor
        }
    }
    MultiEffect {
        source: haloSrc
        anchors.fill: haloSrc
        visible: lit.visible
        blurEnabled: true
        blur: 1.0
        blurMax: 64
        blurMultiplier: Math.max(0, tube.height / 300)
        opacity: 0.85 * tube.glow
    }
    MultiEffect {
        source: lit
        anchors.fill: lit
        visible: lit.visible
        blurEnabled: true
        blur: 1.0
        blurMax: Math.max(4, 28 * tube.u)
        colorization: 0.6
        colorizationColor: tube.glowColor
        opacity: 0.5 + 0.5 * tube.glow
    }
    Item {
        id: lit
        x: tube.digitX - tube.litPad
        y: tube.digitY - tube.litPad
        width: tube.digitW + 2 * tube.litPad
        height: tube.digitH + 2 * tube.litPad
        visible: tube.isLit

        Wire {
            x: tube.litPad
            y: tube.litPad
            width: tube.digitW
            height: tube.digitH
            visible: tube.digit >= 0
            cathode: Math.max(0, tube.digit)
            unit: tube.u
            stretch: tube.stretch
            colour: tube.glowColor
            strokeUnits: 7.5
            minStroke: 1.2
        }
        Wire {
            x: tube.litPad
            y: tube.litPad
            width: tube.digitW
            height: tube.digitH
            visible: tube.digit >= 0
            cathode: Math.max(0, tube.digit)
            unit: tube.u
            stretch: tube.stretch
            colour: tube.coreColor
            strokeUnits: 2.8
            minStroke: 0.6
        }
        Rectangle {
            visible: tube.dpLit
            width: 2 * Digits.dp.r * tube.u
            height: width
            radius: width / 2
            x: tube.litPad + Digits.dp.x * tube.u - width / 2
            y: tube.litPad + Digits.dp.y * tube.u * tube.stretch - height / 2
            color: tube.coreColor
            border.color: tube.glowColor
            border.width: Math.max(1, 2.5 * tube.u)
        }
    }

    // --- unlit cathodes in front of the lit one, catching its light --------
    Repeater {
        model: tube.showBack && tube.height >= 60 ? Digits.stack : []
        Wire {
            required property int modelData
            required property int index
            readonly property real k: 1 - index * 0.008
            visible: index < tube.litDepth
            cathode: modelData
            unit: tube.u * k
            stretch: tube.stretch
            x: tube.digitX + tube.digitW * (1 - k) / 2
            y: tube.digitY + tube.digitH * (1 - k) / 2
            width: tube.digitW * k
            height: tube.digitH * k
            colour: tube.frontWireColor
            strokeUnits: 3
            opacity: (0.30 + 0.15 * tube.glow) * (1 - index * 0.06)
        }
    }

    // --- square anode mesh in front of the stack ---------------------------
    Canvas {
        visible: tube.showMesh && tube.detailed
        x: glassBody.x
        y: tube.meshTop
        width: glassBody.width
        height: tube.meshBottom - tube.meshTop
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const w = width, h = height;
            const inset = w * 0.06;
            const pitch = Math.max(3, w * 0.05);
            ctx.lineWidth = Math.max(0.6, w * 0.005);
            ctx.strokeStyle = "rgba(150,138,126,0.20)";
            ctx.beginPath();
            for (let x = inset; x <= w - inset + 0.1; x += pitch) {
                ctx.moveTo(x, 0);
                ctx.lineTo(x, h);
            }
            for (let y = 0; y <= h + 0.1; y += pitch) {
                ctx.moveTo(inset, y);
                ctx.lineTo(w - inset, y);
            }
            ctx.stroke();
            ctx.lineWidth = Math.max(1, w * 0.012);   // anode frame
            ctx.strokeStyle = "rgba(120,108,98,0.35)";
            ctx.strokeRect(inset, 0, w - 2 * inset, h);
        }
    }

    // --- front glass ------------------------------------------------------
    Rectangle {   // left wall
        visible: tube.detailed
        x: tube.glassX
        y: tube.glassTop
        width: tube.glassW * 0.08
        height: tube.glassH
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.10) }
            GradientStop { position: 0.35; color: Qt.rgba(1, 1, 1, 0.03) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0) }
        }
    }
    Rectangle {   // right wall
        visible: tube.detailed
        x: tube.glassX + tube.glassW * 0.92
        y: tube.glassTop
        width: tube.glassW * 0.08
        height: tube.glassH
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0) }
            GradientStop { position: 0.65; color: Qt.rgba(1, 1, 1, 0.03) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.08) }
        }
    }
    Rectangle {   // broad soft reflection on the flat front
        visible: tube.detailed
        x: tube.glassX + tube.glassW * 0.12
        y: tube.glassTop
        width: tube.glassW * 0.2
        height: tube.glassH
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0) }
            GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.045) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0) }
        }
    }
    Rectangle {   // glow caught by the top of the glass
        visible: tube.detailed && tube.isLit
        x: tube.glassX
        y: tube.glassTop
        width: tube.glassW
        height: tube.glassH * 0.06
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(tube.glowColor.r, tube.glowColor.g, tube.glowColor.b, 0.22 * tube.glow) }
            GradientStop { position: 1.0; color: Qt.rgba(tube.glowColor.r, tube.glowColor.g, tube.glowColor.b, 0) }
        }
    }
    Rectangle {   // glass outline
        x: glassBody.x
        y: glassBody.y
        width: glassBody.width
        height: glassBody.height
        radius: glassBody.radius
        color: "transparent"
        border.width: Math.max(1, tube.width * 0.012)
        border.color: Qt.rgba(1, 1, 1, 0.12)
    }

    // --- metal cap --------------------------------------------------------
    Rectangle {
        x: tube.glassX - tube.width * 0.01
        width: tube.glassW + tube.width * 0.02
        y: 0
        height: tube.capH
        topLeftRadius: height * 0.5
        topRightRadius: height * 0.5
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#3b3633" }
            GradientStop { position: 0.4; color: "#1a1715" }
            GradientStop { position: 1.0; color: "#0c0a09" }
        }
        Rectangle {
            visible: tube.detailed
            x: parent.width * 0.08
            width: parent.width * 0.84
            height: 1
            color: Qt.rgba(1, 1, 1, 0.16)
        }
        Rectangle {   // orange glint on the cap's lower edge
            x: parent.width * 0.06
            width: parent.width * 0.88
            height: Math.max(1, parent.height * 0.2)
            y: parent.height - height
            color: tube.glowColor
            opacity: tube.isLit ? 0.55 * tube.glow : 0
        }
    }

    // --- base ---------------------------------------------------------------
    Rectangle {
        x: tube.width * 0.01
        width: tube.width * 0.98
        y: tube.glassBottom - tube.baseH / 2
        height: tube.baseH
        radius: width * 0.04
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#24201e" }
            GradientStop { position: 0.15; color: "#151211" }
            GradientStop { position: 1.0; color: "#050404" }
        }
        Rectangle {   // glow reflected on the base's top edge
            x: parent.width * 0.06
            width: parent.width * 0.88
            height: Math.max(1, parent.height * 0.08)
            color: tube.glowColor
            opacity: tube.isLit ? 0.25 * tube.glow : 0
        }
    }
}
