import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import "Palette.js" as Palette

// `value` (the current worldline) is deliberately not a cfg_ property here:
// Apply would otherwise write back a stale value over a shift that happened meanwhile.
KCM.SimpleKCM {
    id: page

    property alias cfg_minMinutes: minSpin.value
    property alias cfg_maxMinutes: maxSpin.value
    property string cfg_colour
    property alias cfg_glow: glowSlider.value
    property alias cfg_showUnlit: unlitBox.checked
    property alias cfg_showMesh: meshBox.checked

    Kirigami.FormLayout {
        RowLayout {
            Kirigami.FormData.label: i18nc("@label:spinbox", "Shift every:")  // qmllint disable unqualified
            spacing: Kirigami.Units.smallSpacing

            SpinBox {
                id: minSpin
                from: 1
                to: 1440
                editable: true
            }
            Label {
                text: i18nc("@label between two spinboxes, as in 20 to 60 minutes", "to")  // qmllint disable unqualified
            }
            SpinBox {
                id: maxSpin
                from: 1
                to: 1440
                editable: true
            }
            Label {
                text: i18nc("@label unit after the spinboxes", "minutes")  // qmllint disable unqualified
            }
        }

        ComboBox {
            Kirigami.FormData.label: i18nc("@label:listbox", "Colour:")  // qmllint disable unqualified
            textRole: "name"
            valueRole: "colour"
            model: Palette.presets
            currentIndex: Palette.indexOf(page.cfg_colour)
            onActivated: page.cfg_colour = currentValue
        }

        Slider {
            id: glowSlider
            Kirigami.FormData.label: i18nc("@label:slider", "Glow:")  // qmllint disable unqualified
            Layout.preferredWidth: Kirigami.Units.gridUnit * 12
            from: 0
            to: 1
            stepSize: 0.05
        }

        CheckBox {
            id: unlitBox
            Kirigami.FormData.label: i18nc("@label:group", "Show:")  // qmllint disable unqualified
            text: i18nc("@option:check", "Unlit digits")  // qmllint disable unqualified
        }

        CheckBox {
            id: meshBox
            text: i18nc("@option:check", "Mesh")  // qmllint disable unqualified
        }
    }
}
