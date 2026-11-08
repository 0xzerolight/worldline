import QtQuick
import QtQuick.Shapes
import "Digits.js" as Digits

// One cathode wire, drawn in the 100 x 160 digit unit box scaled by `unit`.
Shape {
    id: w

    property int cathode: 0
    property real unit: 1
    property color colour: "#5e4e45"
    property real strokeUnits: 3.6
    property real minStroke: 1
    property real stretch: 1

    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        strokeColor: w.colour
        strokeWidth: Math.max(w.minStroke, w.strokeUnits * w.unit)
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap
        joinStyle: ShapePath.RoundJoin
        scale: Qt.size(w.unit, w.unit * w.stretch)
        PathSvg { path: Digits.paths[w.cathode] }
    }
}
